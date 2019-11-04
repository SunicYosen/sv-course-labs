// without output 

`timescale 1ns / 1ps

`define FIFO_SIZE = 256


module fifo (clock,       // clock
             reset_n,     // reset low level
             valid_in,    // input valid
             out_enable,  // output enable
             size,        // input size 00:1byte; 01:2bytes; 10:4bytes; 11:8bytes
             data_in,     // input data
             valid_out,   // output valid
             ready_in,    // input ready
             data_out);   // output data

parameter FIFO_SIZE  = 256;// Define FIFO Deepth 1-byte * 256
parameter READ_MOST  = 4;  // Read  no more than READ_MOST  byte(s) at one time
parameter WRITE_MOST = 8;  // Write no more than WRITE_MOST byte(s) at one time

input           clock;
input           reset_n;
input           valid_in;  // Reset_n valid
input           out_enable;
input  [1:0]    size;
input  [63:0]   data_in;

output reg         valid_out;
output             ready_in;
output reg [31:0]  data_out;

reg    [7:0]    fifo_mem    [0: FIFO_SIZE-1];
reg    [7:0]    write_addr;
reg    [7:0]    read_addr;

wire   [7:0]    data_remain;
wire   [3:0]    data_in_size;

wire            valid_out_temp;

assign data_remain    = (write_addr > read_addr) ? (write_addr - read_addr) :
                                                   (read_addr  - write_addr);

assign ready_in       = (data_remain <= (FIFO_SIZE-WRITE_MOST));    // no delay
// 
assign valid_out_temp = (out_enable & (data_remain >= READ_MOST)); // no delay

assign data_in_size   = (4'b0001 << size);

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        write_addr <= 8'h00;
    else if(ready_in & valid_in)
        write_addr <= write_addr + data_in_size;
    else
        write_addr <= write_addr;
end

always @(posedge clock  or negedge reset_n)
begin
    if(!reset_n)
        read_addr <= 8'h00;
    else if(valid_out_temp)
        read_addr <= read_addr + 3'b100;
    else
        read_addr <= read_addr;
end

// always @(posedge clock or negedge reset_n)
// begin
//     if(!reset_n)
//         data_in_size       <= 4'b0000;
//     else if()
//         data_in_size       <= (4'b0001 << size);
//     else 
//         data_in_size       <= data_in_size; 
// end

// always @(posedge clock or negedge reset_n)
// begin
//     if(!reset_n)
//         data_remain  <= 8'h00;
//     else if(write_addr >= read_addr)
//         data_remain  <= write_addr - read_addr;
//     else if(write_addr < read_addr)
//         data_remain  <= read_addr  - write_addr;
//     else
//         data_remain  <= data_remain;
// end

// Write a clock delay
always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        fifo_mem[write_addr] <= 8'h00;
    else if(ready_in & valid_in)
        fifo_mem[write_addr] <= data_in[7:0];
    else
        fifo_mem[write_addr] <= fifo_mem[write_addr];
end

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        fifo_mem[write_addr+1] <= 8'h00;
    else if(ready_in & valid_in & (size[0] | size[1]))
        fifo_mem[write_addr+1] <= data_in[15:8];
    else
        fifo_mem[write_addr+1] <= fifo_mem[write_addr+1];
end

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        {fifo_mem[write_addr+2], fifo_mem[write_addr+3]} <= 16'h0000;

    else if(ready_in & valid_in & (size[1]))
        {fifo_mem[write_addr+2], fifo_mem[write_addr+3]} <= data_in[31:16];

    else
        {fifo_mem[write_addr+2], fifo_mem[write_addr+3]} <= 
        {fifo_mem[write_addr+2], fifo_mem[write_addr+3]};
end

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]} = 32'b0000_0000;

    else if(ready_in & valid_in & (size[1] & size[0]))
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]} = data_in[63:32];

    else
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]} = 
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]};
end

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        valid_out <= 1'b0;
    else
        valid_out <= valid_out_temp;
end

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        data_out <= 32'h0000_0000;
    else if(valid_out_temp)
        data_out <= {fifo_mem[read_addr+3], 
                     fifo_mem[read_addr+2], 
                     fifo_mem[read_addr+1], 
                     fifo_mem[read_addr]};
    else
        data_out <= data_out;
end

endmodule
