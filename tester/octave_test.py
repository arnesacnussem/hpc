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
        [code, H, table] = oc.prepare(3, nout=3)
        size = np.size(code)
        shape = np.shape(code)
        codeSerial = np.reshape(code, -1)

        print(size, shape, codeSerial, code, H)
        return code, H, table

    def test_main(self):
        [code, H, table] = self.test_runInit()
        main.prep(code, H, table)
        [isEquals, err_amounts] = main.run_test_batch(
            [
                np.array([1,2,3]),
                np.array([2,3])
            ]
        )
        print(f"Test finished with result={isEquals}")


if __name__ == '__main__':
    unittest.main()
