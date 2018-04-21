RTL_DIR := ../rtl
TB_DIR := ../tb

all: top_module

init:
	vlib work
	vcom $(RTL_DIR)/conf.vhd \
	     $(TB_DIR)/tb_conf.vhd

top_module: 
	vcom $(RTL_DIR)/blk_mem*.vhd \
			 $(RTL_DIR)/max.vhd \
			 $(RTL_DIR)/sigmoid.vhd \
			 $(RTL_DIR)/neuron.vhd \
			 $(RTL_DIR)/controller.vhd \
			 $(RTL_DIR)/top_module.vhd \
			 $(TB_DIR)/top_module_tb.vhd
	vsim -novopt -wlf top_module.wlf top_module_tb \
		-c -do "log -r /*; run -a; exit;"

neuron: init
	vcom $(RTL_DIR)/sigmoid.vhd \
			 $(RTL_DIR)/neuron.vhd \
			 $(TB_DIR)/neuron_tb.vhd
	vsim -novopt -wlf neuron.wlf neuron_tb \
		-c -do "log -r /*; run -a; exit;"

clean:
	rm -rf ../rtl/modelsim.ini ../tb/modelsim.ini \
			 	 ../sim/modelsim.ini ../sim/transcipt \
				 ../sim/work/ ../sim/transcript
