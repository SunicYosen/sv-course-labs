# make general testbench for exercise 1
# Sunic
# 2019.11.03

# Makefile by simulator the verilog/systemverilog project based on VCS

TB_GENERAL_DIR   = $(SRC_DIR)/tb/tb-general
TB_GENERAL_FILES = $(wildcard $(TB_GENERAL_DIR)/*.sv)

# TB_GENERAL_FILES = $(TB_GENERAL_DIR)/router_test_top.sv \
#                    $(TB_GENERAL_DIR)/router_io.sv \
#                    $(TB_GENERAL_DIR)/test.sv

TB_GENERAL ?= tb_general

VPD_GENERAL_FILE  = $(LOG_DIR)/$(TB_GENERAL).vpd
LOG_GENERAL_FILE  = $(LOG_DIR)/$(TB_GENERAL).log

RUN_GENERAL_FLAGS = +vcdplusfile=$(VPD_GENERAL_FILE)

BIN_GENERAL       = $(BIN_DIR)/$(TB_GENERAL).vsim

$(BIN_GENERAL): $(TB_GENERAL_FILES) $(RTL_FILES)
	mkdir -p $(BIN_DIR) && \
	$(VCS) $(VCS_OPTS) $^ -o $@

$(LOG_GENERAL_FILE): $(BIN_GENERAL)
	mkdir -p $(LOG_DIR)
	$^ $(RUN_GENERAL_FLAGS) > $@

run_general: $(LOG_GENERAL_FILE)

.PHONY: clean_general
clean_general:
	rm -rf $(BIN_GENERAL) $(BIN_GENERAL).daidir $(LOG_DIR) $(BIN_DIR) ucli.key csrc DVEfiles vc_hdrs.h
