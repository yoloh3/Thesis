RTL_DIR := ../rtl
TB_DIR := ../tb

all: neuron 

init:
	vlib work
	vcom $(RTL_DIR)/conf.vhd \
	     $(TB_DIR)/tb_conf.vhd

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
