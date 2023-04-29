import argparse
import os

parser = argparse.ArgumentParser(description='Generate a Tcl script from a list of VHDL source files.')
parser.add_argument('input_file', help='path to input file')
parser.add_argument('output_file', help='path to output Tcl script file')
parser.add_argument('testbench', help='name of the testbench entity')
args = parser.parse_args()

with open(args.input_file, 'r') as f:
    sources = f.read().split()

with open(args.output_file, 'w') as f:
    f.write('# Load design sources\n')
    for source in sources:
        f.write('vcom -work work -2008 "{}"\n'.format(os.path.basename(source)))

    f.write('\n# Load testbench source\n')
    f.write('vcom -work work -2008 "{}"\n'.format(args.testbench))

    f.write('\n# Elaborate design\n')
    f.write('vsim -L work -L secureip -t 1ps -voptargs="+acc" work.{}\n'.format(args.testbench.split('.vhdl')[0]))

    f.write('\n# Run simulation\n')
    f.write('run -all\n')

    f.write('\n# Save waveform\n')
    f.write('vcd file {}.vcd\n'.format(args.testbench.split('.vhdl')[0]))
    f.write('add wave *\n')
    f.write('wave zoom full\n')
