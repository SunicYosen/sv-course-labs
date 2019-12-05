# make lab2
# Sunic
# 2019.11.03

# Makefile by simulator the verilog/systemverilog project based on VCS

default: all

BASE_DIR  = $(abspath .)
SRC_DIR   = $(BASE_DIR)/src
VSRC_DIR  = $(SRC_DIR)/rtl

LOG_DIR   =  $(BASE_DIR)/build/log
BIN_DIR   =  $(BASE_DIR)/build/bin
RTL_FILES =  $(SRC_DIR)/rtl/router_vcs.vp

VCS := vcs
VCS_OPTS += -full64 -sverilog \
            -LDFLAGS -Wl,--no-as-needed \
		    -timescale=1ns/10ps \
		    -debug_access \
		    -CC "-O3 -Wall" \
	        -CC "-Wextra -DNDEBUG" 

		  # -y $(VSRC_DIR) +libext+.v

include $(BASE_DIR)/make_general.mk  # include make_class.mk & make_general.mk
include $(BASE_DIR)/make_class.mk

all: $(BIN_GENERAL) $(BIN_CLASS)

.PHONY: run run_general run_class
run:
	make run_general
	make run_class

.PHONY: clean
clean:
	make clean_general
	make clean_class
