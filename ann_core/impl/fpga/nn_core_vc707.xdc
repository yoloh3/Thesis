## simple constraint for evaluation

create_clock -period 10.85 -name clk [get_ports clk]
create_clock -period 10.85 -name virtual_clk
set_false_path -from [get_ports res]

group_path -name INPUT -from [all_inputs] -to [all_clocks]
group_path -name OUTPUT -from [all_outputs] -to [all_clocks]
group_path -name COMBO -from [all_inputs] -to [all_outputs]
