///
/// Note the Timeunit, Timeprecision and timescale definitions.. ( SystemVerilog ) 
/// You can use timeunit and timeprecision together .. or Use timescale 
///

//timeunit 1ns;
//timeprecision 100ps;
`timescale 1ns/100ps

/// Module ports can be defined in multiple ways.. 
/// Either pass this as arguement ..else define it seperatly inside the module

//module counter ( input logic clk, rst, enable, [4:0]data,
//output logic [4:0]count );

module counter (clk,rst,enable,count);
    input logic clk;
    input logic rst;
    input logic enable;
    output logic [9:0]count;

    always @(posedge clk or negedge rst)
    begin
        // priority if ( !rst )
        // unique if ( !rst )
        if ( !rst )
            count <= '0 ;
        else
            if (enable)
            begin
                if (count == 10'd1000)
                    count <='0;
                else
                    count +=1;
            end

            else 
              count -- ;
    end
    
endmodule
