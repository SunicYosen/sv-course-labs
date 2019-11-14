`timescale 1ns / 1ps
`include   "fifo.v"

//******************************************************************

// Author:
// Date: 2019/10/26
// Version: v1.0
// Module Name: fifo-dut
// Project Name: SystemVerilog Lab1

//*******************************************************************


module fifo_dut(clock,
                reset_n,
                valid_in,
                size,
                data_in,
                valid_out,
                ready_in,
                data_out);

    input           clock;
    input           reset_n;
    input           valid_in; //reset_n valid
    input [1:0]     size;
    input [63:0]    data_in;
    output          valid_out,ready_in;   
    output[31:0]    data_out;

//**************Please add your code below ****************************

fifo #(.FIFO_SIZE(256)) 
     fifo1(.clock(clock),
           .reset_n(reset_n),
           .valid_in(valid_in),
           .out_enable(1'b1),
           .size(size),
           .data_in(data_in),
           .valid_out(valid_out),
           .ready_in(ready_in),
           .data_out(data_out));

endmodule