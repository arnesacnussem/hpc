GHDL=/usr/bin/ghdl
GHDLFLAGS=--std=08
GHDLRUNFLAGS=
TOP_LEVEL=matrix_transposer

# Default target : elaborate
all : init elab run

# Elaborate target.  Almost useless
elab : force
	$(GHDL) -c $(GHDLFLAGS) -e ${TOP_LEVEL}

# Run target
run : force
	$(GHDL) -c $(GHDLFLAGS) -r ${TOP_LEVEL} $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: force
	$(GHDL) -a $(GHDLFLAGS) vhdl/*

force: all
