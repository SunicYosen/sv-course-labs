`define 	CLK_PERIOD			10

`define     REGISTER_WIDTH      32  
`define     INSTR_WIDTH         32
`define     IMMEDIATE_WIDTH     16

`define     MEM_READ            3'b101
`define     MEM_WRITE           3'b100
`define     ARITH_LOGIC     	3'b001
`define     SHIFT_REG		    3'b000

// ARITHMETIC
`define     ADD		            3'b000
`define     HADD            	3'b001
`define     SUB		            3'b010
`define     NOT	            	3'b011
`define     AND        	        3'b100
`define     OR        	        3'b101
`define     XOR        	        3'b110
`define     LHG       	        3'b111

// SHIFTING
`define     SHLEFTLOG		    3'b000
`define     SHLEFTART         	3'b001
`define     SHRGHTLOG         	3'b010
`define     SHRGHTART         	3'b011

// DATA TRANSFER 
`define     LOADBYTE           	3'b000
`define     LOADBYTEU          	3'b100
`define     LOADHALF           	3'b001
`define     LOADHALFU          	3'b101
`define     LOADWORD           	3'b011


