interface fifo_tb_io(input bit clock);
    parameter FIFO_DEEPTH = 256;
    parameter INPUT_WIDTH = 64;
    parameter OUTPUT_BITS = 32;

    logic                    reset_n;
    logic                    valid_in;
    logic [1:0]              size;
    logic [INPUT_WIDTH-1:0]  data_in;
    logic                    valid_out;
    logic                    ready_in;
    logic [OUTPUT_BITS-1:0]  data_out;

    clocking clocking_block @(posedge clock);
        // default input #1 output #1;

        output valid_in;
        output size;
        output data_in;
        
        input  valid_out;
        input  ready_in;
        input  data_out;
    endclocking

    modport TB(clocking clocking_block, output reset_n);
endinterface
