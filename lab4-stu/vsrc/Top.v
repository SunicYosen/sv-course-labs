// // `include "data_defs.v"

module Top(		
			clock, reset, enable_ex, src1, src2, imm, control_in, 
			mem_data_read_in, mem_data_write_out, mem_write_en, aluout,
			carry
			);
    parameter   instr_wd  	=   `INSTR_WIDTH;
    parameter   reg_wd    	=   `REGISTER_WIDTH;
    parameter   imm_wd    	=   `IMMEDIATE_WIDTH;

    input 					            clock, reset, enable_ex;
	input  	 		[reg_wd -1:0]       src1, src2; 
	input 	 		[reg_wd -1:0]       imm;
	input 		    [6:0]			    control_in;
    // the data that was read in the Decode stage
	input	 		[reg_wd	-1:0]		mem_data_read_in; 
    // data that is going to be written to the memory 
	output  	    [reg_wd -1:0]       mem_data_write_out; 
    output					            mem_write_en;  
	output	 		[reg_wd -1:0]		aluout;
	output								carry;
	
	wire  	 		[reg_wd -1:0]       aluin1, aluin2; 
	wire	     	[2:0]			    opselect;
	wire	        [2:0]               operation;	
	wire            [4:0]          		shift_number;
    wire                           		enable_shift, enable_arith;
	

	Ex_Preproc  Preproc_Inst (   
		.clock(clock), .reset(reset), .enable_ex(enable_ex), 
		.src1(src1), .src2(src2), .imm(imm), .control_in(control_in), 
        .mem_data_read_in(mem_data_read_in), .mem_data_write_out(mem_data_write_out), 
		.mem_write_en(mem_write_en), .aluin1(aluin1), .aluin2(aluin2), 
		.opselect_out(opselect), .operation_out(operation), .shift_number(shift_number), 
		.enable_shift(enable_shift), .enable_arith(enable_arith) 
	);

	ALU ALU_inst  (   	
		.clock(clock), .reset(reset), .aluin1(aluin1), .aluin2(aluin2), 
		.opselect(opselect), .operation(operation), .enable_shift(enable_shift), 
		.enable_arith(enable_arith), .shift_number(shift_number), 
		.aluout(aluout), .carry(carry)
	);


    
endmodule


