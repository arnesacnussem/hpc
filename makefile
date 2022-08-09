GHDL=ghdl
WORKDIR=build
GHDL_ARG=--std=08 --workdir=$(WORKDIR)

TOP_LEVEL=channel_tb

scripts:
	@yarn tsc

vhdl: scripts
	@node dist/hierarchy.js

anl: vhdl
	@mkdir -p $(WORKDIR)
	$(GHDL) -a $(GHDL_ARG) $(shell cat vhdl.list)

elab: anl
	$(GHDL) -e $(GHDL_ARG) $(TOP_LEVEL)

run: elab
	$(GHDL) -r $(GHDL_ARG) $(TOP_LEVEL)

.PHONY: vhdl