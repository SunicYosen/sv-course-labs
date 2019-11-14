/* ALU SHIFT
 * Sunic
 * 2019.10.31
 * Store the input first, so a cycle delay.
 */ 

`timescale 1ns / 1ps
`include "define.v"

module alu_shift(input         clock,
                 input         reset_n,
                 input         enable,
                 input  [31:0] in_data,
                 input  [2:0]  shift,
                 input  [2:0]  shift_operation,
                 output [31:0] alu_shift_out)

reg [31:0] in_data_reg;
reg [2:0]  shift_reg;
reg [2:0]  shift_operation_reg;

wire [31:0] shift_left_logic;
wire [31:0] shift_left_arithmetic;
wire [31:0] shift_right_logic;
wire [31:0] shift_right_arithmetic;

assign shift_left                = in_data_reg <<  shift_reg;
// assign shift_left_logic       = in_data_reg <<  shift_reg;
// assign shift_left_logic       = in_data_reg <<  shift_reg;
// assign shift_left_arithmetic  = in_data_reg <<  shift_reg; // Same with shift_left
assign shift_right_logic         = in_data_reg >>  shift_reg;
assign shift_right_arithmetic    = in_data_reg >>> shift_reg;
// assign shift_right_arithmetic = {in_data_reg[31],in_data_reg[30:0] >> shift_reg}; // TODO

assign alu_shift_out = (!shift_operation_reg[1]) ? shift_left : 
                    (( shift_operation_reg[0]) ? shift_right_arithmetic : shift_right_logic);

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

endmodule