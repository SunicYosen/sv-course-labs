`timescale 1ns/1ns

module memory (clock, rd_wr, addr ,data_in ,data_out );
    // Port declarations
    input logic clock, rd_wr; 
    input logic [3:0] addr;
    input logic [7:0] data_in ;
    output logic [7:0] data_out;

    // Memory declaration as Two Dimensional array 
    logic [7:0] mem [0:15] ;

    always @(posedge clock)

    // Read the Value stored in the memory
    if (rd_wr == 1'b0)
        data_out <= mem[addr];
    
    // Write the Value in data_in into the memory
    else if (rd_wr == 1'b1)
        #1 mem[addr] <= data_in;
        
endmodule
