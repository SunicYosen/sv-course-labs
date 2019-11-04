module alu_tb();

alu_dut alu_dut1(.clock(clock),
                 .reset_n(reset_n),
                 .aluin1(alu_input1),
                 .aluin2(alu_input2),
                 .operation(operation),
                 .opselect(opselect),
                 .enable_arith(enable_arithmetic),
                 .enable_shift(enable_shift),
                 .aluout(alu_out));
                 
endmodule