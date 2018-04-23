##############################################################################
# Project name   :
# File name      : Makefile
# Author         : Huy-Hung Ho
# Last modified  : Apr 02 2018 10:46
# Guide          :
###############################################################################
RTL_DIR  := ../rtl
TB_DIR   := ../tb
COMP_OPT := #-cover bcst
VSIM_OPT := #-coverage
TCL_ENAB := -c

all: top_module

init:
	vlib work
	vcom $(COMP_OPT) $(RTL_DIR)/conf.vhd \
	     $(TB_DIR)/tb_conf.vhd


top_module: init
	@rm -rf ../tb/output_ann.bin
	vcom $(COMP_OPT) $(RTL_DIR)/blk_mem*.vhd \
			 $(RTL_DIR)/max.vhd \
			 $(RTL_DIR)/sigmoid.vhd \
			 $(RTL_DIR)/relu.vhd \
			 $(RTL_DIR)/neuron.vhd \
			 $(RTL_DIR)/controller.vhd \
			 $(RTL_DIR)/top_module.vhd \
			 $(TB_DIR)/top_module_tb.vhd
	vsim $(VSIM_OPT) -novopt -wlf top_module.wlf top_module_tb \
		$(TCL_ENAB) -do "run -a; exit;"

run:
	vsim $(VSIM_OPT) -novopt -wlf top_module.wlf top_module_tb \
		$(TCL_ENAB) -do "run -a; exit;"

sim:
	vsim $(VSIM_OPT) -novopt top_module_tb \
									 -do "config wave -signalnamewidth 1; \
									      add wave -radix unsigned -group "neuron" uut/sel_neu_0/neuron_0/*; run -all;"	

neuron: init
	vcom $(RTL_DIR)/sigmoid.vhd \
			 $(RTL_DIR)/neuron.vhd \
			 $(TB_DIR)/neuron_tb.vhd
	vsim -novopt -wlf neuron.wlf neuron_tb \
		-c -do "run -a; exit;"

sc_neuron: init
	vcom -2008 $(RTL_DIR)/lfsr.vhd \
						 $(RTL_DIR)/sc_add.vhd \
						 $(RTL_DIR)/sc_mul.vhd
	vcom $(RTL_DIR)/bin2sc.vhd \
			 $(RTL_DIR)/sc_sigmoid.vhd \
			 $(RTL_DIR)/sc_relu.vhd \
			 $(RTL_DIR)/sc_neuron.vhd \
			 $(TB_DIR)/sc_neuron_tb.vhd
	vsim -novopt -wlf sc_neuron.wlf sc_neuron_tb \
		-c -do "run -a; exit;"

sc_top: init
	vcom -2008 $(RTL_DIR)/lfsr.vhd \
						 $(RTL_DIR)/sc_add.vhd \
						 $(RTL_DIR)/sc_mul.vhd \
						 $(RTL_DIR)/bin2sc.vhd
	vcom $(COMP_OPT) $(RTL_DIR)/blk_mem*.vhd \
			 $(RTL_DIR)/max.vhd \
			 $(RTL_DIR)/sc_sigmoid.vhd \
			 $(RTL_DIR)/sc_neuron.vhd \
			 $(RTL_DIR)/sc_relu.vhd \
			 $(RTL_DIR)/controller.vhd \
			 $(RTL_DIR)/top_module.vhd \
			 $(TB_DIR)/top_module_tb.vhd
	vsim $(VSIM_OPT) -novopt -wlf sc_top_module.wlf top_module_tb \
		$(TCL_ENAB) -do "run -a; exit;"

clean:
	rm -rf ./modelsim.ini ../rtl/modelsim.ini ../tb/modelsim.ini \
			 	 ./transcipt ./work/ ./transcript ./vsim*
