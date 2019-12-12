`timescale 1ns/1ps

module axi_protocol_property (
    input logic    init,
    input logic    error,txn_done,
    input logic    clk,reset_n,
    input logic    [5:0]   awaddr,
    input logic    [2:0]   awprot,
    input logic    awvalid,awready,
    input logic    [31:0]  wdata,
    input logic    [3:0]   wstrb,
    input logic    wvalid,wready,
    input logic    [1:0]   bresp,
    input logic    bvalid,bready,
    input logic    [5:0]   araddr,
    input logic    [2:0]   arprot,
    input logic    arvalid,arready,
    input logic    [31:0]  rdata,
    input logic    [1:0]   rresp,
    input logic    rvalid,rready
    
);

endmodule