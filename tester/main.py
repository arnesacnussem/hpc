import multiprocessing
import os
import time
from concurrent.futures import ProcessPoolExecutor
from itertools import combinations
from threading import Thread
from typing import List

import numpy as np
import oct2py
from numpy import ndarray
from prometheus_client import CollectorRegistry, Gauge, Counter, push_to_gateway

import process
from Progress import Progress

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

registry = CollectorRegistry()
job_executed = Counter('job_executed', "Total job finished",["errors"],
                       registry=registry, namespace='hpc')
job_succeed = Counter('correct_success', 'Successfully corrected some error', ['errors'], registry=registry,
                      namespace='hpc')
batch_gen = Gauge('batch_gen', 'Batch generate time',
                  registry=registry, namespace='hpc')
batch_exec = Gauge('batch_exec', 'Batch finish time',
                   registry=registry, namespace='hpc')


class Main:
    __PROGRESS_FILE = f"{SCRIPT_DIR}/progress.json"

    def __init__(self, batch_size:int, chk_type:int, test_method:str):
        self.batchSize = batch_size
        cpu_count = multiprocessing.cpu_count()
        print(
            f"Using {cpu_count} CPU for process pool worker.")

        octave = oct2py.Oct2Py()
        octave.addpath(SCRIPT_DIR)
        # args_tuple = (code, H, table, syndt)
        if chk_type == 73:
            args_tuple = octave.prepare73(3, nout=4)
        elif chk_type == 84:
            args_tuple = octave.prepare84(3, nout=4)
        self.size = np.size(args_tuple[0])
        self._range = range(1, self.size + 1)
        self.executor = ProcessPoolExecutor(max_workers=cpu_count, 
                                            initializer=process.prep,
                                            initargs=(args_tuple, test_method))

        self.batchID = 0
        self.__restore_progress()
        self._last_time = time.time_ns()
        self.workers = cpu_count
        self.main_thread()

    def main_thread(self):
        while True:
            batches = []
            end_of_work = False
            for i in range(self.workers):
                b, batch_id, end_of_work = self.__get_batch()
                batches.append((b, batch_id))

            for succeed, exec_time, amount, errors, batch_id in self.executor.map(process.run_test_batch, batches):
                print(f"batch={batch_id} time={exec_time} errors={errors} amount={amount} succeed={succeed}")
                batch_exec.set(exec_time)
                job_executed.labels(0).inc(amount)
                job_executed.labels(errors).inc(amount)
                job_succeed.labels(errors).inc(succeed)
                if errors == self.progress.errors:
                    self.progress.executed += amount

                if errors > self.progress.errors:
                    self.progress.executed = amount
                    self.progress.errors = errors

                if errors in self.progress.success:
                    self.progress.success[errors] += succeed
                else:
                    self.progress.success[errors] = succeed

            self.progress.save()
            push_to_gateway('localhost:9091',
                            job=self.progress.name, 
                            registry=registry)
            if end_of_work:
                print("No more work to do, waiting for executor shutdown...")
                self.executor.shutdown(True, cancel_futures=False)

    @batch_gen.time()
    def __get_batch(self) -> tuple[List[ndarray], int, bool]:
        self.batchID += 1
        batch_tmp = []
        for i in range(self.batchSize):
            n = next(self.comb, None)
            if n is None:
                if self.errors == self.size:
                    return batch_tmp, self.batchID, True
                else:
                    self.errors += 1
                    self.comb = combinations(self._range, self.errors)
                    return batch_tmp, self.batchID, False
            else:
                batch_tmp.append(np.array(n))
        return batch_tmp, self.batchID, False

    def __restore_progress(self):
        self.progress = Progress(self.__PROGRESS_FILE)
        if not self.progress.is_new():
            print("Found previous progress, restore...")
            self.errors = self.progress.errors
            self.executed = self.progress.executed
            self.comb = combinations(self._range, self.errors)

            load_time = time.time_ns()
            for i in range(self.executed):
                next(self.comb)
            load_time = int((time.time_ns() - load_time) * 1e-6)
            print(
                f"Loaded previous progress in {load_time}ms: err={self.errors}, skipped={self.executed}")
        else:
            self.errors = 5
            self.comb = combinations(self._range, self.errors)


if __name__ == '__main__':
    Main(batch_size=1000, chk_type=84, test_method="EHPC_decoding")
