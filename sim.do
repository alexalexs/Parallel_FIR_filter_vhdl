vsim filter_tb
add wave -position end  sim:/filter_tb/N_in
add wave -position end  sim:/filter_tb/N_out
add wave -position end  sim:/filter_tb/N_coeff
add wave -position end  sim:/filter_tb/M
add wave -position end  sim:/filter_tb/clk
add wave -position end  sim:/filter_tb/reset
add wave -position end  -format analog-step -min -100 -max 100 -height 300 sim:/filter_tb/data_in
add wave -position end  -format analog-step -min -100 -max 100 -height 300 sim:/filter_tb/data_out
add wave -position end  sim:/filter_tb/period
run 1 ms