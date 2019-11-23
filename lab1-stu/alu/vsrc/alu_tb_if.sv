
/* alu_tb_if.sv
 * Sunic
 * 2019.11.14
 * testbench interface
 */

interface alu_tb_io(input bit clock);
    parameter DATA_WIDTH      = 32;
    parameter OPERATION_WIDTH = 3;
    parameter OPSELECT_WIDTH  = 3;
    
    logic                        reset_n;
    logic [DATA_WIDTH-1:0]       alu_data_in_1;   
    logic [DATA_WIDTH-1:0]       alu_data_in_2;
    logic [OPERATION_WIDTH-1:0]  operation;
    logic [OPSELECT_WIDTH-1:0]   opselect;
    logic                        enable_arithmetic_alu;
    logic                        enable_shift_alu;

    logic [DATA_WIDTH-1:0]       aluout_data;

    clocking clocking_block @(posedge clock);
        // default input #1 output #1;

        output alu_data_in_1;
        output alu_data_in_2;
        output operation;
        output opselect;
        output enable_arithmetic_alu;
        output enable_shift_alu;

        input  aluout_data;

    endclocking

    modport TB(clocking clocking_block, output reset_n);

endinterface
