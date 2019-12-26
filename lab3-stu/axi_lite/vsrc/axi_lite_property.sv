`timescale 1ns/1ps

module axi_lite_property (
    input logic            init,
    input logic            error,
    input logic            txn_done,
    input logic            clk,
    input logic            reset_n,
    input logic    [5:0]   awaddr,
    input logic    [2:0]   awprot,
    input logic            awvalid,
    input logic            awready,
    input logic    [31:0]  wdata,
    input logic    [3:0]   wstrb,
    input logic            wvalid
    input logic            wready,
    input logic    [1:0]   bresp,
    input logic            bvalid,
    input logic            bready,
    input logic    [5:0]   araddr,
    input logic    [2:0]   arprot,
    input logic            arvalid,
    input logic            arready,
    input logic    [31:0]  rdata,
    input logic    [1:0]   rresp,
    input logic            rvalid,
    input logic            rready);

endmodule