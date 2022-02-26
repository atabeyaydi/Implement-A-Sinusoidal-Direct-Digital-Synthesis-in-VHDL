vcom  -work work ./dds_sine.vhd
vcom  -work work ./tb/dds_sine_tb.vhd

vsim work.dds_sine_tb -novopt

do dds_sine_wave.do

