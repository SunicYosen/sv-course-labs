//

program alu_test(alu_tb_io.TB alu_tb_io_test);

    parameter reg_wd            = 32;
    parameter OPERATION_WIDTH   = 3;
    parameter OPSELECT_WIDTH    = 3;
    parameter run_n_times       = 10;
    int       run_n_times_count = 0;
    integer   seed              = 0;

    reg [7:0]               run_count;

    reg	[reg_wd-1:0] 	       payload_aluin1[$];
	reg	[reg_wd-1:0] 	       payload_aluin2[$];
    reg [OPERATION_WIDTH-1:0]  payload_operation[$];
    reg [OPSELECT_WIDTH-1:0]   payload_opselect[$];
    
    reg	[reg_wd-1:0] 	       payload_aluin1_display;
	reg	[reg_wd-1:0] 	       payload_aluin2_display;
    reg [OPERATION_WIDTH-1:0]  operation_display;
    reg [OPSELECT_WIDTH-1:0]   opselect_display;
    reg                        enable_arithmetic_alu_display;
    reg                        enable_shift_alu_display;

    initial begin
        reset_n();
        $display($time, "ns:  Function Testing ...");
        repeat(run_n_times)
            begin
                seed = run_n_times_count;
                $display($time, "ns:  Function Testing ... %2d/%2d",run_n_times_count, run_n_times);
                gen();
                test_alu();
                run_n_times_count ++;
            end

        repeat(5) @(alu_tb_io_test.clocking_block);
    end

    task  reset_n();
        $display($time, "ns:  RESET BEGIN...");
        alu_tb_io_test.reset_n <= 1'b0;
        repeat(5) @(alu_tb_io_test.clocking_block);
        alu_tb_io_test.reset_n <= 1'b1;
        $display($time, "ns:  RESET END.");
        $display($time, "ns:  --------------------------------------------------------.");
    endtask //

    
	task gen();
		//generate an arbitrary number of payloads
        $display($time, "ns:  Created Payload Packet");
		repeat($urandom_range(80,100))
		begin
			payload_aluin1.push_back($random(seed));
			payload_aluin2.push_back($random(seed));
            payload_operation.push_back($random(seed));
            payload_opselect.push_back($random(seed));
		end
	endtask

    task test_alu();
        run_count  = 0;
        while (payload_aluin1.size() !=0)
        begin
            payload_aluin1_display <= payload_aluin1.pop_front();
            payload_aluin2_display <= payload_aluin2.pop_front();

            if(run_count <= 8'd30)
            begin
                // $display($time, "Test Arithmetic ALU BEGIN ...");
                enable_arithmetic_alu_display                       <= 1'b1;
                enable_shift_alu_display                            <= 1'b0;
                operation_display                                   <= run_count[2:0];
                opselect_display                                    <= 3'b001;

                alu_tb_io_test.clocking_block.enable_arithmetic_alu <= enable_arithmetic_alu_display;
                alu_tb_io_test.clocking_block.enable_shift_alu      <= enable_shift_alu_display;
                alu_tb_io_test.clocking_block.alu_data_in_1     	<= payload_aluin1_display;
                alu_tb_io_test.clocking_block.alu_data_in_2	        <= payload_aluin2_display;
                alu_tb_io_test.clocking_block.operation             <= operation_display;
                alu_tb_io_test.clocking_block.opselect              <= opselect_display;
                // $display($time, "Test Arithmetic ALU END.");
            end

            else if(run_count <= 8'd60)
            begin
                // $display($time, "Test Shift ALU BEGIN ...");
                enable_arithmetic_alu_display                       <= 1'b0;
                enable_shift_alu_display                            <= 1'b1;
                operation_display                                   <= payload_operation.pop_front();
                opselect_display                                    <= {1'b0, run_count[1:0]};

                alu_tb_io_test.clocking_block.enable_arithmetic_alu <= enable_arithmetic_alu_display;
                alu_tb_io_test.clocking_block.enable_shift_alu      <= enable_shift_alu_display;
                alu_tb_io_test.clocking_block.alu_data_in_1     	<= payload_aluin1_display;
                alu_tb_io_test.clocking_block.alu_data_in_2	        <= payload_aluin2_display;
                alu_tb_io_test.clocking_block.operation             <= operation_display;
                alu_tb_io_test.clocking_block.opselect              <= opselect_display;
                // $display($time, "Test Shift ALU END.");
            end

            else
            begin
                // $display($time, "Test ALU RANDOMLY BEGIN ...");
                enable_arithmetic_alu_display                       <= payload_aluin1_display[1];  //Random
                enable_shift_alu_display                            <= payload_aluin2_display[1];
                operation_display                                   <= payload_operation.pop_front();
                opselect_display                                    <= payload_opselect.pop_front();

                alu_tb_io_test.clocking_block.enable_arithmetic_alu <= enable_arithmetic_alu_display;
                alu_tb_io_test.clocking_block.enable_shift_alu      <= enable_shift_alu_display;
                alu_tb_io_test.clocking_block.alu_data_in_1     	<= payload_aluin1_display;
                alu_tb_io_test.clocking_block.alu_data_in_2	        <= payload_aluin2_display;
                alu_tb_io_test.clocking_block.operation             <= operation_display;
                alu_tb_io_test.clocking_block.opselect              <= opselect_display;
                // $display($time, "Test ALU RANDOMLY END.");
            end

            run_count = run_count + 1;
            @(alu_tb_io_test.clocking_block);
			display_func();
        end

        $display($time, "ns:  Test ALU RANDOMLY END!");
        $display($time, "ns:  --------------------------------------------------------.");
        $display($time, "ns:  Test ALU END!");
        $display($time, "ns:  --------------------------------------------------------.");
    endtask

    task display_func();

        if(run_count == 8'd1)
            begin
                $display($time, "ns:  Test Arithmetic ALU BEGIN ...");
            end

            else if(run_count == 8'd31)
            begin
                $display($time, "ns:  Test Arithmetic ALU END.");
                $display($time, "ns:  --------------------------------------------------------.");
                $display(" ");
                $display($time, "ns:  Test Shift ALU BEGIN ...");
            end

            else if(run_count == 8'd61)
            begin
                $display($time, "ns:  Test Shift ALU END.");
                $display($time, "ns:  --------------------------------------------------------.");
                $display(" ");
                $display($time, "ns:  Test ALU RANDOMLY BEGIN ...");
            end

            else
                $display(" ");

        // Input
        $display($time, "ns:  Inputs to ALU: enable_arith = %b, enable_shift = %b, data_in1 = %h, data_in2 = %h, operation = %b, opselect = %b", 
                        enable_arithmetic_alu_display,
                        enable_shift_alu_display,
                        payload_aluin1_display,
                        payload_aluin2_display,
                        operation_display,
                        opselect_display);
        // Output
        $display($time, "ns:  Outputs from ALU: aluout = %h", alu_tb_io_test.clocking_block.aluout_data);
    endtask


endprogram