`timescale 1ns / 1ps
`include "define.v"

//******************************************************************

// Author:
// Date: 2019/10/26
// Version: v1.0
// Module Name: alu_dut
// Project Name: SystemVerilog Lab1

//*******************************************************************
module alu_dut(clock,
               reset_n,
               aluin1,
               aluin2,
               operation,
               opselect,
               enable_arith,
               enable_shift,
               aluout);

input            clock;
input            reset_n;       //reset_n lower is reset.
input            enable_arith;
input            enable_shift;
input   [31:0]   aluin1;
input   [31:0]   aluin2;
input   [2:0]    operation;
input   [2:0]    opselect;
output  [31:0]   aluout;

wire [31:0] alu_arithmetic_out;
wire [31:0] alu_shift_out;

reg alu_selection;

assign aluout = alu_selection ? alu_arithmetic_out : alu_shift_out;

alu_shift alu_shift_s(.clock(clock),
                      .reset_n(reset_n),
                      .enable(enable_shift),
                      .in_data(aluin1),
                      .shift(operation),
                      .shift_operation(opselect),
                      .alu_sht_out(alu_shift_out));

alu_arithmetic alu_arithmetic_s(.clock(clock),
                                .reset_n(reset_n),
                                .enable(enable_arith),
                                .alu_input1(aluin1),
                                .alu_input2(aluin2),
                                .alu_operation(operation),
                                .alu_op_select(opselect),
                                .alu_arithmetic_out(alu_arithmetic_out));

always @(posedge clock)
begin
    if (!reset_n)
        alu_selection <= 1'b0;
    else if(enable_arith)
        alu_selection <= 1'b1;
    else
        alu_selection <= 1'b0;
end

endmodule