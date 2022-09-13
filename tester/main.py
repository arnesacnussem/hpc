from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor, wait, ALL_COMPLETED
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway, Summary, Counter
from itertools import combinations
import multiprocessing
from multiprocessing.dummy import Process
from typing import List
import time
import oct2py
import os
import numpy as np
from os.path import exists
from datetime import datetime, date
import scipy

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PROGRESS_FILE = f"{SCRIPT_DIR}/progress.txt"

octave_global = oct2py.Oct2Py()
octave_global.addpath(SCRIPT_DIR)
[code, H, table] = octave_global.prepare(3, nout=3)
size = np.size(code)
shape = np.shape(code)
codeSerial = np.reshape(code, -1)

def prep():
    global octave_thread
    octave_thread = oct2py.Oct2Py()
    octave_thread.addpath(SCRIPT_DIR)
    octave_thread.eval("pkg load communications;")

def run_test(err_bits: tuple):
    global octave_thread

    code_in = np.copy(codeSerial)
    for pos in err_bits:
        code_in[pos] = 1 - codeSerial[pos]

    cw = octave_thread.baoV3(H, np.reshape(code_in, shape), table, nout=1)
    code_out = np.reshape(cw, -1)

    for pos in err_bits:
        if codeSerial[pos] != code_out[pos]:
            return False, len(err_bits)

    return True, len(err_bits)


def write_progress(_err_amount, _progress):
    progF = open(PROGRESS_FILE, "w")
    progF.write(f"{_err_amount},{_progress}")


if __name__ == '__main__':
    global comb
    cpu_count = multiprocessing.cpu_count()
    worker_amount = cpu_count if cpu_count < 3 else cpu_count - 1
    print(
        f"Using {worker_amount} of {multiprocessing.cpu_count()} cpu for processing pool.")
    executor = ProcessPoolExecutor(max_workers=worker_amount, initializer=prep)

    registry = CollectorRegistry()
    pcs = Counter('correct_success',
                  'Successfully corrected some error',
                  ['err_bit_amount'], registry=registry)
    pjc = Counter('job_executed', "Total job finished", registry=registry)
    pbg = Gauge('batch_gen', 'Batch generate time', registry=registry)
    pbe = Gauge('batch_exec', 'Batch finish time', registry=registry)
    jobName = str(datetime.now())

    batch = []
    batch_id = 0
    err_bit_amount = 1
    batch_size = 500

    skip = 0
    if exists(PROGRESS_FILE):
        pFile = open(PROGRESS_FILE, "r")
        pContent = pFile.read().split(',')
        if len(pContent) == 2:
            print(
                f"Found previous progress: err_bit={pContent[0]}, progress={pContent[1]}")
            skip = int(pContent[1])
            err_bit_amount = int(pContent[0])

    comb = combinations(range(size), err_bit_amount)
    for i in range(skip):
        _n = next(comb, None)
        if _n is None:
            err_bit_amount += 1
            comb = combinations(range(size), err_bit_amount)

    while True:
        endOfCombinations = False
        start_ns = time.time_ns()

        while len(batch) < batch_size:
            n = next(comb, None)
            if n is None:
                if err_bit_amount == size:
                    endOfCombinations = True
                    break
                else:
                    err_bit_amount += 1
                    comb = combinations(range(size), err_bit_amount)
                    continue
            else:
                batch.append(n)
        batch_gen = (time.time_ns() - start_ns)*1e-6
        pbg.set(batch_gen)
        print(
            f'generated batch {batch_id} in {batch_gen} ms')


        for success, err_am in executor.map(run_test, batch):
            pjc.inc()
            if success:
                pcs.labels(err_am).inc()

        batch_exec = (time.time_ns() - start_ns)*1e-6
        print(
            f'batch {batch_id} done in {batch_exec} ms')

        pbe.set(batch_exec)
        push_to_gateway('localhost:9091', job=jobName, registry=registry)
        if endOfCombinations:
            break

        batch_id += 1
        batch.clear()

    print("All Finished!")
