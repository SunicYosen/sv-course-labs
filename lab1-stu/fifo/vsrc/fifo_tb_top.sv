/* fifo_tb_top.sv
 * test bench top of fifo
 * Sunic
 * 2019.11.03
 */

module fifo_tb();

    parameter simulation_cycle = 10;
    reg [2047:0] vcdplusfile = 0;

    reg clock;

    fifo_tb_io fifo_tb_top_io(clock);
    fifo_test  fifo_tb_top_test(fifo_tb_top_io);

    fifo_dut fifo_dut1(.clock    (fifo_tb_top_io.clock),
                       .reset_n  (fifo_tb_top_io.reset_n),
                       .valid_in (fifo_tb_top_io.valid_in),
                       .size     (fifo_tb_top_io.size),
                       .data_in  (fifo_tb_top_io.data_in),
                       .valid_out(fifo_tb_top_io.valid_out),
                       .ready_in (fifo_tb_top_io.ready_in),
                       .data_out (fifo_tb_top_io.data_out));

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
        clock = 0;

        forever 
        begin
            #(simulation_cycle/2);
            clock = ~clock;
        end
    end

endmodule
