
/* fifo_tb_func.sv
 * test bench functions of fifo
 * Sunic
 * 2019.11.03
 */

program fifo_test(fifo_tb_io.TB fifo_tb_io_test);

    parameter run_n_times  = 2;
    parameter INPUT_WIDTH  = 64;
    parameter OUTPUT_BITS  = 32;
    parameter SIZE_WIDTH   = 2;
    parameter PAYLOAD_SIZE = 2048;

    int       run_n_times_count = 0;
    integer   seed              = 0;

    reg [INPUT_WIDTH-1:0]   payload_data_in[$];
    reg [SIZE_WIDTH -1:0]   payload_size[$];

    reg [INPUT_WIDTH-1:0]   data_in_display;
    reg [SIZE_WIDTH -1:0]   size_display;
    reg                     valid_in_display;

    wire                    ready_in;
    wire                    valid_out;
    wire [OUTPUT_BITS-1:0]  data_out;

    //read from fifo
    assign ready_in  = fifo_tb_io_test.clocking_block.ready_in;   
    assign valid_out = fifo_tb_io_test.clocking_block.valid_out;
    assign data_out  = fifo_tb_io_test.clocking_block.data_out;

    initial begin
        reset_n();  //reset
        run_n_times_count = 0;
        repeat(run_n_times) 
            begin
                $display($time, "ns:  Function Testing ... %2d/%2d",run_n_times_count, run_n_times);
                seed = $get_initial_random_seed() + run_n_times_count;
                payload_gen();         // gen random input data
                write_full();          // Write fifo until full 
                write_data_empty();    // Write all payload data to fifo
                read_data_empty();     // Read all fifo
                run_n_times_count ++;  // Iteration
            end
    	repeat(5) @(fifo_tb_io_test.clocking_block);
    end

    task reset_n();
		$display($time, "ns: RESET BEGIN...");		
		fifo_tb_io_test.reset_n <= 1'b0;
		repeat(5) @(fifo_tb_io_test.clocking_block);
		fifo_tb_io_test.reset_n <= 1'b1;
		$display($time, "ns: RESET END");
	endtask

    task payload_gen();
        $display($time, "ns: Creating Payload Packets...");
        repeat(PAYLOAD_SIZE)
        begin
            payload_data_in.push_back({$random(seed), $random(seed)});
            payload_size.push_back($random(seed));
        end
        $display($time, "ns: Created Payload!");
        $display($time, "ns:  --------------------------------------------------------.");
    endtask

    task write_full();  // Write utill fifo full 
        $display($time, "ns: Task write Full Begin...");
        while(ready_in & (payload_data_in.size() !=0))
        begin
            data_in_display   <= payload_data_in.pop_front();
            size_display      <= payload_size.pop_front();
            valid_in_display  <= 1'b1;

            // Send data
            fifo_tb_io_test.clocking_block.data_in  <= data_in_display;
            fifo_tb_io_test.clocking_block.valid_in <= valid_in_display;
            fifo_tb_io_test.clocking_block.size     <= size_display;  

            //Display
            display_in();
            display_out();
            
            @(fifo_tb_io_test.clocking_block);
        end

        if(!ready_in)
        begin
            $display($time, "ns: FIFO is FULL!");
        end

        if(payload_data_in.size() == 0)
        begin
            $display($time, "ns: Payload data is empty!");
        end

        $display($time, "ns: Task write full END!");
        $display($time, "ns:  --------------------------------------------------------.");
    endtask

    task write_data_empty();  //
        $display($time, "ns: Task write data empty Begin...");
        while(payload_data_in.size() !=0)
        begin
            data_in_display   <= payload_data_in.pop_front();
            size_display      <= payload_size.pop_front();
            
            if(!ready_in)
                valid_in_display <= 1'b0;
            else
                valid_in_display <= 1'b1;
            // send data
            fifo_tb_io_test.clocking_block.data_in  <= data_in_display;
            fifo_tb_io_test.clocking_block.valid_in <= valid_in_display;
            fifo_tb_io_test.clocking_block.size     <= size_display;           

            // Display
            display_in();
            display_out();
            
            @(fifo_tb_io_test.clocking_block);
        end

        if(payload_data_in.size() == 0)
        begin
            $display($time, "ns: Payload data is empty!");
        end

        $display($time, "ns: Task write data empty END!");
        $display($time, "ns:  --------------------------------------------------------.");
    endtask

    task read_data_empty();  //read data empty
        $display($time, "ns: Task write data empty Begin...");
        while(valid_out)
        begin

            data_in_display   <= 64'h0000_0000_0000_0000;
            size_display      <= 2'b00;
            valid_in_display  <= 1'b0;    // do not write fifo

            // Send data
            fifo_tb_io_test.clocking_block.data_in  <= data_in_display;
            fifo_tb_io_test.clocking_block.valid_in <= valid_in_display;
            fifo_tb_io_test.clocking_block.size     <= size_display;  

            //Display
            display_in();
            display_out();
            @(fifo_tb_io_test.clocking_block);
        end

        $display($time, "ns: Task Read data empty END!");
        $display($time, "ns:  --------------------------------------------------------.");
    endtask

/*  For no control for read.
 *
 *    task read();
 *        $display($time, "ns: Task read Begin...");
 *        while(valid_out)
 *        begin
 *            $display(" ");
 *        end
 *        $display($time, "ns: Task read END!");
 *        $display($time, "ns:  --------------------------------------------------------.");
 *    endtask
 *
 *    task random_rw();
 *        $display($time, "ns: Task random_rw Begin...");
 *        $display($time, "ns: Task random_rw END!");
 *        $display($time, "ns:  --------------------------------------------------------.");
 *    endtask
 */

    task display_in();  //Display the inputs
        $display($time, "ns:  Inputs:   valid_in=%1b,   size=%1d,    data_in=%16h",
                         valid_in_display, size_display, data_in_display);
    endtask

    task display_out(); // Display the outputs
        $display($time, "ns: Outputs:   valid_out=%1b,  ready_in=%1b,   data_out=%8h",
                        valid_out, ready_in, data_out);
    endtask

endprogram
