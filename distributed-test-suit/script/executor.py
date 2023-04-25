import time
from typing import Tuple, List

import oct2py
import ray
from numpy import ndarray


@ray.remote(num_cpus=1)
class TestExecutor:

    def __init__(self, args: Tuple, func: str):
        start = time.time_ns()
        self.args = args
        self.octave = oct2py.Oct2Py()
        self.octave.eval("pkg load communications;")
        self.octave.addpath('targets')
        self.func_ptr = self.octave.get_pointer(func)
        print(f"TestExecutor{self.__str__()} initialized in {time.time_ns() - start}ns")

    def runtest(self, b: Tuple[List[ndarray], int]):
        batch, batch_id = b
        start = time.time_ns()
        succeed = self.octave.batch_tester(
            batch,
            self.func_ptr,
            *self.args,
            nout=1
        )
        return int(succeed), int((time.time_ns() - start) * 1e-6), len(batch), batch[0].size, batch_id
