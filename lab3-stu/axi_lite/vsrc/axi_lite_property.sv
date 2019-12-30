

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
input logic            wvalid,
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

// Write
// Check awvalid
property check_awvalid;  
    @(posedge clk) disable iff(!reset_n) $rose(awready) |-> awvalid ##1 $fell(awvalid);
endproperty

check_awvalid_p: assert property (check_awvalid)
                else  $display($time, "ns : FAIL::check_awvalid!\n");

// Check awready
property check_awready;  
    @(posedge clk) disable iff(!reset_n) (~awready && wvalid && awvalid) |-> ##1 awready ##1 ~awready;
endproperty

check_awready_p: assert property (check_awready)
                else  $display($time, "ns : FAIL::check_awready!\n");

// Check wvalid
property check_wvalid;  
    @(posedge clk) disable iff(!reset_n) (wready && wvalid) |-> ##1 $fell(wvalid);
endproperty

check_wvalid_p: assert property (check_wvalid)
                else  $display($time, "ns : FAIL::check_wvalid!\n");


// Check wready
property check_wready;  
    @(posedge clk) disable iff(!reset_n) $rose(wready) |-> ##1 $fell(wready);
endproperty

check_wready_p: assert property (check_wready)
                else  $display($time, "ns : FAIL::check_wready!\n");

// Check bresp 
property check_bresp;
    @(posedge clk) disable iff(!reset_n)  (awready && awvalid && wready && wvalid && ~bvalid) |-> (bresp==2'b00) ##1 (bresp==2'b00);
endproperty

check_bresp_p: assert property (check_bresp)
               else $display($time, "ns : FAIL::check_bresp!\n");

// Check bvalid
property check_bvalid;
    @(posedge clk) disable iff(!reset_n) (awready && awvalid && wready && wvalid && ~bvalid) |-> ##1 bvalid;
endproperty

check_bvalid_p: assert property (check_bvalid)
                else $display($time, "ns : FAIL::check_bvalid!\n");

// Check bvalid
property check_bvalid_n;
    @(posedge clk) disable iff(!reset_n) (bready && bvalid) |-> ##1 ~bvalid;
endproperty

check_bvalid_n_p: assert property (check_bvalid_n)
                else $display($time, "ns : FAIL::check_bvalid_n!\n");

// Check bready
property check_bready;
    @(posedge clk) disable iff(!reset_n)  (bvalid && ~bready) |-> ##1 bready;
endproperty

check_bready_p: assert property (check_bready)
                else $display($time, "ns : FAIL::check_bready!\n");


// Read
// Check arvalid
property check_arvalid;
    @(posedge clk) disable iff(!reset_n) $rose(arready) |-> arvalid ##1 $fell(arvalid);
endproperty

check_arvalid_p: assert property (check_arvalid)
                 else $display($time, "ns : FAIL::check_arvalid!\n");

// Check_arready
property check_arready;
    @(posedge clk) disable iff(!reset_n) (arvalid && ~arready) |-> ##1 arready;
endproperty

check_arready_p: assert property (check_arready)
                 else $display($time, "ns : FAIL::check_arready!\n");

// Check_rvalid
property check_rvalid;
    @(posedge clk) disable iff(!reset_n) (arvalid && arready && ~rvalid) |-> ##1 rvalid ##2 ~rvalid;
endproperty

check_rvalid_p: assert property (check_rvalid)
                 else $display($time, "ns : FAIL::check_rvalid!\n");

// Check_rready
property check_rready;
    @(posedge clk) disable iff(!reset_n) $fell(rvalid) |-> $fell(rready);
endproperty

check_rready_p: assert property (check_rready)
                 else $display($time, "ns : FAIL::check_rready!\n");

endmodule