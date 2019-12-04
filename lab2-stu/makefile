#
# makefile for vcs
# Sunic
# 2019.11.03

# makefile by simulator the verilog/systemverilog project
# using vcs

BASE_DIR       = $(abspath .)
SRC_DIR        = $(BASE_DIR)/src
VSRC_DIR       = $(SRC_DIR)/rtl
TB_GENERAL_DIR = $(SRC_DIR)/tb/tb-general
TB_CLASS_DIR   = $(SRC_DIR)/tb/tb-class

LOG_DIR =  $(BASE_DIR)/build/log
BIN_DIR =  $(BASE_DIR)/build/bin

RTL_FILES        = $(SRC_DIR)/rtl/router_vcs.vp

TB_GENERAL_FILES = $(TB_GENERAL_DIR)/router_test_top.sv \
                   $(TB_GENERAL_DIR)/router_io.sv \
                   $(TB_GENERAL_DIR)/test.sv

TB_CLASS_FILES   = $(TB_CLASS_DIR)/

TB_GENERAL = tb_general
TB_CLASS   = tb_class

VPD_GENERAL_FILE := $(LOG_DIR)/$(TB_GENERAL).vpd
LOG_GENERAL_FILE := $(LOG_DIR)/$(TB_GENERAL).log

VCS = vcs
VCS_OPTS = -full64 -sverilog \
        -LDFLAGS -Wl,--no-as-needed \
		-timescale=1ns/10ps \
		-debug_access \
		-CC "-O3 -Wall" \
	    -CC "-Wextra -DNDEBUG" \

		# -y $(VSRC_DIR) +libext+.v

RUN_GENERAL_FLAGS = +vcdplusfile=$(VPD_GENERAL_FILE)

BIN_GENERAL = $(BIN_DIR)/$(TB_GENERAL).vsim

default: $(BIN_GENERAL)

all: $(BIN_GENERAL)

$(BIN_GENERAL): $(TB_GENERAL_FILES) $(RTL_FILES)
	mkdir -p $(BIN_DIR) && \
	$(VCS) $(VCS_OPTS) $^ -o $@

$(LOG_GENERAL_FILE): $(BIN_GENERAL)
	mkdir -p $(LOG_DIR)
	$^ $(RUN_GENERAL_FLAGS) > $(LOG_GENERAL_FILE)

run_general: $(LOG_GENERAL_FILE)

.PHONY: clean
clean:
	rm -rf $(BIN_GENERAL) $(BIN_GENERAL).daidir $(LOG_DIR) $(BIN_DIR) ucli.key csrc DVEfiles vc_hdrs.h
