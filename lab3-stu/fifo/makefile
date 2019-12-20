#
# makefile
# Sunic
# 2019.12.17

# makefile for vcs

BASE_DIR = $(abspath .)
SRC_DIR = $(BASE_DIR)
VSRC_DIR = $(SRC_DIR)/vsrc

LOG_DIR =  $(BASE_DIR)/build/log
BIN_DIR =  $(BASE_DIR)/build/bin

VSRC = $(VSRC_DIR)/fifo_tb.sv         \
	   $(VSRC_DIR)/fifo.v             \
	   $(VSRC_DIR)/fifo_property.sv       

TOP_NAME = fifo_tb

VPD_FILE  = $(LOG_DIR)/$(TOP_NAME).vpd
FSDB_FILE = $(LOG_DIR)/$(TOP_NAME).fsdb
LOG_FILE := $(LOG_DIR)/$(TOP_NAME).log
# LOG_FILE := $(LOG_DIR)/run_`date +%y%m%d%02k%M`.log

VCS = vcs
VCS_OPTS = -full64 -sverilog \
           -LDFLAGS -Wl,--no-as-needed \
		   -timescale=1ns/10ps \
		   -debug_access \
		   -CC "-O3 -Wall" \
	       -CC "-Wextra -DNDEBUG" \

		# -y $(VSRC_DIR) +libext+.v

# Assertion
VCS_OPTS += -assert enable_diag \
            -assert vpiSeqBeginTime \
            -assert vpiSeqFail

# Verdi
VCS_OPTS += -P ${VERDI_HOME}/share/PLI/VCS/LINUXAMD64/novas.tab \
               ${VERDI_HOME}/share/PLI/VCS/LINUXAMD64/pli.a

# Run
RUN_FLAGS = +vcdplusfile=$(VPD_FILE) \
            +fsdbfile=$(FSDB_FILE)   \
            -assert

BIN = $(BIN_DIR)/$(TOP_NAME).vsim

all: $(BIN)

$(BIN): $(VSRC)
	mkdir -p $(BIN_DIR) && \
	$(VCS) $(VCS_OPTS) $^ -o $@

run: $(BIN)
	mkdir -p $(LOG_DIR)
	$(BIN) $(RUN_FLAGS) > $(LOG_FILE)

$(VPD_FILE): $(BIN)
	mkdir -p $(LOG_DIR)
	$(BIN) $(RUN_FLAGS) > $(LOG_FILE)

$(FSDB_FILE): $(BIN)
	mkdir -p $(LOG_DIR)
	$(BIN) $(RUN_FLAGS) > $(LOG_FILE)

.PHONY: verdi
verdi: $(FSDB_FILE)
	verdi -sv $(VSRC) -ssf $(FSDB_FILE)

.PHONY: dve
dve: $(VPD_FILE)
	dve -vpd $(VPD_FILE)

.PHONY: clean
clean:
	rm -rf $(BIN) $(BIN).daidir $(LOG_FILE) $(LOG_DIR) $(BIN_DIR) ucli.key csrc DVEfiles novas* verdiLog 
