# Load design sources
vcom -work work -2008 "types.vhdl"
vcom -work work -2008 "constants.vhdl"
vcom -work work -2008 "test_data.vhdl"
vcom -work work -2008 "mxio_util.vhdl"
vcom -work work -2008 "core_util.vhdl"
vcom -work work -2008 "decoder_utils.vhdl"
vcom -work work -2008 "decoder_shpc.vhdl"
vcom -work work -2008 "decoder_ehpc.vhdl"
vcom -work work -2008 "decoder_bao3.vhdl"
vcom -work work -2008 "decoder_types.vhdl"
vcom -work work -2008 "decoder.vhdl"
vcom -work work -2008 "decoder_dummy.vhdl"
vcom -work work -2008 "decoder_pms2.vhdl"
vcom -work work -2008 "encoder.vhdl"
vcom -work work -2008 "mat_mul_rem2.vhdl"
vcom -work work -2008 "worker_controller.vhdl"
vcom -work work -2008 "p_decoder.vhdl"
vcom -work work -2008 "p_encoder.vhdl"
vcom -work work -2008 "harq_type.vhdl"
vcom -work work -2008 "matrix_io.vhdl"
vcom -work work -2008 "RandomBitFlipper.vhdl"
vcom -work work -2008 "decoder_tb.vhdl"

# Load testbench source
vcom -work work -2008 "decoder_tb.vhdl"
vsim -L work -t 1ps -voptargs="+acc=npr" work.decoder_tb
log -r *
vcd file wave.vcd
vcd add -r /decoder_tb/decoder_inst/decoder_gen/inst/*

add wave /decoder_tb/decoder_inst/decoder_gen/inst/*
run -all
wave zoom full
