// Receiver class 
// By Sunic

`ifndef INC_RECEIVERBASE_SV
`define INC_RECEIVERBASE_SV

/* Receiver Class: Get Data from DUT
 * Note: 
 * - name             : string       -- this name of receiver class
 * - rtr_io           : router_io.TB -- IO ports for listening
 * - pkt_to_check     : Packet       -- Packet send to scoreboard class
 * - out_box_to_check : pkt_mbox     -- Mail box to scoreboard class
 * - listen_port      : int          -- Listen output port this receiver
 * - payload_temp[$]  : queue        -- temp payload for receiving from output port
 */

class Receiver;                        
  string               name;            
  virtual router_io.TB rtr_io;          
  Packet               pkt_to_check;    
  pkt_mbox             out_box_to_check; 
  int                  listen_port;
  logic [7:0]          payload_temp[$];

  extern function new(string name = "ReceiverBase", virtual router_io.TB rtr_io, int listen_port); // new function
  extern virtual  task recv();        // Receive packets from the DUT output port by get_payload();
  extern virtual  task get_payload(); // Receive packets from the DUT output port
endclass

// Init receive object
function Receiver::new(string name = "ReceiverBase", virtual router_io.TB rtr_io, int listen_port);
  this.name             = name;
  this.rtr_io           = rtr_io;
  this.pkt_to_check     = new;
  this.out_box_to_check = new(32000);
  this.listen_port      = listen_port;
endfunction: new


// Receive wrapper
task Receiver::recv();
  this.get_payload();
endtask: recv

/* get payload task. 
 * Note:
 * Get payload from DUT output port (listen port).
 */
task Receiver::get_payload();
  $display($time, "ns : O %2d -- Get Payload Start ...", this.listen_port);

  fork
    begin: wd_timer_fork
      fork: frameo_wd_timer 
        // Do not use @(negedge rtr_io.cb.frameo_n[da]);
        // This may cause timing issues because of how the LRM defines it.
        begin  // wait until valido_n enabled.
          wait(this.rtr_io.cb.valido_n[this.listen_port] != 0);
          @(this.rtr_io.cb iff(this.rtr_io.cb.valido_n[this.listen_port] == 0 ));
        end

        begin //this is another thread
          repeat(1000) @(this.rtr_io.cb);  // Long time no data arrived.
          $display("\n%m\n[ERROR]%t Port: %2d Frame signal timed out!\n", $realtime, this.listen_port);
          $finish;
        end

      join_any: frameo_wd_timer

      disable fork;
    end: wd_timer_fork

  join

  forever 
  begin
    logic [7:0] datum;

    for(int i=0; i<8; i=i)   // Receive datum arrived at listening port.
    begin
      if(!this.rtr_io.cb.valido_n[this.listen_port])
      begin
        datum[i++] = this.rtr_io.cb.dout[this.listen_port];
      end

      if(this.rtr_io.cb.frameo_n[this.listen_port])
        if(i == 8)
          begin                                            // byte alligned
            this.payload_temp.push_back(datum);            // Set output data
            this.pkt_to_check.da = this.listen_port;       // Set Output addresss.
            this.pkt_to_check.payload = this.payload_temp; // Set payload
            this.out_box_to_check.put(this.pkt_to_check);  // Put to Check packet mail box.
            $display($time, "ns : O %2d -- R: ", this.listen_port, this.payload_temp);
            this.payload_temp.delete();                    // clear temp payload
            return;                                        // done with payload
          end
        else   // Not byte aligned 
          begin
            $display("\n%m\n[ERROR]%t Packet payload not byte aligned!\n", $realtime);
            $display("Port=%3d, i = %2d\n", this.listen_port, i);
            $finish;
          end
        
        @(this.rtr_io.cb);
    end

    this.payload_temp.push_back(datum);      // push output data to payload
    // $display("O %2d: ", this.listen_port, this.payload_temp);
    // $display("Port:%2d, R: %3d", this.listen_port, datum);
  end
  $display($time, "ns : O %2d -- Get Payload END!", this.listen_port);

endtask: get_payload

`endif
