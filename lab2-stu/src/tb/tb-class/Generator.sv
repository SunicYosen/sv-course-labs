`ifndef INC_GENERATOR_SV
`define INC_GENERATOR_SV

typedef mailbox #(Packet) pkt_mbox;

class Generator;
  int        run_for_n_packets = 34000; // >= Needed
  string     name;		            // unique identifier
  Packet     pkt2send;	          // stimulus Packet object
  pkt_mbox   out_box;	            // mailbox to Drivers
  int        port_id = -1;        // port_id of connected Driver
  static int pkts_generated = 0;  // packet count across all generators

  extern         function new(string name = "Generator", int port_id);
  extern virtual task     gen();
  extern virtual task     start();

endclass: Generator

function Generator::new(string name, int port_id);
  this.name     = name;
  this.pkt2send = new();
  this.out_box  = new(1);    // 1-deep mailbox
  this.port_id  = port_id;
endfunction: new

task Generator::gen();
  $display($time, "ns: Packet Gen: %5d/%5d", pkts_generated, run_for_n_packets);
  this.pkt2send.name = $sformatf("Packet[%0d]", this.pkts_generated++);   // Packet[0:1999]
  if (!this.pkt2send.randomize() with {if (port_id != -1) sa == port_id;})
  begin
    $display("\n%m\n[ERROR]%t Randomization Failed!\n", $realtime);
    $finish;
  end
endtask: gen

task Generator::start();
  fork
    while (this.pkts_generated < run_for_n_packets || run_for_n_packets <= 0) 
    begin
      this.gen();
      begin
        Packet pkt = this.pkt2send.copy();
        this.out_box.put(pkt);
      end
    end
  join_none
endtask: start

`endif
