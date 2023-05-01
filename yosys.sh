cd out
yosys -m ghdl -p "ghdl --std=08 `cat hierarchy.list` -e decoder_ehpc; shell"
yosys -m ghdl -p 'ghdl filename.vhdl -e top_unit [arch]; write_verilog filename.v'