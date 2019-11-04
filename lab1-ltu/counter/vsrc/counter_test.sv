
// Things to note from this Counter example :
// 1) 3 Initial blocks
// 2) Component Instantiation
// 3) Port mapping
// 4) $display, $finish, $timeformat, $monitor, ... Default System Functions
// 5) See the structure: Drive the values, Expect a value , Verify it with a monitor, Display for Debugging on the screen
// 6) task subroutine used here  
// 7) timescale used 
// 8) logic SV data type used.
// 9) Concatenation Operator {,}
//////////////////////////////////////////
//////////////////////////////////////////


`timescale 1ns / 100ps


module counter_test;

    reg [2047:0] vcdplusfile = 0;
    logic reset_tb, enable_tb;
    logic [9:0] count_tb;
    bit clk;

    // Implicit port connections 
    counter count_inst (clk, 
                        reset_tb,
                        enable_tb,
                        count_tb);

    // Generates 3000 Clocks
    initial 
    begin
      clk = 0;
      for (int i =0; i<2000; i++) 
        clk = #1 ~clk;
    end

    // Monitor Results
    initial
    begin
        $timeformat ( -9, 1, " ns", 9 );
        $monitor ( "time=%t clk=%0b reset_tb=%0b enable_tb=%0b  count_tb=%d", $time, clk, reset_tb, enable_tb , count_tb );
    end

    // Verify Results 
    /// task executes all the lines inside as if it will execute it from the calling place 
    task expect_value( input [3:0] expected);
        if ( count_tb !== expected ) begin
            $display ( " ********** COUNTER TEST FAILED ************* " );
            $display ( " Count value is %d but it should be %d ", count_tb, expected );
            $finish ;
        end
    endtask

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

        @ ( negedge clk )
        { reset_tb, enable_tb } = 2'b0_0; @(negedge clk) expect_value ( 0 );
        { reset_tb, enable_tb } = 2'b1_1; @(negedge clk) expect_value ( 1 );
        { reset_tb, enable_tb } = 2'b1_0; @(negedge clk) expect_value ( 0 );
        { reset_tb, enable_tb } = 2'b1_1; @(negedge clk) expect_value ( 1 );
        $display ( " ********** COUNTER TEST PASSED ************* " );
        $finish;
    end
endmodule

