# make CLASS testbench for exercise 1
# Sunic
# 2019.11.03

# Makefile by simulator the verilog/systemverilog project based on VCS

TB_CLASS_DIR   = $(SRC_DIR)/tb/tb-class

# TB_CLASS_FILES = $(TB_CLASS_DIR)/Packet.sv \
                   $(TB_CLASS_DIR)/Generator.sv \
				   $(TB_CLASS_DIR)/router_io.sv \
				   $(TB_CLASS_DIR)/router_test_top.sv \
				   $(TB_CLASS_DIR)/test.sv

TB_CLASS_FILES = $(wildcard $(TB_CLASS_DIR)/*.sv)

TB_CLASS ?= tb_class

VPD_CLASS_FILE  = $(LOG_DIR)/$(TB_CLASS).vpd
LOG_CLASS_FILE  = $(LOG_DIR)/$(TB_CLASS).log

RUN_CLASS_FLAGS = +vcdplusfile=$(VPD_CLASS_FILE)

BIN_CLASS       = $(BIN_DIR)/$(TB_CLASS).vsim

$(BIN_CLASS): $(TB_CLASS_FILES) $(RTL_FILES)
	mkdir -p $(BIN_DIR) && \
	$(VCS) $(VCS_OPTS) +incdir+$(TB_CLASS_DIR) $^ -o $@

$(LOG_CLASS_FILE): $(BIN_CLASS)
	mkdir -p $(LOG_DIR)
	$^ $(RUN_CLASS_FLAGS) > $@

run_class: $(LOG_CLASS_FILE)

.PHONY: clean_class
clean_class:
	rm -rf $(BIN_CLASS) $(BIN_CLASS).daidir $(LOG_DIR) $(BIN_DIR) ucli.key csrc DVEfiles vc_hdrs.h
