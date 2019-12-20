module fifo_tb;
reg [2047:0] vcdplusfile     = 0;
reg [2047:0] fsdbfile        = 0;

parameter    FIFO_DATA_WIDTH = 8; 
parameter    FIFO_ADDR_WIDTH = 8; 
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

fifo #(FIFO_ADDR_WIDTH, FIFO_DATA_WIDTH, FIFO_DP) 
     fifo_func(.clock(clock),
               .reset_n(rst_n),
               .w_en(w_en),
               .data_in(in_data),
               .r_en(r_en),
               .size(size),
               .data_out(out_data),
               .empty(empty),
               .full(full),
               .overflow(overflow),
               .valid_out(valid_out));

bind fifo_func fifo_property #(FIFO_ADDR_WIDTH, FIFO_DATA_WIDTH, FIFO_DP) 
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
  if ($value$plusargs("fsdbfile=%s", fsdbfile))
  begin
    $fsdbDumpfile(fsdbfile);
    $fsdbDumpvars(0);
    $fsdbDumpon(0);
  end

  fifo_reset;
  check_reset;
  repeat(5) @(negedge clock);
  
  // Causing full
  write_full;

  @(negedge clock) w_en=0;
  repeat(50) @(negedge clock);
  check_full;
  
  repeat(50) @(negedge clock);
  rst_n=0;
  repeat(50) @(negedge clock);
  rst_n=1;

  // Causing overflow
  read_overflow(80);

  @(negedge clock) w_en=0;
  repeat(50) @(negedge clock);

  check_overflow(3'b011);

  repeat(10) @(negedge clock);
  rst_n=0;
  repeat(10) @(negedge clock);
  rst_n=1;

  // Cause valid_out=0;
  @(negedge clock) w_en=1;
  r_en=1;
  @(negedge clock);

  read_valid_out;  // Cause and Check.


  // Causing overflow
  read_overflow(34);

  @(negedge clock) w_en=0;
  repeat(10) @(negedge clock);

  check_overflow(3'b100);

  @(negedge clock) r_en=1;
  repeat(10) @(negedge clock);

  begin
    $display("********************\n Done, without error! \n********************\n");
    $stop;
  end

end  // End initial

always #1 clock=~clock;

task fifo_reset;
  $display($time, "ns : Reset Start ... ");
  in_data=0;
  r_en=0;
  w_en=0;
  clock=1;
  size = 0;
  @ (negedge clock);
  rst_n = 0;
  @ (negedge clock);
  repeat(5) @(negedge clock);
  rst_n = 1;
  $display($time, "ns : Reset END!\n");
endtask // End task fifo reset

task check_reset;
  if({empty, full, overflow, valid_out} != 4'b1000)
    begin
      $display("\nError at time %0t:",$time);
      $display("After reset,status not asserted\n");
      $display("empty = %b full = %b overflow = %b valid_out = %b\n",empty,full,overflow,valid_out);
      $stop;
    end

  else
    begin
      $display($time, "ns : Initial Status right! empty = %b full = %b overflow = %b valid_out = %b\n", empty, full, overflow, valid_out);
    end
endtask // End check reset

task write_full;
  $display($time, "ns : Write Full Start ... ");

  // Causing full
  for (i=1; i<33; i=i+1)
	begin
	  @(negedge clock) 
	  w_en=1; 
	  in_data=$urandom_range(0, 1000000);
	  size = 0;
	  $display($time, "ns : Storing %3d: w_en=%1d r_en=%1d data_in=%8d  size=%2d", i , w_en, r_en, in_data, size);
	end

  $display($time, "ns : Write Full END!\n");
endtask // End task write

task check_full;
  if({empty,full,overflow}!=3'b010)
    begin
      $display("\nError at time %0t:",$time);
      $display("Half_full\n");
      $display("empty = %b full = %b overflow = %b\n",empty,full,overflow);
      $stop;
    end

  else
    begin
      $display($time, "ns : Half_full status right! empty = %b full = %b  overflow = %b\n", empty, full, overflow);
    end
endtask // End check write

task read_overflow(int num);
  $display($time, "ns : Read Overflow Start ... ");
  for (i=1; i<num; i=i+1)
    begin
      @(negedge clock) 
      w_en    = 1;
      r_en    = 0; 
      in_data = $urandom_range(0,1000000); 
      size    = $urandom_range(0,3);
      $display($time, "ns : Storing %3d w_en=%1d r_en=%1d data_in=%8d  size=%2d", i, w_en, r_en, in_data, size);
    end
  $display($time, "ns : Read Overflow END!\n");
endtask // End task read overflow.

task check_overflow(logic [2:0] co_status);
  if({empty,full,overflow} != co_status)
    begin
      $display("\nError at time %0t:",$time);
      $display("Overflow\n");
      $display("empty = %b full = %b overflow = %b\n", empty, full, overflow);
      $stop;
    end

  else
    begin
      $display($time, "ns : Overflow status right. empty = %b full = %b  overflow = %b\n", empty, full, overflow);
    end
endtask // End task check overflow

task read_valid_out;
  $display($time, "ns : Read Valid Out Start ... ");
  for (i=1;i<4;i=i+1)
  fork
    begin
      @(negedge clock) in_data=i; size = 0;
    end

    begin
      @(posedge clock);
      $display("reading data %d, your data %d\n",i,out_data);
      
      if(valid_out!=0)
      begin
        $display("error! valid_out should be zero!");
        $stop;
      end
    end
  join
  $display($time, "ns : Read Valid Out END!");
endtask // End task read valid out.

endmodule // End testbench_fifo_final module

