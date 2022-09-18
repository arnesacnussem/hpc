import json
from datetime import datetime
from os.path import exists


class Progress:

    def __init__(self, file: str):
        self._file = file
        # error amount to generate
        self.errors = 1
        self.batch_id = 1
        # already executed in this errors amount
        self.executed: int = 0
        self.name = str(datetime.now())
        self.success: dict[int, int] = {}
        self._new = True
        self.load()

    def load(self):
        if exists(self._file):
            f_content = open(self._file, 'r').read()
            loaded: dict = json.loads(f_content)
            self.__dict__.update(loaded)
            self._new = False

    def save(self):
        open(self._file, 'w+').write(json.dumps(self.__dict__))

    def is_new(self):
        return self._new
