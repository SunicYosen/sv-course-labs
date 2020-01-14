#
# makefile
# Sunic
# 2020.01.02
# makefile for questasim
#

BASE_DIR  := $(abspath .)
VSRC_DIR  := $(BASE_DIR)/vsrc
WORK_DIR  := $(BASE_DIR)/work

BUILD_DIR := $(BASE_DIR)/build

VSRC_VP  := $(VSRC_DIR)/ALU.vp                 \
            $(VSRC_DIR)/Arith_ALU.vp           \
			$(VSRC_DIR)/Shift_ALU.vp           \
			$(VSRC_DIR)/Ex_Preproc.vp

VSRC_FILE :=$(VSRC_DIR)/data_defs.v            \
            $(VSRC_DIR)/Top.v                  \
			$(VSRC_DIR)/Packet2.sv             \
			$(VSRC_DIR)/Driver.sv              \
			$(VSRC_DIR)/OutputPacket.sv        \
			$(VSRC_DIR)/Receiver.sv            \
			$(VSRC_DIR)/Scoreboard_coverage.sv \
			$(VSRC_DIR)/Generator.sv           \
			$(VSRC_DIR)/Execute.tb.sv          \
			$(VSRC_DIR)/Execute.test_top.sv    \
			$(VSRC_DIR)/Execute.if.sv

default: create_lib compile simulate

create_lib:
	rm -rf $(WORK_DIR)
	vlib $(WORK_DIR)

compile: $(VSRC_VP) $(VSRC_FILE)
	vlog -l $(BUILD_DIR)/compile.log $(VSRC_VP)
	vlog -l $(BUILD_DIR)/compile.log -mfcu -sv $(VSRC_FILE)

simulate:
	vsim -l $(BUILD_DIR)/run.log -coverage Execute_test_top -do "run 80000"

# gui:
# 	vsim -coverage Execute_test_top -do "run 2000"

clean:
	rm -rf $(BUILD_DIR)/* $(WORK_DIR)/ transcript



