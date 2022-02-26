onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /dds_sine_tb/i_clk
add wave -noupdate -format Logic /dds_sine_tb/i_rstb
add wave -noupdate -format Logic /dds_sine_tb/i_sync_reset
add wave -noupdate -format Literal -radix hexadecimal /dds_sine_tb/i_start_phase1
add wave -noupdate -format Literal -radix hexadecimal /dds_sine_tb/i_start_phase2
add wave -noupdate -format Literal -radix hexadecimal /dds_sine_tb/i_fcw
add wave -noupdate -format Literal -radix hexadecimal /dds_sine_tb/o_sine1
add wave -noupdate -format Literal -radix hexadecimal /dds_sine_tb/o_sine2
add wave -noupdate -format Analog-Step -height 150 -max 8192.0 -min -8192.0 -radix decimal /dds_sine_tb/o_sine1
add wave -noupdate -format Analog-Step -height 150 -max 8192.0 -min -8192.0 -radix decimal /dds_sine_tb/o_sine2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1475000 ps} 0} {{Cursor 2} {2475000 ps} 0}
configure wave -namecolwidth 209
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1280722 ps} {2925687 ps}
