`ifndef INC_RECEIVERBASE_SV
`define INC_RECEIVERBASE_SV
class Receiver;
  extern function new(string name = "ReceiverBase", virtual router_io.TB rtr_io);
  extern virtual  task recv();        // Receive packets from the DUT output port
  extern virtual  task get_payload(); //
endclass

function Receiver::new(string name = "ReceiverBase", virtual router_io.TB rtr_io);
  $display("");
endfunction: new

task Receiver::recv();
  
endtask: recv

task Receiver::get_payload();
  $display($time, "ns : Get Payload Start ...");
  $display($time, "ns : Get Pay load END.");
endtask: get_payload

`endif
