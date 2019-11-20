/* ALU SHIFT
 * Sunic
 * 2019.10.31
 * Store the input first, so a cycle delay.
 */ 

`timescale 1ns / 1ps
// `include "define.v"

module alu_shift(input         clock,
                 input         reset_n,
                 input         enable,
                 input  [31:0] in_data,
                 input  [2:0]  shift,
                 input  [2:0]  shift_operation,
                 output [31:0] alu_shift_out);

reg [31:0] in_data_reg;
reg [2:0]  shift_reg;
reg [2:0]  shift_operation_reg;

wire [31:0] shift_left;
// wire [31:0] shift_left_logic;
// wire [31:0] shift_left_arithmetic;
wire [31:0] shift_right_logic;
wire [31:0] shift_right_arithmetic;
wire [31:0] shift_right_arithmetic_temp;

reg [31:0] alu_shift_out_last;

assign shift_left                  = in_data_reg <<  shift_reg;
// assign shift_left_logic         = in_data_reg <<  shift_reg;
// assign shift_left_logic         = in_data_reg <<  shift_reg;
// assign shift_left_arithmetic    = in_data_reg <<  shift_reg; // Same with shift_left
assign shift_right_logic           = in_data_reg >>  shift_reg;
// assign shift_right_arithmetic   = in_data_reg >>> shift_reg;
assign shift_right_arithmetic_temp = in_data_reg[30:0] >> shift_reg;
assign shift_right_arithmetic = shift_reg[2] ? (shift_reg[1] ? (shift_reg[0] ? {{8{in_data_reg[31]}}, shift_right_arithmetic_temp[23:0]}    // shift 111
                                                                             : {{7{in_data_reg[31]}}, shift_right_arithmetic_temp[24:0]})   // shift 110
                                                             : (shift_reg[0] ? {{6{in_data_reg[31]}}, shift_right_arithmetic_temp[25:0]}    // shift 101
                                                                             : {{5{in_data_reg[31]}}, shift_right_arithmetic_temp[26:0]}))  // shift 100
                                             : (shift_reg[1] ? (shift_reg[0] ? {{4{in_data_reg[31]}}, shift_right_arithmetic_temp[27:0]}    // shift 011
                                                                             : {{3{in_data_reg[31]}}, shift_right_arithmetic_temp[28:0]})   // shift 010
                                                             : (shift_reg[0] ? {{2{in_data_reg[31]}}, shift_right_arithmetic_temp[29:0]}    // shift 001
                                                                             : {{1{in_data_reg[31]}}, shift_right_arithmetic_temp[30:0]})); // shift 000

assign alu_shift_out = shift_operation_reg[2] ? alu_shift_out_last   // No Change
                                              : (!shift_operation_reg[1]) ? shift_left  // Shift Left
                                                                          : (shift_operation_reg[0] ? shift_right_arithmetic // Shift Right Archithmetic 
                                                                                                    : shift_right_logic);   // Shift Right Logic

always @(posedge clock)
begin
    if(!reset_n)
        in_data_reg <= 32'h0000_0000;
    else if(enable)
        in_data_reg <= in_data;
    else
        in_data_reg <= in_data_reg;
end

always @(posedge clock)
begin
    if(!reset_n)
        shift_reg <= 3'b000;
    else if(enable)
        shift_reg <= shift;
    else
        shift_reg <= shift_reg;
end

always @(posedge clock)
begin
    if(!reset_n)
        shift_operation_reg <= 3'b000;
    else if(enable)
        shift_operation_reg <= shift_operation;
    else
        shift_operation_reg <= shift_operation_reg;
end


always @(posedge clock)
begin
    if(!reset_n)
        alu_shift_out_last <= 31'h0000_0000;
    else 
        alu_shift_out_last <= alu_shift_out;
end

endmodule