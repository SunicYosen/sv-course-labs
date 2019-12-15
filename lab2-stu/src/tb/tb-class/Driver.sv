`ifndef INC_DRIVERBASE_SV
`define INC_DRIVERBASE_SV

/* Driver Class : Send data to DUT
 * Note: 
 * - name                 : string       -- this name of driver object
 * - rtr_io               : router_io.TB -- IO ports for listening
 * - pkt_to_check         : Packet       -- Packet send to scoreboard class
 * - out_box_to_check     : pkt_mbox     -- Mail box to scoreboard class
 * - in_box               : pkt_mbox     -- Mail box for get packets from generator class.
 * - out_ports_semaphore  : semaphore    -- static!  semaphore for output ports.
 */ 

class Driver;
  string               name;
  Packet               pkt_from_gen;
  Packet               pkt_to_check;
  pkt_mbox             in_box;
  pkt_mbox             out_box_to_check;
  virtual router_io.TB rtr_io;
  static  semaphore    out_ports_semaphore[16];

  extern function new(string name = "DriverBase", virtual router_io.TB rtr_io, pkt_mbox in_box);  // Init object
  extern virtual task get_packet();      // Read packet from generator
  extern virtual task set_lock();        // Set  semaphore for output port.
  extern virtual task release_lock();    // Release semaphore when send and received end.
  extern virtual task packet_to_check(); // Send packet to Scoreboard class
  extern virtual task send();            // wrapper of Sending packet to DUT
  extern virtual task send_addrs();      // Subtask of the send task, used to send the address
  extern virtual task send_pad();        // Subtask of the send task, used to send the pad
  extern virtual task send_payload();    // Subtask of the send task, used to send the payload
endclass: Driver

// New Function. Init a object.
function Driver::new(string name, virtual router_io.TB rtr_io, pkt_mbox in_box);
  this.name                          = name;
  this.rtr_io                        = rtr_io;
  this.pkt_from_gen                  = new;
  this.pkt_to_check                  = new;
  this.in_box                        = in_box;
  this.out_box_to_check              = new(3200);  // Deepth of mailbox to scoreboard >= 1
  foreach(this.out_ports_semaphore[i]) this.out_ports_semaphore[i] = new(1); // Init semaphore
endfunction: new

// Get Packet task. Get packets from generator class by mail box.
task Driver::get_packet();
  this.in_box.get(this.pkt_from_gen);
endtask: get_packet

// Set lock of output port by semaphore
task Driver::set_lock();
  this.out_ports_semaphore[this.pkt_from_gen.da].get(1);
endtask

// Release lock of output port by semaphore
task Driver::release_lock();
  this.out_ports_semaphore[this.pkt_from_gen.da].put(1);
endtask: release_lock

// Send packet to Scoreboard class.
task Driver::packet_to_check();
    this.pkt_to_check = this.pkt_from_gen.copy();
    this.out_box_to_check.put(pkt_to_check);
endtask: packet_to_check


// Send Wrapper with send addrs/pad/payload
task Driver::send();
  $display($time, "ns : I %2d-->%2d -- S: ", this.pkt_from_gen.sa, this.pkt_from_gen.da, this.pkt_from_gen.payload);
  this.send_addrs();  // Send addrs 
  this.send_pad();    // Send Pads
  this.send_payload();// Send payloads 
endtask: send


// Send addrs task. Send output ports address.
task Driver::send_addrs();
  $display($time, "ns : I %2d -- Send Addrs Start ...", this.pkt_from_gen.sa);
  
  this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= 1'b0;   // Set frame_n when send start.
  
  for(int i=0; i<4; i++)  // Send Address bit by bit
  begin
    this.rtr_io.cb.din[this.pkt_from_gen.sa] <= this.pkt_from_gen.da[i]; //i'th bit of da
    @(this.rtr_io.cb);
  end
  $display($time, "ns : I %2d -- Send Addrs END.", this.pkt_from_gen.sa);
endtask: send_addrs

task Driver::send_pad();  // Send Pad 
  $display($time, "ns : I %2d -- Send Pad Start ...", this.pkt_from_gen.sa);
  
  // Set signals.
  this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= 1'b0;  
  this.rtr_io.cb.din[this.pkt_from_gen.sa]     <= 1'b1;
  this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b1;

  // Delay
  repeat(5) @(this.rtr_io.cb);

  $display($time, "ns : I %2d -- Send Pad END.", this.pkt_from_gen.sa);
endtask: send_pad

// Send payload. Send data to DUT.
task Driver::send_payload();
  $display($time, "ns : I %2d -- Send Payload Start ...", this.pkt_from_gen.sa);

  foreach(this.pkt_from_gen.payload[index]) // Send All payloads.
  begin
    for(int i=0; i<8; i++)  // Send Bit by Bit
    begin
      this.rtr_io.cb.din[this.pkt_from_gen.sa]     <= this.pkt_from_gen.payload[index][i];
      this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b0;            // driving a valid bit
      this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= ((i == 7) && (index == (this.pkt_from_gen.payload.size() - 1)));
      @(this.rtr_io.cb);
    end
  end

  this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b1;  // Disable valid_n when send data end.

  $display($time, "ns : I %2d -- Send Payload END.", this.pkt_from_gen.sa);
  
endtask: send_payload

`endif
