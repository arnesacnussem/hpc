from concurrent.futures import ProcessPoolExecutor
import json
from typing import List

from prometheus_client import CollectorRegistry, Gauge, push_to_gateway, Counter
from itertools import combinations
import multiprocessing
import time
import oct2py
import os
import numpy as np
from os.path import exists
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PROGRESS_FILE = f"{SCRIPT_DIR}/progress.json"


def prep(code, H, table):
    global octave_thread
    global arg_tuple

    arg_tuple = (code, H, table)
    octave_thread = oct2py.Oct2Py()
    octave_thread.addpath(SCRIPT_DIR)
    octave_thread.eval("pkg load communications;")


def run_test_batch(batch: List[tuple]):
    global octave_thread
    global arg_tuple

    func_ptr = octave_thread.get_pointer('baoV3')
    isEquals, err_amounts = octave_thread.batch_tester(batch, func_ptr, arg_tuple[0], arg_tuple[1], arg_tuple[2],
                                                         nout=2)

    # why return nested array?
    return isEquals[0], err_amounts[0]


progress = {
    'errors': 1,
    'executed': 0,
    'batch_id': 0,
    'skip': 0,
    'jobName': str(datetime.now()),
    'success': [],
    'total': [],
}


def save_progress():
    f = open(PROGRESS_FILE, "w")
    f.write(json.dumps(progress))
    f.close()


def load_progress():
    global progress
    if exists(PROGRESS_FILE):
        f = open(PROGRESS_FILE, 'r')
        progress = json.loads(f.read())
        return True
    return False


def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]


def main():
    global comb
    cpu_count = multiprocessing.cpu_count()
    worker_amount = cpu_count
    print(
        f"Using {worker_amount} of {multiprocessing.cpu_count()} cpu for processing pool.")

    octave = oct2py.Oct2Py()
    octave.addpath(SCRIPT_DIR)
    [code, h_mat, table] = octave.prepare(3, nout=3)
    size = np.size(code)
    executor = ProcessPoolExecutor(max_workers=worker_amount, initializer=prep, initargs=(code, h_mat, table))

    registry = CollectorRegistry()
    correct_success = Counter('correct_success',
                              'Successfully corrected some error',
                              ['errors'], registry=registry)
    job_executed = Counter('job_executed', "Total job finished", registry=registry)
    batch_gen_gauge = Gauge('batch_gen', 'Batch generate time', registry=registry)
    batch_exec_gauge = Gauge('batch_exec', 'Batch finish time', registry=registry)

    batch = []
    batch_size = 1000
    batch_id = 1
    errors = 1

    _range = range(1, size + 1)  # matlab array index start at 1
    comb = combinations(_range, errors)
    # TODO: LOAD PROGRESS

    while True:
        end_of_combinations = False
        start_ns = time.time_ns()

        while len(batch) < batch_size * worker_amount:
            n = next(comb, None)
            if n is None:
                if errors == size:
                    end_of_combinations = True
                    break
                else:
                    errors += 1
                    comb = combinations(_range, errors)
                    continue
            else:
                batch.append(np.array(n))
        batch_gen = (time.time_ns() - start_ns) * 1e-6
        batch_gen_gauge.set(batch_gen)
        print(
            f"generated batch {batch_id} in {batch_gen} ms")

        for isEquals, err_amounts in executor.map(run_test_batch, chunks(batch, batch_size)):
            b_size = len(isEquals)
            job_executed.inc(b_size)
            cs_tmp = {}
            for i in range(len(isEquals)):
                if isEquals[i] == 1:
                    err_am = int(err_amounts[i])
                    if err_am in cs_tmp:
                        cs_tmp[err_am] += 1
                    else:
                        cs_tmp[err_am] = 1

            for cs in cs_tmp:
                correct_success.labels(cs).inc(cs_tmp[cs])

        batch_exec = (time.time_ns() - start_ns) * 1e-6
        print(
            f"batch {batch_id} done in {batch_exec} ms")

        batch_exec_gauge.set(batch_exec)
        push_to_gateway('localhost:9091', job=progress['jobName'], registry=registry)
        if end_of_combinations:
            break

        batch_id += 1
        batch.clear()

    print("All Finished!")


if __name__ == '__main__':
    global comb
    try:
        main()
    except KeyboardInterrupt:
        save_progress()
