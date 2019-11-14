# makefile by simulator the verilog/systemverilog project
# using vcs

BASE_DIR = $(abspath .)
SRC_DIR = $(BASE_DIR)
VSRC_DIR = $(SRC_DIR)/vsrc

LOG_DIR =  $(BASE_DIR)/build/log
BIN_DIR =  $(BASE_DIR)/build/bin

VSRC = $(VSRC_DIR)/alu_tb.sv

TOP_NAME = alu_tb

VPD_FILE = $(LOG_DIR)/$(TOP_NAME).vpd
LOG_FILE := $(LOG_DIR)/run_`date +%y%m%d%02k%M`.log

VCS = vcs
VCS_OPTS = -full64 -sverilog \
        -LDFLAGS -Wl,--no-as-needed \
		-timescale=1ns/10ps \
		-y $(VSRC_DIR) +libext+.v \
		-debug_access \
		-CC "-O3 -Wall" \
	    -CC "-Wextra -DNDEBUG" \

		# -y $(VSRC_DIR) +libext+.v

RUN_FLAGS = +vcdplusfile=$(VPD_FILE) \

BIN = $(BIN_DIR)/$(TOP_NAME).vsim

all: $(BIN)

%.vsim: $(VSRC)
	mkdir -p $(BIN_DIR) && \
	$(VCS) $(VCS_OPTS) $^ -o $@

run: $(BIN)
	mkdir -p $(LOG_DIR)
	$(BIN) $(RUN_FLAGS) > $(LOG_FILE)

.PHONY: clean
clean:
	rm -rf $(BIN) $(BIN).daidir $(LOG_FILE) $(LOG_DIR) $(BIN_DIR) ucli.key csrc DVEfiles
