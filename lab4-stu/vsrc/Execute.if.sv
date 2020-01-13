// `include "data_defs.v"
interface Execute_io(input bit clock);
  	parameter   instr_wd  	=   `INSTR_WIDTH;
  	parameter   reg_wd    	=   `REGISTER_WIDTH;
  	parameter   imm_wd    	=   `IMMEDIATE_WIDTH;
 
  	logic						reset, enable_ex;
  	logic 	[reg_wd -1:0]       src1, src2; 
  	logic 	[reg_wd -1:0]       imm;
  	logic 	[6:0]				control_in;
  	logic	[reg_wd	-1:0]		mem_data_read_in; 

  	logic  	[reg_wd -1:0]       mem_data_write_out; 
  	logic						mem_write_en;  
   	logic 	[reg_wd -1:0]		aluout;
 	logic						carry;  

  	clocking cb @(posedge clock);
    	default input #1 output #1;
		
		output 	enable_ex;
   		output	src1, src2; 
   		output 	imm;
   		output 	control_in;
   		output	mem_data_read_in; 
   		input	mem_data_write_out; 
   		input	mem_write_en;  
   		input	aluout;
   		input	carry;		
  	endclocking

	modport TB(clocking cb, output reset); 
endinterface

interface DUT_probe_if(	
	input bit clock,
	input logic [`REGISTER_WIDTH-1:0]	aluin1, 
	input logic [`REGISTER_WIDTH-1:0]	aluin2, 
	input logic [2:0]			opselect,
	input logic [2:0]			operation,
	input logic [4:0]      	shift_number,
	input logic 				enable_shift, 
	input logic 				enable_arith 
	);
	
  	clocking cb @(posedge clock);
    	default input #1 output #1;		
		
		input	aluin1; 
		input	aluin2; 
		input	opselect;
		input	operation;
		input	shift_number;
		input	enable_shift; 
		input	enable_arith;
		
  	endclocking
	
endinterface
	