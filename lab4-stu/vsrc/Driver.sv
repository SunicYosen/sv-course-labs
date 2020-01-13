`include "DriverBase.sv"
class Driver extends DriverBase;
  //Mailbox in_box;	// Generator mailbox // QUESTA QUIRK
  typedef mailbox #(Packet) in_box_type;
  in_box_type in_box = new;
  //Mailbox out_box;	// Scoreboard mailbox // QUESTA QUIRK
  typedef mailbox #(Packet) out_box_type;
  out_box_type out_box = new;
  //Semaphore sem[];	// output port arbitration

  extern function new(string name = "Driver", in_box_type in_box, out_box_type out_box, virtual Execute_io.TB Execute);
  extern virtual task start();
endclass

function Driver::new(string name= "Driver", in_box_type in_box, out_box_type out_box, virtual Execute_io.TB Execute);
  super.new(name, Execute);
  this.in_box = in_box;
  this.out_box = out_box;
endfunction

task Driver::start();
	reg	[6:0]	control_in_temp;
	int get_flag = 10; 
	int packets_sent = 0;
	$display ($time, "ns:  [DRIVER] Driver Started");
    fork
	    forever
	    begin
	      	in_box.get(pkt2send); // grab the packet in the q
			packets_sent++;
		  	control_in_temp = {pkt2send.operation_gen, pkt2send.immp_regn_op_gen, pkt2send.opselect_gen};
			$display ($time, "[DRIVER] Sending in new packet BEGIN");
		  	this.payload_control_in = control_in_temp;
		  	this.payload_src1 = pkt2send.src1; 
		  	this.payload_src2 = pkt2send.src2;
		  	this.payload_imm = 	pkt2send.imm;  
		  	this.payload_mem_data = pkt2send.mem_data;
			this.payload_enable = pkt2send.enable;
	      				
 	     	send();
	 		
			$display ($time, "ns:  [DRIVER] Sending in new packet END");
			$display ($time, "ns:  [DRIVER] Number of packets sent = %d", packets_sent);
	     	out_box.put(pkt2send);
			$display ($time,  "ns:  [DRIVER] The number of Packets in the Generator Mailbox = %d", in_box.num());
			if(in_box.num() == 0)
			begin
				break;
			end
		  	@(Execute.cb);
	    end
	join_none	
endtask

