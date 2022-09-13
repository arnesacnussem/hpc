import numpy as np
import unittest
from concurrent.futures import ProcessPoolExecutor
import oct2py
import main
SCRIPT_DIR = "/workspaces/hpc/tester"


class Test_octave(unittest.TestCase):
    def test_runInit(self):
        oc = oct2py.Oct2Py()
        oc.addpath(SCRIPT_DIR)
        [code, H] = oc.prepare(3, nout=2)
        size = np.size(code)
        shape = np.shape(code)
        codeSerial = np.reshape(code, -1)

        print(size, shape, codeSerial, code, H)

    def test_main(self):
        main.initProc("test")
        result = main.run_test([0])
        print(f"Test finished with result={result}")


if __name__ == '__main__':
    unittest.main()
