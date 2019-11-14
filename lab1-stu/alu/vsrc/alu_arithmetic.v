/* ALU SHIFT
 * Sunic
 * 2019.10.31
 * Store the input first, so a cycle delay.
 */

`timescale 1ns / 1ps
`include "define.v"

module alu_arithmetic(input         clock,
                      input         reset_n,
                      input         enable,
                      input  [31:0] alu_input1,
                      input  [31:0] alu_input2,
                      input  [2:0]  alu_operation,
                      input  [2:0]  alu_op_select,
                      output [31:0] alu_arithmetic_out);

reg [31:0] alu_input1_reg;
reg [31:0] alu_input2_reg;
reg [2:0]  alu_operation_reg;

wire [31:0] alu_add;
wire [31:0] alu_half_add_temp;
wire [31:0] alu_half_add;
wire [31:0] alu_sub;
wire [31:0] alu_not;
wire [31:0] alu_and;
wire [31:0] alu_or;
wire [31:0] alu_xor;
wire [31:0] alu_lhg;

assign alu_add               =  alu_input1_reg  +  alu_input2_reg;           // ADD       000
assign alu_sub               =  alu_input1_reg  -  alu_input2_reg;           // SUB       010
assign alu_not               =                  ~ (alu_input2_reg);          // NOT       011
assign alu_and               = (alu_input1_reg) & (alu_input2_reg);          // AND       100
assign alu_or                = (alu_input1_reg) | (alu_input2_reg);          // OR        101
assign alu_xor               = (alu_input1_reg) ^ (alu_input2_reg);          // XOR       110
assign alu_half_add_temp     = alu_input1_reg[15:0] + alu_input2_reg[15:0];  // HALF ADD
assign alu_half_add          = {16(alu_half_add_temp[15]),alu_half_add_temp};// HALF ADD  001
assign alu_lhg               = {alu_input2_reg[15:0], 16'h0000};             // LHG       111

assign alu_arithmetic_out    =  (alu_operation_reg[2]) ? \
                               ((alu_operation_reg[1]) ? \
                               ((alu_operation_reg[0]) ? alu_lhg      : alu_xor)  : \  // [11x]
                               ((alu_operation_reg[0]) ? alu_or       : alu_and)) : \  // [10x]
                               ((alu_operation_reg[1]) ? \     
                               ((alu_operation_reg[0]) ? alu_not      : alu_sub)  : \  // [01x]
                               ((alu_operation_reg[0]) ? alu_half_add : alu_add))      // [00x]

always @(posedge clock)
begin
    if(!reset_n)
        alu_input1_reg <= 32'h0000_0000;
    else if(enable & (alu_op_select == ARITH_LOGIC))
        alu_input1_reg <= alu_input1;
    else 
        alu_input1_reg <= alu_input1_reg;
end

always @(posedge clock)
begin
    if(!reset_n)
        alu_input2_reg <= 32'h0000_0000;
    else if(enable & (alu_op_select == ARITH_LOGIC))
        alu_input2_reg <= alu_input2;
    else
        alu_input2_reg <= alu_input2_reg;
end

always @(posedge clock)
begin
    if(!reset_n)
        alu_operation_reg <= 3'b000;
    else if(enable & (alu_op_select == ARITH_LOGIC))
        alu_operation_reg <= alu_operation;
    else
        alu_operation_reg <= alu_operation_reg;
end

endmodule