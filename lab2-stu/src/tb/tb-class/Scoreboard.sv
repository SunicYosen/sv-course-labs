`ifndef INC_SCOREBOARD_SV
`define INC_SCOREBOARD_SV

/* ScoreBoard Class : Check and record the result.
 * Note: 
 * - name           : string     -- this name of scoreboard object
 * - driver_mbox    : pkt_box    -- mail box for getting packet from driver
 * - receiver_mbox  : pkt_box    -- mail box for getting packet from receiver
 * - driver_pkt     : Packet     -- Packets from driver
 * - receiver_pkt   : Packet     -- Packets from receiver
 * - result         : bit        -- Result for comparing
 * - message        : string     -- Compare message from compare module
 * - scores         : int        -- Whole number of right cases. for ALL PORTS.
 */ 

class Scoreboard;
  string   name;
  pkt_mbox driver_mbox;
  pkt_mbox receiver_mbox;
  Packet   driver_pkt;
  Packet   receiver_pkt;
       
         bit    result;
         string message;
  static int    scores;

  extern function new(string name = "Scoreboard", pkt_mbox driver_mbox = null, receiver_mbox = null);  // New function
  extern virtual task check();           // Compare the data package and check the correctness
  extern virtual task get_pkt_driver();  // Get data from driver
  extern virtual task get_pkt_receiver();// Get data from receiver
endclass: Scoreboard

// Define function of New a score board object.
function Scoreboard::new(string name = "Scoreboard", pkt_mbox driver_mbox = null, receiver_mbox = null);
    this.name          = name;
    this.driver_mbox   = driver_mbox;
    this.receiver_mbox = receiver_mbox;
    this.driver_pkt    = new;
    this.receiver_pkt  = new;
    this.scores        = 0;
    this.result        = 1'b0;
endfunction: new

// Wrapper of Check. Compare the data package and check the correctness
task Scoreboard::check();
  this.get_pkt_driver();  // Get data from driver
  this.get_pkt_receiver();// Get data from receiver
  // this.receiver_pkt.sa = this.driver_pkt;  // Comment for DONT compare sa of Packet.
  this.result = this.receiver_pkt.compare(this.driver_pkt, this.message);  // Packet compare.
  $display(this.message);   // Show the result.
  
  if(this.result)
    begin
      this.scores = this.scores + 1;  // Add the score if right.
    end

  else   // Something is wrong.
    $display("\n[ERROR]%t The Result is WRONG!\n",  $realtime);

endtask: check

// Get packet from driver.
task  Scoreboard::get_pkt_driver();
  this.driver_mbox.get(this.driver_pkt);
endtask: get_pkt_driver

// Get packet from receiver.
task  Scoreboard::get_pkt_receiver();
  this.receiver_mbox.get(this.receiver_pkt);
endtask: get_pkt_receiver

`endif
