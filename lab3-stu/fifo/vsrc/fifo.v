`timescale 1ns / 1ps

module fifo(clock,
            reset_n,
            w_en,
            r_en,
            size,
            data_in,
            valid_out,
            data_out,
            empty,
            full,
            overflow);

  input           clock;
  input           reset_n;
  input           w_en;
  input           r_en;
  input  [1:0]    size;
  input  [63:0]   data_in;
  output          valid_out;  
  output [31:0]   data_out;
  output          empty;
  output          full;
  output          overflow;

  parameter FIFO_DATA_WIDTH = 8; 
  parameter FIFO_ADDR_WIDTH = 8; 
  parameter FIFO_DP         = 2 << FIFO_ADDR_WIDTH ;

  reg  [31:0]                  data_out;
  reg                          valid_out;
  reg                          overflow;
  wire                         empty;
  wire                         full; 

  reg  [FIFO_DATA_WIDTH-1:0]   fifo_rd_data; 
  reg  [FIFO_ADDR_WIDTH-1:0]   fifo_wr_addr; 
  reg  [FIFO_ADDR_WIDTH-1:0]   fifo_rd_addr; 
  reg  [FIFO_ADDR_WIDTH-1:0]   wr_addr_ptr;
  reg  [FIFO_ADDR_WIDTH-1:0]   rd_addr_ptr;
  reg  [FIFO_DATA_WIDTH-1:0]   fifo_mem [FIFO_DP-1:0] ;
  integer i;

  assign empty  =  (wr_addr_ptr == rd_addr_ptr ) ;
  assign full   = ((wr_addr_ptr[FIFO_ADDR_WIDTH-1]^rd_addr_ptr[FIFO_ADDR_WIDTH-1])&(wr_addr_ptr[FIFO_ADDR_WIDTH-1:0]==rd_addr_ptr[FIFO_ADDR_WIDTH-1:0]+4));

  always @(posedge clock or negedge reset_n)
  begin
    if(reset_n == 1'b0)
      begin
        for(i=0;i<= FIFO_DP-1 ; i=i+1)
          fifo_mem[i] <= {(FIFO_DATA_WIDTH){1'b0}} ;
      end

    else if (w_en & (~full))
      begin
        if(size==2'b00) 
          begin
            fifo_mem[fifo_wr_addr] <= data_in[7:0];
          end

        else if (size==2'b01) 
          begin
            fifo_mem[fifo_wr_addr]   <= data_in[7:0];
            fifo_mem[fifo_wr_addr+1] <= data_in[15:8];
          end

        else if (size==2'b10) 
          begin
            fifo_mem[fifo_wr_addr]   <= data_in[7:0];
            fifo_mem[fifo_wr_addr+1] <= data_in[15:8];
            fifo_mem[fifo_wr_addr+2] <= data_in[23:16];
            fifo_mem[fifo_wr_addr+3] <= data_in[31:24];
          end

        else if (size==2'b11) 
          begin
            fifo_mem[fifo_wr_addr]   <= data_in[7:0];
            fifo_mem[fifo_wr_addr+1] <= data_in[15:8];
            fifo_mem[fifo_wr_addr+2] <= data_in[23:16];
            fifo_mem[fifo_wr_addr+3] <= data_in[31:24];
            fifo_mem[fifo_wr_addr+4] <= data_in[39:32];
            fifo_mem[fifo_wr_addr+5] <= data_in[47:40];
            fifo_mem[fifo_wr_addr+6] <= data_in[55:48];
            fifo_mem[fifo_wr_addr+7] <= data_in[63:56];
          end
      end       
  end
  
  always @(posedge clock or negedge reset_n)
    begin
      if(reset_n == 1'b0) begin
        data_out   <= {32{1'b0}};
        valid_out  <=1'b0;
      end

      else if (r_en) 
        begin
          data_out[7:0]     <= fifo_mem[fifo_rd_addr]; 
          data_out[15:8]    <= fifo_mem[fifo_rd_addr+1]; 
          data_out[23:16]   <= fifo_mem[fifo_rd_addr+2];         
          data_out[31:24]   <= fifo_mem[fifo_rd_addr+3]; 
          valid_out         <= '1;
        end

      else 
        begin
          valid_out  <='0;
        end
    end
  
  always @(posedge clock or negedge reset_n)
    begin
      if(reset_n == 1'b0)
        rd_addr_ptr <= {(FIFO_ADDR_WIDTH){1'b0}} ;

      else if (r_en)
        rd_addr_ptr <= rd_addr_ptr + 3'b100 ;         
    end
 
  always @(posedge clock or negedge reset_n)
    begin
      if(reset_n == 1'b0)
        wr_addr_ptr <= {(FIFO_ADDR_WIDTH){1'b0}} ;
      
      else if (w_en & (~full))
        begin
          if(size==2'b00) begin
            wr_addr_ptr <= wr_addr_ptr + 1'b1 ;
        end
      
      if(size==2'b01) 
        begin
          wr_addr_ptr <= wr_addr_ptr + 2'b10 ;
        end
        
      if(size==2'b10) 
        begin
          wr_addr_ptr <= wr_addr_ptr + 3'b100 ;
        end
        
      if(size==2'b11) 
        begin
          wr_addr_ptr <= wr_addr_ptr + 4'b1000 ;
        end
     end        
 end

always @*
  begin
    fifo_wr_addr = wr_addr_ptr[FIFO_ADDR_WIDTH-1:0];
    fifo_rd_addr = rd_addr_ptr[FIFO_ADDR_WIDTH-1:0];
  end

always @(posedge clock or negedge reset_n)
if(!reset_n)
   overflow <= 1'b0;
else
   overflow <= full;

endmodule
