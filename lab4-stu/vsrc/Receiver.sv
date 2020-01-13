`include "ReceiverBase.sv"
class Receiver extends ReceiverBase;

  	typedef mailbox #(OutputPacket) rx_box_type;
  	rx_box_type 	rx_out_box;		// mailbox for Packet objects To Scoreboard 
   	
	extern function new(string name = "Receiver", rx_box_type rx_out_box, virtual Execute_io.TB Execute, virtual DUT_probe_if Prober);
   	extern virtual task start();
endclass

function Receiver::new(string name = "Receiver", rx_box_type rx_out_box, virtual Execute_io.TB Execute, virtual DUT_probe_if Prober);
  super.new(name, Execute, Prober);
  this.rx_out_box = rx_out_box;
endfunction

task Receiver::start();
	$display($time, "ns:  [RECEIVER]  RECEIVER STARTED");
	@ (Execute.cb); // to cater to the one cycle delay in the pipeline
	fork
		forever
		begin
			get_memdout();				// Get Mem Data Out is called first because this is created asynchronously as 
								// soon as the Pre Processor gets a new set of i/ps at each positive clock

			@ (Execute.cb);
			recv();
			rx_out_box.put(pkt_cmp);
			$display($time, "ns:   [RECEIVER -> GETPAYLOAD]   Payload Obtained");
		end	
	join_none
endtask

