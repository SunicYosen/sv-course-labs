//

//program Execute_test(Execute_io.TB Execute);

program fifo_test(fifo_tb_io.TB fifo_tb_io_test);

    parameter run_n_times = 10;


    initial begin
        reset_n();
        repeat(run_n_times) 
            begin
                $display($time, "Sending Another Packet");
                write();
                read();
                random_rw();
            end
    	repeat(5) @(fifo_tb_io_test.clocking_block);
    end

    task reset_n();
		$display($time, "RESET BEGIN...");		
		fifo_tb_io_test.reset_n <= 1'b0;
		repeat(5) @(fifo_tb_io_test.clocking_block);
		fifo_tb_io_test.reset_n <= 1'b1;
		$display($time, "RESET END");
	endtask

    task write();
        $display($time, "Task write Begin...");
        $display($time, "Task write END!");
    endtask

    task read();
        $display($time, "Task read Begin...");
        $display($time, "Task read END!");
    endtask

    task random_rw();
        $display($time, "Task random_rw Begin...");
        $display($time, "Task random_rw END!");
    endtask

    task display();  //Display the result of output
        $display($time, "ns:  Inputs:  ");
        $display($time, "ns:  Outputs: ");
    endtask

endprogram
