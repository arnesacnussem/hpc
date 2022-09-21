import time
from typing import List

import oct2py
from numpy import ndarray

from main import SCRIPT_DIR


def prep(_arg_tuple: tuple, func: str):
    global octave
    global arg_tuple
    global func_ptr

    arg_tuple = _arg_tuple
    octave = oct2py.Oct2Py()
    octave.addpath(SCRIPT_DIR)
    octave.eval("pkg load communications;")
    func_ptr = octave.get_pointer(func)


def run_test_batch(b: tuple[List[ndarray], int]) -> tuple[int, float, int, int, int]:
    global octave
    global arg_tuple
    global func_ptr
    batch,batch_id = b
    start = time.time_ns()
    succeed = octave.batch_tester(batch,
                                  func_ptr,
                                  *arg_tuple,
                                  nout=1)

    return int(succeed), int((time.time_ns() - start) * 1e-6), len(batch), batch[0].size, batch_id
