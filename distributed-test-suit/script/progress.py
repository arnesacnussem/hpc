import json
import time

from typing import Dict


class Progress:

    def __init__(self, func: str, t_type: int = None, chk_bit: int = None, previous: str = None):
        self.executed: int = 0
        self.func = func
        self.name = str(int(time.time()))
        self.success: Dict[int, int] = {}
        self.errors = 1
        self.type = 73 if t_type is None else t_type
        self.chk_bit = 3 if chk_bit is None else chk_bit
        self._new = True
        if previous is not None:
            self.load(previous)

    def load(self, j: str):
        loaded: dict = json.loads(j)
        if loaded.get("func") != self.func:
            raise TypeError(f"{self.func} is not the same function from previous progress!")
        self.__dict__.update(loaded)
        self._new = False

        # fix self.success become a List[str] rather a List[int] after load
        t = {}
        for k in self.success:
            t[int(k)] = self.success[k]
        self.success = t

    def dump(self):
        return json.dumps(self.__dict__)

    def is_new(self):
        return self._new
