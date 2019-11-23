timeunit 1ns;
timeprecision 1ns;

module mem_test ();
    reg [2047:0] vcdplusfile;
        
    bit clk;
    logic read_write; 
    logic [3:0] addr; 
    logic [7:0] data_in; // Write data to memory
    logic [7:0] data_out; // Read data from memory

    logic [7:0] temp; 

    // Generate clock 
    always clk = #5 ~clk;
    
    // write memory subroutine !!!
    task write_memory (input [3:0] waddr, input [4:0] wdata);
        @(negedge clk)
        read_write <= 1;
        addr <= waddr;
        data_in <= wdata;
        @(negedge clk) read_write <= 0;
    endtask

    // read memory subroutine !!! 
    task read_memory (input [3:0] raddr, output [7:0] rdata);
        @(negedge clk)
        read_write <= 0;
        addr <= raddr;
        @(negedge clk)
        rdata = data_out;
    endtask

    // Instantiating the memory component !!! 
    memory memory_inst (clk, read_write, addr ,data_in ,data_out);
    
    // Monitoring the  Results
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

        $timeformat ( -9, 0, " ns", 9);
	    // Make sure.. there is only one MONITOR statement ON at any given time.. else use $monitoron and $monitoroff pragmas
        // $monitor ( " Write Monitor time=%t  addr=%d  data_in=%d", $time,  addr , data_in);
        $monitor("Read  Monitor time=%t  addr=%d  data_out=%d", $time, addr, data_out);

        #1000;
        $finish;
    end

    initial
    begin: memtest
        $display(" ********* Memory Test begins with Feeding Data as 2 x Address ********** \n");
        for (int i = 0; i<=15; i++)
            write_memory (i, i*2);

        for (int i = 0; i<=15; i++)
            read_memory (i, temp);
            
        $finish;
    end
endmodule
