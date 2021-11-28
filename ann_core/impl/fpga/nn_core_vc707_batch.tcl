# vc707 batch implemenation of neuron network core from LSI Contest 2018
# part: xc7vx485tffg1761-2
# run the script: vivado -mode tcl -source vc707_batch.tcl

set_param general.maxThreads 4

set output_dir ./nn_core_vc707
file mkdir $output_dir

set src_dir ../../rtl
set vivado_dir $::env(XILINX_VIVADO)
read_vhdl -library ieee $vivado_dir/scripts/rt/data/fixed_pkg_2008.vhd

read_vhdl $src_dir/conf.vhd
read_vhdl $src_dir/blk_mem_bias.vhd
read_vhdl $src_dir/blk_mem_weight.vhd
read_vhdl $src_dir/blk_mem_img.vhd
read_vhdl $src_dir/blk_mem_res.vhd
read_vhdl $src_dir/sigmoid.vhd
read_vhdl $src_dir/neuron.vhd
read_vhdl $src_dir/max.vhd
read_vhdl $src_dir/controller.vhd
read_vhdl $src_dir/top_module.vhd
read_xdc ./nn_core_vc707.xdc

## step 2 run synthesis
synth_design -top top_module -part xc7vx485tffg1761-2 -flatten rebuilt
write_checkpoint -force $output_dir/post_synth

## Step 3 run placement and logic optimization, report utilization and timing
##        estimation
opt_design
power_opt_design
place_design
phys_opt_design
write_checkpoint -force $output_dir/post_place
report_timing_summary -file $output_dir/post_place_timing_summary.rpt

## Step 4: run router, report actual utilization and timing, write checkpoint
##         design, run drc, write verilog and xdc out
route_design
write_checkpoint -force $output_dir/post_route
report_timing_summary -file $output_dir/post_route_timing_summary.rpt

report_timing -sort_by group -max_paths 100 -path_type summary -file $output_dir/post_route_timing_timing.rpt

report_clock_utilization -file $output_dir/clock_util.rpt
report_utilization -file $output_dir/post_route_utilization.rpt
report_drc -file $output_dir/post_imp_drc.rpt
write_verilog -force $output_dir/nn_core_impl_netlist.v
write_xdc -no_fixed_only -force $output_dir/nn_core_impl.xdc

## step 5: generate bitstream
# write_bitstream -force $output_dir/nn_core.bit
