
//Use macros as a guard against multiple includes of Packet.sv

`ifndef INC_PACKET_SV
`define INC_PACKET_SV

//Declare a class Packet

class Packet;

  //In the body of the class create the following properties
  
  rand bit[3:0] sa, da;
  rand logic[7:0] payload[$];
       string   name;

  //In body of the class
 
  constraint valid {
  	sa inside { [0:15] };
	da inside { [0:15] };
	payload.size() inside { [2:4] };
  }

  //In body of the class
  //Add prototype declarations of the following methods

  extern function new(string name = "Packet");
  extern function bit compare(Packet pkt2cmp, ref string message);
  extern function void display(string prefix = "NOTE");
  extern function Packet copy();

endclass: Packet

//Outside the class body


function Packet::new(string name);

  //Inside new() assign class property name with string passed via argument
  
  this.name = name;
endfunction: new


//Cut and paste the compare method from the test.sv file
//Reference the method to Packet class with ::
//Modify the argument list to add a Packet handle

function bit Packet::compare(Packet pkt2cmp, ref string message);


  //In compare() compare data payload[$] with pkt2cmp_payload[$]
  //If sizes do not match
  //   set string argument with description of error
  //   terminate subroutine by returning a 0
  //If data matches (you can directly compare arrays using ==)
  //   set string argument with description of success
  //   terminate subroutine successfully by returning a 1
  //If data does not match
  //   set string argument with description of error
  //   terminate subroutine by returning a 0
  
  if(payload.size() != pkt2cmp.payload.size()) begin
    message = "Payload size Mismatch:\n";
    message = { message, $sformatf("payload.size() = %0d, pkt2cmp.payload.size() = %0d\n", payload.size(), pkt2cmp.payload.size()) };
    return (0);
  end
  if(payload == pkt2cmp.payload) ;
  else begin
    message = "Payload Content Mismatch:\n";
    message = { message, $sformatf("Packet Sent:   %p\nPkt Received:   %p", payload, pkt2cmp.payload) };
    return (0);
  end
  message = "Successfully Compared";
  return(1);
endfunction: compare


  //In compare() change all pkt2cmp_payload references to pkt2cmp.payload
  
//Define the display() function



function void Packet::display(string prefix);
  $display("[%s]%t %s sa = %0d, da = %0d", prefix, $realtime, name, sa, da);
  foreach(payload[i])
    $display("[%s]%t %s payload[%0d] = %0d", prefix, $realtime, name, i, payload[i]);
endfunction
 
function Packet Packet::copy();
	Packet pkt_copy = new();
	pkt_copy.sa = this.sa;
	pkt_copy.da = this.da;
	pkt_copy.payload = this.payload;
	return(pkt_copy);
endfunction

`endif
