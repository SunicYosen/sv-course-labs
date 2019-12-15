`ifndef INC_SCOREBOARD_SV
`define INC_SCOREBOARD_SV

class Scoreboard;
  string   name;
  pkt_mbox driver_mbox;
  pkt_mbox receiver_mbox;

  Packet   driver_pkt;
  Packet   receiver_pkt;

  bit      result;
  string   message;

  static int scores;

  extern function new(string name = "Scoreboard", pkt_mbox driver_mbox = null, receiver_mbox = null);
  extern virtual task check();           //Compare the data package and check the correctness
  extern virtual task get_pkt_driver();
  extern virtual task get_pkt_receiver();

endclass: Scoreboard

function Scoreboard::new(string name = "Scoreboard", pkt_mbox driver_mbox = null, receiver_mbox = null);
    this.name          = name;
    this.driver_mbox   = driver_mbox;
    this.receiver_mbox = receiver_mbox;
    this.driver_pkt    = new;
    this.receiver_pkt  = new;
    this.scores        = 0;
    this.result        = 1'b0;
endfunction: new

task Scoreboard::check();           //Compare the data package and check the correctness
  this.get_pkt_driver();
  this.get_pkt_receiver();
  // this.receiver_pkt.sa = this.driver_pkt;
  this.result = this.receiver_pkt.compare(this.driver_pkt, this.message);
  $display(this.message);
  if(this.result)
    begin
      this.scores = this.scores + 1;
    end

  else
    $display("\n[ERROR]%t The Result is WRONG!\n",  $realtime);

endtask: check

task  Scoreboard::get_pkt_driver();
  this.driver_mbox.get(this.driver_pkt);
endtask: get_pkt_driver

task  Scoreboard::get_pkt_receiver();
  this.receiver_mbox.get(this.receiver_pkt);
endtask: get_pkt_receiver

`endif
