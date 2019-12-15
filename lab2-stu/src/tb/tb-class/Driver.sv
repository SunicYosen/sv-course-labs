`ifndef INC_DRIVERBASE_SV
`define INC_DRIVERBASE_SV

class Driver;
  string               name;
  Packet               pkt_from_gen;
  Packet               pkt_to_check;
  pkt_mbox             in_box;
  pkt_mbox             out_box_to_check;
  virtual router_io.TB rtr_io;
  static  semaphore    out_ports_semaphore[16];

  extern function new(string name = "DriverBase", virtual router_io.TB rtr_io, pkt_mbox in_box);
  extern virtual task get_packet();
  extern virtual task set_lock();
  extern virtual task release_lock();
  extern virtual task packet_to_check();
  extern virtual task send();            // Send packet
  extern virtual task send_addrs();      // Subtask of the send task, used to send the address
  extern virtual task send_pad();        // Subtask of the send task, used to send the pad
  extern virtual task send_payload();    // Subtask of the send task, used to send the payload
endclass: Driver

function Driver::new(string name, virtual router_io.TB rtr_io, pkt_mbox in_box);
  this.name                          = name;
  this.rtr_io                        = rtr_io;
  this.pkt_from_gen                  = new;
  this.pkt_to_check                  = new;
  this.in_box                        = in_box;
  this.out_box_to_check              = new(3200);
  foreach(this.out_ports_semaphore[i]) this.out_ports_semaphore[i] = new(1);
endfunction: new

task Driver::get_packet();
  this.in_box.get(this.pkt_from_gen);
endtask: get_packet

task Driver::set_lock();
  this.out_ports_semaphore[this.pkt_from_gen.da].get(1); // lock output
endtask

task Driver::release_lock();
  this.out_ports_semaphore[this.pkt_from_gen.da].put(1); // release output
endtask: release_lock

task Driver::packet_to_check();
    this.pkt_to_check = this.pkt_from_gen.copy();
    this.out_box_to_check.put(pkt_to_check);
endtask: packet_to_check

task Driver::send();
  $display($time, "ns : I %2d-->%2d -- S: ", this.pkt_from_gen.sa, this.pkt_from_gen.da, this.pkt_from_gen.payload);
  this.send_addrs();
  this.send_pad();
  this.send_payload();
endtask: send

task Driver::send_addrs();
  $display($time, "ns : I %2d -- Send Addrs Start ...", this.pkt_from_gen.sa);
  
  this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= 1'b0;        // Start of packet
  
  for(int i=0; i<4; i++)
  begin
    this.rtr_io.cb.din[this.pkt_from_gen.sa] <= this.pkt_from_gen.da[i]; //i'th bit of da
    @(this.rtr_io.cb);
  end
  $display($time, "ns : I %2d -- Send Addrs END.", this.pkt_from_gen.sa);
endtask: send_addrs

task Driver::send_pad();
  $display($time, "ns : I %2d -- Send Pad Start ...", this.pkt_from_gen.sa);

  this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= 1'b0;
  this.rtr_io.cb.din[this.pkt_from_gen.sa]     <= 1'b1;
  this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b1;
  repeat(5) @(this.rtr_io.cb);

  $display($time, "ns : I %2d -- Send Pad END.", this.pkt_from_gen.sa);
endtask: send_pad

task Driver::send_payload();
  $display($time, "ns : I %2d -- Send Payload Start ...", this.pkt_from_gen.sa);

  foreach(this.pkt_from_gen.payload[index])
  begin
    for(int i=0; i<8; i++)
    begin
      this.rtr_io.cb.din[this.pkt_from_gen.sa]     <= this.pkt_from_gen.payload[index][i];
      this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b0;            //driving a valid bit
      this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= ((i == 7) && (index == (this.pkt_from_gen.payload.size() - 1)));
      @(this.rtr_io.cb);
    end
  end

  this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b1;

  $display($time, "ns : I %2d -- Send Payload END.", this.pkt_from_gen.sa);
  
endtask: send_payload

`endif
