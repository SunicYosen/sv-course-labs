/* alu_tb.sv
 * test bench of alu
 * Sunic
 * 2019.11.14
 */

module alu_tb();

    parameter           simulation_cycle = 10;
    reg       [2047:0]  vcdplusfile      = 0;
    reg                 clock;

    alu_tb_io alu_tb_top_io(clock);
    alu_test  alu_tb_top_test(alu_tb_top_io);

    alu_dut alu_dut1(.clock       (alu_tb_top_io.clock),
                     .reset_n     (alu_tb_top_io.reset_n),
                     .aluin1      (alu_tb_top_io.alu_data_in_1),
                     .aluin2      (alu_tb_top_io.alu_data_in_2),
                     .operation   (alu_tb_top_io.operation),
                     .opselect    (alu_tb_top_io.opselect),
                     .enable_arith(alu_tb_top_io.enable_arithmetic_alu),
                     .enable_shift(alu_tb_top_io.enable_shift_alu),
                     .aluout      (alu_tb_top_io.aluout_data));

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
