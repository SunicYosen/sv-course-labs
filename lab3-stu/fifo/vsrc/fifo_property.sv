`define CHECK_RESET;
`define CHECK_EMPTY;
`define CHECK_FULL;
`define CHECK_OVERFLOW;
`define CHECK_FULL_WRITE_STABLE_WRADDR;
`define CHECK5;
`define CHECK6;
`define CHECK7;
`define rd_addr  fifo_tb.fifo_func.fifo_rd_addr
`define wr_addr  fifo_tb.fifo_func.fifo_wr_addr

module fifo_property(input logic        clock,
                     input logic        reset_n,
                     input logic        fifo_write,
                     input logic [63:0] fifo_data_in,
                     input logic        fifo_read,
                     input logic [1:0]  size,
                     input logic [31:0] fifo_data_out,
                     input logic        fifo_empty,
                     input logic        fifo_full,
                     input logic        fifo_overflow,
                     input logic        fifo_valid_out);

  parameter FIFO_DATA_WIDTH = 8; 
  parameter FIFO_ADDR_WIDTH = 8; 
  parameter FIFO_DP         = 2 << FIFO_ADDR_WIDTH ;

  `ifdef CHECK_RESET
    property check_reset;
      @(posedge clock)(!reset_n |-> ((`rd_addr   == 0) && 
                                     (`wr_addr   == 0) && 
                                     (fifo_empty == 1) && 
                                     (fifo_full  == 0)));
    endproperty

    check_reset_p: assert property (check_reset) 
                   else   $display($time, "ns : FAIL::check_reset!\n");
  `endif  // check reset

  `ifdef CHECK_EMPTY
    property check_empty;
      @(posedge clock) disable iff(!reset_n) (fifo_empty == 1);
    endproperty
    check_empty_p: assert property (check_empty) 
                   else $display($time, "ns : FAIL::check_empty condition!\n");
  `endif // check empty

  `ifdef CHECK_FULL
    property check_full;
      @(posedge clock) disable iff(!reset_n) (fifo_full);
    endproperty
    check_full_p: assert property (check_full)
                  else $display($time, "ns : FAIL::check_full condition!\n");
  `endif // check full

  `ifdef CHECK_OVERFLOW
    property check_overflow;
      @(posedge clock) disable iff(!reset_n) (fifo_overflow);
    endproperty
    check_overflow_p: assert property (check_overflow)
                      else $display($time, "ns : FAIL::check_overflow condition!\n");
  `endif // check overflow

endmodule
