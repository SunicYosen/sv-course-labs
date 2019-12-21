/* fifo.v
 * fifo module
 * Sunic
 * 2019.12.13
 */

`timescale 1ns / 1ps

module fifo (clock,       // clock
             reset_n,     // reset low level
             w_en,        // input valid
             r_en,        // output enable
             size,        // input size 00:1byte; 01:2bytes; 10:4bytes; 11:8bytes
             data_in,     // input data
             valid_out,   // output valid
             data_out,    // output data
             empty,       // empty status
             full,        // full status
             overflow);   // overflow

parameter FIFO_DATA_WIDTH = 8; 
parameter FIFO_ADDR_WIDTH = 5; 
parameter FIFO_DP         = 2 << FIFO_ADDR_WIDTH; // Define FIFO Deepth
// parameter READ_MOST       = 4;  // Read  no more than READ_MOST  byte(s) at one time
// parameter WRITE_MOST      = 8;  // Write no more than WRITE_MOST byte(s) at one time

input           clock;
input           reset_n;
input           w_en;      // Reset_n valid
input           r_en;
input  [1:0]    size;
input  [63:0]   data_in;

output reg         valid_out;
output             full;
output             empty;
output             overflow;
output reg [31:0]  data_out;

reg    [FIFO_DATA_WIDTH-1:0]    fifo_mem    [0: FIFO_DP-1];  //FIFO Memory
reg    [FIFO_ADDR_WIDTH-1:0]    write_addr;
reg    [FIFO_ADDR_WIDTH-1:0]    read_addr;

wire   [7:0]    data_remain;
wire   [3:0]    data_in_size;

wire            valid_out_temp;
wire            ready_in;

assign full           = !ready_in;
assign empty          = (data_remain == 0);                         // no delay
assign overflow       = (full && w_en) | (empty && r_en);           // overflow
assign data_remain    = (write_addr > read_addr) ? (write_addr - read_addr) :
                                                   (read_addr  - write_addr);

assign ready_in       = (data_remain[FIFO_ADDR_WIDTH]       != 1'b1) &
                       ((data_remain[FIFO_ADDR_WIDTH-1: 3]) != {(FIFO_ADDR_WIDTH-3){1'b1}});    // no delay
// 
assign valid_out_temp = (r_en & (data_remain >= 4)); // no delay

assign data_in_size   = (4'b0001 << size);

always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        write_addr <= 8'h00;
    else if(ready_in & w_en)
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

//write Input 0 Byte
always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        fifo_mem[write_addr] <= 8'h00;
    else if(ready_in & w_en)
        fifo_mem[write_addr] <= data_in[7:0];
    else
        fifo_mem[write_addr] <= fifo_mem[write_addr];
end

//write Input 1 Byte
always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        fifo_mem[write_addr+1] <= 8'h00;
    else if(ready_in & w_en & (size[0] | size[1]))
        fifo_mem[write_addr+1] <= data_in[15:8];
    else
        fifo_mem[write_addr+1] <= fifo_mem[write_addr+1];
end

//write Input 3-2 Byte
always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        {fifo_mem[write_addr+3], fifo_mem[write_addr+2]} <= 16'h0000;

    else if(ready_in & w_en & (size[1]))
        {fifo_mem[write_addr+3], fifo_mem[write_addr+2]} <= data_in[31:16];

    else
        {fifo_mem[write_addr+3], fifo_mem[write_addr+2]} <= 
        {fifo_mem[write_addr+3], fifo_mem[write_addr+2]};
end

//write Input 7-4 byte
always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]} = 32'b0000_0000;

    else if(ready_in & w_en & (size[1] & size[0]))
        {fifo_mem[write_addr+7],fifo_mem[write_addr+6], 
         fifo_mem[write_addr+5],fifo_mem[write_addr+4]} = data_in[63:32];

    else
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]} = 
        {fifo_mem[write_addr+4],fifo_mem[write_addr+5], 
         fifo_mem[write_addr+6],fifo_mem[write_addr+7]};
end

// Valid out outputs
always @(posedge clock or negedge reset_n)
begin
    if(!reset_n)
        valid_out <= 1'b0;
    else
        valid_out <= valid_out_temp;
end


// Data out
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
