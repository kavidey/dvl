onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /i2c_peripheral_tb/DUT/ADDRESS
add wave -noupdate -radix hexadecimal /i2c_peripheral_tb/DUT/tx
add wave -noupdate /i2c_peripheral_tb/DUT/scl
add wave -noupdate /i2c_peripheral_tb/DUT/sda
add wave -noupdate -radix hexadecimal /i2c_peripheral_tb/DUT/rx_reg
add wave -noupdate -radix hexadecimal /i2c_peripheral_tb/rx
add wave -noupdate /i2c_peripheral_tb/DUT/rw
add wave -noupdate /i2c_peripheral_tb/DUT/state
add wave -noupdate /i2c_peripheral_tb/DUT/start_stop
add wave -noupdate -radix decimal /i2c_peripheral_tb/DUT/counter
add wave -noupdate /i2c_peripheral_tb/DUT/sda_out
add wave -noupdate /i2c_peripheral_tb/DUT/output_enable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20957 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {154550 ps}
