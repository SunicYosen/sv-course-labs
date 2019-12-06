`ifndef INC_DRIVERBASE_SV
`define INC_DRIVERBASE_SV

class Driver;
  string   name;
  Packet   pkt_from_gen;
  pkt_mbox in_box;
  virtual  router_io.TB rtr_io;

  extern function new(string name = "DriverBase", virtual router_io.TB rtr_io);
  extern virtual task send();            //Send packet
  extern virtual task send_addrs();      //Subtask of the send task, used to send the address
  extern virtual task send_pad();        //Subtask of the send task, used to send the pad
  extern virtual task send_payload();    //Subtask of the send task, used to send the payload
endclass: Driver

function Driver::new(string name, virtual router_io.TB rtr_io);
  this.name         = name;
  this.rtr_io       = rtr_io;
  this.pkt_from_gen = new();
  this.in_box       = new(1);
endfunction: new

task Driver::send();
  this.send_addrs();
  this.send_pad();
  this.send_payload();
endtask: send

task Driver::send_addrs();
  $display($time, "ns : Send Addrs Start ...");
  this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= 1'b0;        //start of packet
  for(int i=0; i<4; i++)
  begin
    this.rtr_io.cb.din[this.pkt_from_gen.sa] <= this.pkt_from_gen.da[i]; //i'th bit of da
    @(this.rtr_io.cb);
  end
  $display($time, "ns : Send Addrs END.");
endtask: send_addrs

task Driver::send_pad();
  $display($time, "ns : Send Pad Start ...");
    this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= 1'b0;
    this.rtr_io.cb.din[this.pkt_from_gen.sa]     <= 1'b1;
    this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b1;
    repeat(5) @(this.rtr_io.cb);
  $display($time, "ns : Send Pad END.");
endtask: send_pad

task Driver::send_payload();
  $display($time, "ns : Send Payload Start ...");
    foreach(this.pkt_from_gen.payload[index])
      for(int i=0; i<8; i++) begin
        this.rtr_io.cb.din[this.pkt_from_gen.sa]     <= this.pkt_from_gen.payload[index][i];
        this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b0; //driving a valid bit
        this.rtr_io.cb.frame_n[this.pkt_from_gen.sa] <= ((i == 7) && (index == (this.pkt_from_gen.payload.size() - 1)));
        @(this.rtr_io.cb);
      end
    this.rtr_io.cb.valid_n[this.pkt_from_gen.sa] <= 1'b1;
  $display($time, "ns : Send Payload END.");
endtask: send_payload

`endif
