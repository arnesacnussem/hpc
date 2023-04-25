# This run on REMOTE
import itertools
import os
import time
from typing import List

import numpy as np
import oct2py
import ray
import redis
from ray.util import ActorPool

from executor import TestExecutor
from metric import Metric
from progress import Progress

ray.init()


def prep_testdata(prep_type: int, chk_bit: int):
    octave = oct2py.Oct2Py()
    octave.eval("pkg load communications;")
    if prep_type == 84:
        args = octave.prep84(chk_bit, nout=4)
    else:
        args = octave.prep73(chk_bit, nout=4)
    return args


class MainScript:
    db_key_progress = "hpc_test_progress"

    def __init__(self, target: str = None,
                 limit: int = 6,
                 batch_size: int = 1000,
                 prep_type: int = 73,
                 chk_bit: int = 3,
                 total_cpu: int = 3):
        if target is None:
            raise TypeError("test target is empty!")
        self.limit = limit
        self.workers = total_cpu
        self.batch_size = batch_size
        self.metric = Metric()
        self.redis = redis.Redis(host=os.environ.get("REDIS_HOST"), port=6379, db=0,
                                 password=os.environ.get("REDIS_PASSWORD"))
        print(f"redis: host={os.environ.get('REDIS_HOST')} pass={'REDIS_PASSWORD'}")
        print(f"""
        Distributed Tester
            Test info
            ==========
            total_cpu = {total_cpu}
            redis_user = {self.redis.acl_whoami()}
            batch_size = {batch_size}
            error_limit = {limit}
            
            Ray info
            ============
            {ray.available_resources()}
        """)

        previous = self.redis.get(self.db_key_progress)
        self.progress = Progress(func=target, t_type=prep_type, chk_bit=chk_bit, previous=previous)

        self.test_args = prep_testdata(prep_type=self.progress.type, chk_bit=self.progress.chk_bit)
        print(f"""
        Test data prepared
            codeword shape = {np.shape(self.test_args[0])}
            codeword size = {np.size(self.test_args[0])}
        """)
        self.codeword_size = np.size(self.test_args[0])
        self.range = range(1, self.codeword_size + 1)
        self.combinations = itertools.combinations(self.range, 1)

        if not self.progress.is_new():
            self.combinations = itertools.combinations(self.range, self.progress.errors)

            for i in range(self.progress.executed):
                next(self.combinations)

        self.batchID = 0

        pool = [
            TestExecutor.remote(self.test_args, self.progress.func) for _ in range(0, self.workers)
        ]
        self.pool = ActorPool(pool)

    def __get_batch(self):
        start = time.time_ns()
        self.batchID += 1
        batch_tmp = []
        for i in range(self.batch_size):
            n = next(self.combinations, None)
            if n is None:
                if self.progress.errors == self.limit or self.progress.errors == self.codeword_size:
                    return batch_tmp, self.batchID, True
                else:
                    self.progress.errors += 1
                    self.combinations = itertools.combinations(self.range, self.progress.errors)
                    return batch_tmp, self.batchID, False
            else:
                batch_tmp.append(np.array(n))
        self.metric.batch_generation.set(time.time_ns() - start)
        return batch_tmp, self.batchID, False

    def __update_metrics(self, succeed, exec_time, amount, errors):
        self.metric.batch_execution.set(exec_time)
        self.metric.job_executed.inc(amount, tags={"errors": "0"})
        self.metric.job_executed.inc(amount, tags={"errors": str(errors)})
        self.metric.job_succeed.inc(succeed, tags={"errors": str(errors)})

    def __update_progress(self, succeed, exec_time, amount, errors):
        if errors == self.progress.errors:
            self.progress.executed += amount

        if errors > self.progress.errors:
            self.progress.executed = amount
            self.progress.errors = errors

        if errors in self.progress.success:
            self.progress.success[errors] += succeed
        else:
            self.progress.success[errors] = succeed

        self.redis.set(self.db_key_progress, self.progress.dump())

    def main(self):
        end_of_work = False

        while not end_of_work:
            batches = []
            for i in range(self.workers):
                b, batch_id, end_of_work = self.__get_batch()
                if len(b) != 0:
                    batches.append((b, batch_id))
            self.run_batches(batches)

    # 执行多个batch, 每个batch应该会被分配到一个cpu
    def run_batches(self, batches: List):
        for result in self.pool.map(lambda actor, value: actor.runtest.remote(value), batches):
            succeed, exec_time, amount, errors, batch_id = result
            print(f"batch={batch_id} time={exec_time} errors={errors} amount={amount} succeed={succeed}")
            self.__update_metrics(succeed, exec_time, amount, errors)
            self.__update_progress(succeed, exec_time, amount, errors)


if __name__ == '__main__':
    main = MainScript("BAOv3")
    main.main()
