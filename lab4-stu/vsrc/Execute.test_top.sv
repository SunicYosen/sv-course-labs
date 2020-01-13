
module Execute_test_top;
	parameter simulation_cycle = `CLK_PERIOD;

	reg  SysClock;
	
	Execute_io top_io(SysClock); 	
	DUT_probe_if DUT_probe(
		.clock(SysClock),
		.aluin1(dut.aluin1),
		.aluin2(dut.aluin2), 
		.opselect(dut.opselect),
		.operation(dut.operation),
		.shift_number(dut.shift_number),
		.enable_shift(dut.enable_shift), 
		.enable_arith(dut.enable_arith)		
		);
	
	Execute_test test(top_io, DUT_probe);   	
	
	Top dut(					
		.clock	(top_io.clock), 
		.enable_ex	(top_io.enable_ex),
		.reset	(top_io.reset), 
		.src1(top_io.src1),   
		.src2(top_io.src2),
	   	.imm	(top_io.imm),
		.control_in	(top_io.control_in),
		.mem_data_read_in	(top_io.mem_data_read_in), 
		.mem_data_write_out	(top_io.mem_data_write_out),
		.mem_write_en	(top_io.mem_write_en),
		.aluout	(top_io.aluout),
		.carry	(top_io.carry)
	);
	
	
	initial 
	begin
		SysClock = 0;
		forever 
		begin
			#(simulation_cycle/2)
			SysClock = ~SysClock;
		end
	end
endmodule
