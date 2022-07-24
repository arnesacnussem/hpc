VHDL_LIST:=$(shell cat vhdl/.list)

compile_script:
	@yarn tsc

gen_file_list: compile_script
	@node dist/hierarchy.js
	VHDL_LIST:=$(shell cat vhdl/.list)
