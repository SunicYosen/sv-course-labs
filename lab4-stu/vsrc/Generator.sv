class Generator;
	string  name;		
	Packet  pkt2send;	
	
    typedef mailbox #(Packet) in_box_type;
	in_box_type in_box;
	
	int		packet_number;
	int 	number_packets;
	extern function new(string name = "Generator", int number_packets);
	extern virtual task gen();
	extern virtual task start();
endclass

function Generator::new(string name = "Generator", int number_packets);
	this.name = name;
	this.pkt2send = new();
	this.in_box = new;
	this.packet_number = 0;
	this.number_packets = number_packets;
endfunction

task Generator::gen();
	  
	pkt2send.name = $psprintf("Packet[%0d]", packet_number++);
	if (!pkt2send.randomize()) 
	begin
		$display(" \n%m\n[ERROR]%0d gen(): Randomization Failed!", $time);
		$finish;	
	end
	pkt2send.enable = $urandom_range(0,1);
endtask

task Generator::start();
	  $display ($time, "ns:  [GENERATOR] Generator Started");
	  fork
		  for (int i=0; i<number_packets || number_packets <= 0; i++) 
		  begin
			  gen();
			  begin 
			      Packet pkt = new pkt2send; 
				  in_box.put(pkt); // FUNNY .. 
			  end
		  end
		  $display($time, "ns:  [GENERATOR] Generation Finished Creating %d Packets  ", number_packets);
      join_none
endtask
