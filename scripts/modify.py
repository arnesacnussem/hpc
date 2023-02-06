import argparse
import os
import sys
from typing import NoReturn


parser = argparse.ArgumentParser(
    description='Helper script for modify top-level and hierarchy list,\
         output file always same as hlist_path')

parser.add_argument("input", help="input file")
parser.add_argument("output", help="output file")
parser.add_argument("replace", help="replacement")
parser.add_argument(
    "hlist", help="path to hierarchy list generated by hierarchy.ts,\
         use '-' for stdin")


def get_abspath(fIn: str, fOut: str) -> tuple[str, str]:
    return os.path.abspath(fIn), os.path.abspath(fOut)


def modify_hierarchy_list(abs_in: str, abs_out: str, hlist: str) -> NoReturn:
    useStdio = hlist == '-'
    if useStdio:
        print('using stdin as hierarchy list', file=sys.stderr)
        hlist = sys.stdin.read()
    else:
        hlist = open(hlist).read()
    hlist = hlist.replace(abs_in, abs_out)
    if useStdio:
        print(hlist, file=sys.stdout)
    else:
        open(hlist, 'w').write(hlist)


def copy_and_modify_file(abs_in: str, abs_out: str, _old: str, _new: str):
    fContent = open(abs_in).read()
    fContent = fContent.replace(_old, _new, 1)
    open(abs_out, 'w').write(fContent)


def modify(fIn: str, fOut: str, replace: str, hlist: str):
    abs_in, abs_out = get_abspath(fIn, fOut)
    print(f"Modifing '{abs_in}' with replacement of '{replace}',\
         result write to '{abs_out}'",
          file=sys.stderr)
    copy_and_modify_file(abs_in, abs_out,
                         "DUMMY", replace.upper())
    modify_hierarchy_list(abs_in, abs_out, hlist)
    print("...ok", file=sys.stderr)


if __name__ == '__main__':
    args = parser.parse_args()
    modify(args.input, args.output, args.replace, args.hlist)