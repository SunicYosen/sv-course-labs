`timescale 1 ns / 1 ps

module axi_lite_tb();
reg [2047:0] vcdplusfile     = 0;
reg [2047:0] fsdbfile        = 0;

logic   init;
wire    error;
wire    txn_done;
logic   clk;
logic   reset_n;
wire    [5:0]   awaddr;
wire    [2:0]   awprot;
wire    awvalid;
wire    awready;
wire    [31:0]  wdata;
wire    [3:0]   wstrb;
wire    wvalid;
wire    wready;
wire    [1:0]   bresp;
wire    bvalid;
wire    bready;
wire    [5:0]   araddr;
wire    [2:0]   arprot;
wire    arvalid;
wire    arready;
wire    [31:0]  rdata;
wire    [1:0]   rresp;
wire    rvalid;
wire    rready;

always @(posedge clk)
  $display($stime,,,"clk=%b reset_n=%b awaddr=%b awprot=%h awvalid=%b awready=%b wdata=%b wstrb=%b  wvalid=%b wready=%b bresp=%b bvalid=%h bready=%b araddr=%b arprot=%b arvalid=%b  arready=%b rdata=%b rresp=%b rvalid=%h rready=%b ", 
     clk, reset_n, awaddr, awprot, awvalid, awready, wdata, wstrb,wvalid,wready,bresp,bvalid,bready,araddr,arprot,arvalid,arready,rdata,rresp,rvalid,rready);


axi_lite_property axi_lite_property_instance(.init(init),
                                             .error(error),
                                             .txn_done(txn_done),
                                             .clk(clk),
                                             .reset_n(reset_n),
                                             .awaddr(awaddr),
                                             .awprot(awprot),
                                             .awvalid(awvalid),
                                             .awready(awready),
                                             .wdata(wdata),
                                             .wstrb(wstrb),
                                             .wvalid(wvalid),
                                             .wready(wready),
                                             .bresp(bresp),
                                             .bvalid(bvalid),
                                             .bready(bready),
                                             .araddr(araddr),
                                             .arprot(arprot),
                                             .arvalid(arvalid),
                                             .arready(arready),
                                             .rdata(rdata),
                                             .rresp(rresp),
                                             .rvalid(rvalid),
                                             .rready(rready));
                                             
axi_lite_master  axi_lite_master_instance(.INIT_AXI_TXN(init),
                                          .ERROR(error),
                                          .TXN_DONE(txn_done),
                                          .M_AXI_ACLK(clk),
                                          .M_AXI_ARESETN(reset_n),
                                          .M_AXI_AWADDR(awaddr),
                                          .M_AXI_AWPROT(awprot),
                                          .M_AXI_AWVALID(awvalid),
                                          .M_AXI_AWREADY(awready),
                                          .M_AXI_WDATA(wdata),
                                          .M_AXI_WSTRB(wstrb),
                                          .M_AXI_WVALID(wvalid),
                                          .M_AXI_WREADY(wready),
                                          .M_AXI_BRESP(bresp),
                                          .M_AXI_BVALID(bvalid),
                                          .M_AXI_BREADY(bready),
                                          .M_AXI_ARADDR(araddr),
                                          .M_AXI_ARPROT(arprot),
                                          .M_AXI_ARVALID(arvalid),
                                          .M_AXI_ARREADY(arready),
                                          .M_AXI_RDATA(rdata),
                                          .M_AXI_RRESP(rresp),
                                          .M_AXI_RVALID(rvalid),
                                          .M_AXI_RREADY(rready));

axi_lite_slave  axi_lite_slave_instance(.S_AXI_ACLK(clk),
                                        .S_AXI_ARESETN(reset_n),
                                        .S_AXI_AWADDR(awaddr),
                                        .S_AXI_AWPROT(awprot),
                                        .S_AXI_AWVALID(awvalid),
                                        .S_AXI_AWREADY(awready),
                                        .S_AXI_WDATA(wdata),
                                        .S_AXI_WSTRB(wstrb),
                                        .S_AXI_WVALID(wvalid),
                                        .S_AXI_WREADY(wready),
                                        .S_AXI_BRESP(bresp),
                                        .S_AXI_BVALID(bvalid),
                                        .S_AXI_BREADY(bready),
                                        .S_AXI_ARADDR(araddr),
                                        .S_AXI_ARPROT(arprot),
                                        .S_AXI_ARVALID(arvalid),
                                        .S_AXI_ARREADY(arready),
                                        .S_AXI_RDATA(rdata),
                                        .S_AXI_RRESP(rresp),
                                        .S_AXI_RVALID(rvalid),
                                        .S_AXI_RREADY(rready));                                    

always #5 clk = ~clk;
initial 
begin
`ifdef VCS
        if ($value$plusargs("vcdplusfile=%s", vcdplusfile))
        begin
            $vcdplusfile(vcdplusfile);
            $vcdpluson(0);
            $vcdplusmemon(0);
        end
`else
            $fdisplay(stderr, "Error: +vcdplusfile is VCS-only; use +vcdfile instead or recompile with VCS=1");
            $fatal;
`endif
// FSDB
// if ($value$plusargs("fsdbfile=%s", fsdbfile))
//   begin
//     $fsdbDumpfile(fsdbfile);
//     $fsdbDumpvars(0);
//     $fsdbDumpon(0);
//   end
  clk     <= 0;
  init    <= 0;
  reset_n <= 0;
  #30
  reset_n <= 1;
  init    <= 1;
end

endmodule