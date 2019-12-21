module fifo_tb;
reg [2047:0] vcdplusfile     = 0;
reg [2047:0] fsdbfile        = 0;

parameter    FIFO_DATA_WIDTH = 8; 
parameter    FIFO_ADDR_WIDTH = 5; 
parameter    FIFO_DP         = 2 << FIFO_ADDR_WIDTH ;

logic           clock;
logic           rst_n;
logic           r_en;
logic           w_en;
logic		[63:0]	in_data;
logic		[1:0]	  size;
wire	  [31:0]	out_data;
wire			      full;
wire            empty;
wire            overflow;
wire			      valid_out;

integer i;

fifo #(FIFO_DATA_WIDTH, FIFO_ADDR_WIDTH, FIFO_DP) 
     fifo_func(.clock(clock),
               .reset_n(rst_n),
               .w_en(w_en),
               .r_en(r_en),
               .size(size),
               .data_in(in_data),
               .valid_out(valid_out),
               .data_out(out_data),
               .empty(empty),
               .full(full),
               .overflow(overflow));

bind fifo_func fifo_property #(FIFO_DATA_WIDTH, FIFO_ADDR_WIDTH, FIFO_DP) 
               fifo_bind(.clock(clock),
                         .reset_n(reset_n),
                         .fifo_write(w_en),
                         .fifo_data_in(data_in),
                         .fifo_read(r_en),
						             .size(size),
                         .fifo_data_out(data_out),
                         .fifo_empty(empty),
                         .fifo_full(full),
                         .fifo_overflow(overflow),
                         .fifo_valid_out(valid_out));

initial // Test signals status after reset(full empty overflow)
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

  // Reset
  fifo_reset;
  check_status(4'b1000, "Reset");    // {empty, full, overflow, valid_out}
  repeat(5) @(negedge clock);
  
  // Causing full
  write_byte(FIFO_DP-8);
  repeat(5) @(negedge clock);
  check_status(4'b0100, "Full");     // {empty, full, overflow, valid_out}

  read(FIFO_DP-8);
  check_status(4'b1010, "Empty");

  repeat(5) @(negedge clock);
  rst_n = 0;
  r_en  = 0;
  w_en  = 0;

  repeat(5) @(negedge clock);
  check_status(4'b1000, "Reset");  // {empty, full, overflow, valid_out}
  rst_n=1;

  // Causing overflow
  write(80);
  check_status(4'b0110, "Overflow"); // {empty, full, overflow, valid_out}
  @(negedge clock) w_en = 1'b0;

  repeat(5) @(negedge clock);
  rst_n=0;

  repeat(5) @(negedge clock);
  check_status(4'b1000, "Reset");   // {empty, full, overflow, valid_out}
  rst_n=1;

  // Cause valid_out=0;
  read_less_4_byte;  // Cause and Check.

  @(negedge clock) fifo_reset;
  repeat(5) @(negedge clock);

  begin
    $display("********************************************************************************\n");
    $display($time, "ns : Done, without error!\n");
    $display("********************************************************************************\n");
    $finish;
  end

end  // End initial

always #1 clock=~clock;

task fifo_reset;
  $display($time, "ns : Reset Start ... ");
  in_data = 0;
  r_en    = 0;
  w_en    = 0;
  clock   = 1;
  size    = 0;

  @ (negedge clock) rst_n = 0;

  repeat(5) @(negedge clock);
  rst_n = 1;

  $display($time, "ns : Reset END!\n");
endtask // End task fifo reset

// task check_reset;
//   if({empty, full, overflow, valid_out} != 4'b1000)
//     begin
//       $display("\nError at time %0t:",$time);
//       $display("After reset,status not asserted\n");
//       $display("empty = %b full = %b overflow = %b valid_out = %b\n",empty,full,overflow,valid_out);
//       $stop;
//     end
// 
//   else
//     begin
//       $display($time, "ns : Initial Status right! empty = %b full = %b overflow = %b valid_out = %b\n", empty, full, overflow, valid_out);
//     end
// endtask // End check reset

task write_byte(int num);
  $display($time, "ns : Write Full Start ... ");

  for (i=1; i <= num; i=i+1)
    begin
      @(negedge clock);
      w_en    = 1; 
      r_en    = 0;
      in_data = $urandom_range(0, 1000000000);
      size    = 0;
      $display($time, "ns : Storing %3d: w_en=%1d r_en=%1d data_in=%8d  size=%2d", i , w_en, r_en, in_data, size);
    end
  
  @(negedge clock) w_en = 0; // disable write

  $display($time, "ns : Write Full END!\n");
endtask // End task write_byte

task write(int num);
  $display($time, "ns : Write Start ... ");
  for (i=1; i <= num; i=i+1)
    begin
      @(negedge clock) 
      w_en    = 1;
      r_en    = 0; 
      in_data = $urandom_range(0,1000000000); 
      size    = $urandom_range(0,3);
      $display($time, "ns : Storing %3d w_en=%1d r_en=%1d data_in=%8d  size=%2d", i, w_en, r_en, in_data, size);
    end
  $display($time, "ns : Write END!\n");
endtask // End task Write

task read(int num);
  $display($time, "ns : Read Start ... ");
  @(negedge clock);
  w_en    = 0;
  r_en    = 1;

  for (i=1; i <= num; i=i+1)
    begin
      @(negedge clock);
      $display($time, "ns : Read %3d w_en=%1b r_en=%1b valid_out=%b out_data=%8h", i, w_en, r_en, valid_out, out_data);
    end
  
  $display($time, "ns : Read END!\n");
endtask // End task read

task read_less_4_byte;
  $display($time, "ns : Read Valid Out Start ... ");
  @(negedge clock);
  w_en=1;
  r_en=1;

  for (i=1; i<=3; i=i+1)  // Write less than 4 byte for Read 
  fork
    begin
      @(negedge clock);
      in_data = i; 
      size    = 0;
    end

    begin   // Data less than 4-byte
      @(posedge clock);
      $display($time, " ns : Reading data %d, your data %d\n", i, out_data);

      if(valid_out != 0)
      begin
        $display("Error! valid_out should be zero!");
        $stop;
      end
    end
  join
  
  $display($time, "ns : Read Valid Out END!");
endtask // End task read valid out.

// messgae can be Empty/Full/Vverflow/Reset
task check_status(logic [3:0] co_status, string message="");
  if({empty, full, overflow, valid_out} != co_status)
    begin
      $display("\nError at time %0t for %s:",$time, message);
      $display("empty = %b full = %b overflow = %b\n", empty, full, overflow);
      $stop;
    end

  else
    begin
      $display($time, "ns : %s status right. empty = %b full = %b  overflow = %b\n",message, empty, full, overflow);
    end
endtask // End task check status

endmodule // End testbench_fifo_final module

