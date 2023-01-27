#!/usr/bin/env python3
import os
import argparse
import json
import sys
from typing import Dict, List

# read algorithms list
algorithms: Dict[int, List[str]] = json.loads(open('./algorithms.json').read())
for alg in algorithms["_73"]:
    algorithms[alg] = '73'
for alg in algorithms["_84"]:
    algorithms[alg] = '84'
algorithms['_all'] = algorithms['_73']+algorithms['_84']


parser = argparse.ArgumentParser(description='Gradle build script wrapper')

parser.add_argument(
    'alg', choices=algorithms["_all"], metavar="<Algorithm>",
    help=f"Availiable choices: {', '.join(algorithms['_all'])}")
parser.add_argument("-chk", metavar="CHK",
                    help="size of CHK-by-n parity-check matrix", default=3)

parser.add_argument("-r", "--run", action="store_true",
                    help="run elabroated testbench")
parser.add_argument("-tb", "--testbench", default="decoder_tb",
                    help="specifiy testbench to elaborate")
parser.add_argument("-w", "--wave", action="store_true",
                    help="show waveform use gtkwave")
parser.add_argument("-c", "--clean", action="store_true",
                    help="clean before build")
parser.add_argument("-d", "--dry-run", action="store_true",
                    help="only print the command to run")
parser.add_argument("-f", "--force", action="store_true",
                    help="force ignore build cache")
# parser.add_argument('pass_to_gradle', nargs=argparse.REMAINDER)

if len(sys.argv) == 1:
    parser.print_help(sys.stderr)
    sys.exit(1)
args, unusedArgs = parser.parse_known_args()
if '--' in unusedArgs:
    unusedArgs.remove('--')


gradle_pArg = {
    "vhdlGen_size": algorithms[args.alg],
    "vhdlGen_chkBits": args.chk,
    "ghdl_topLevel": args.testbench
}
gradle_pArg_list = [
    f'-P{name}={gradle_pArg[name]}' for name in dict.keys(gradle_pArg)]


gradle_task = 'elaborate'
if args.run:
    gradle_task = 'run'
if args.wave:
    gradle_task = 'wave'

gradle_task = [gradle_task]
if args.clean:
    gradle_task.insert(0, "clean")


gradle_cmd_list = ["./gradlew"] + gradle_task + gradle_pArg_list + unusedArgs
gradle_cmd_str = ' '.join(gradle_cmd_list)
if args.dry_run:
    print("\n\t"+gradle_cmd_str+"\n")

os.system(gradle_cmd_str)
