scripts:
	@yarn tsc

vhdl: scripts
	@node dist/hierarchy.js

anl: vhdl
	ghdl -a --std=08 --workdir=build $(shell cat vhdl.list)
