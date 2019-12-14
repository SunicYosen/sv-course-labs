`include "Generator.sv"
`include "Driver.sv"
`include "Receiver.sv"
`include "Scoreboard.sv"

program automatic test(router_io.TB rtr_io);
  int PORTS_NUM         = 16;
  int run_for_n_packets = 2000;     // number of packets to test
  int run_times[];                  // process of each port

  logic [7:0] pkt2cmp_payload[$];   // actual packet data array
  pkt_mbox    in_box[];             // In box for each port
  Packet      pkt[];                // Pkt get from gen to driver for each port.
  Packet      pkt2cmp = new();      // Declare and construct two Packets pkt2send and pkt2cmp
  
  Generator   gen[];                // Generator for each port
  Driver      driver[];             // Driver for each port

  initial 
  begin
    run_times = new[PORTS_NUM];     // new
    in_box    = new[PORTS_NUM];     // new
    pkt       = new[PORTS_NUM];     // Input packets
    gen       = new[PORTS_NUM];     // gen input ports Generator
    driver    = new[PORTS_NUM];     // new

    foreach (run_times[i]) run_times[i] = 0;

    reset();
    foreach (gen[i])    gen[i] = new($sformatf("gen[%0d]", i), i);    // new("gen[i]",i]
    foreach (gen[i])    gen[i].start();

    foreach (driver[i]) driver[i] = new($sformatf("driver[%0d]", i), rtr_io, gen[i].out_box);
    foreach (in_box[i]) in_box[i] = driver[i].out_box_to_check;
    
    foreach(driver[i])
    begin
      fork
        automatic int port_i = i;
        repeat(run_for_n_packets)
        begin
          $display("-------------------port%3d: %4d/%4d-------------------", port_i, run_times[port_i]+1, run_for_n_packets);

          begin
            driver[port_i].get_packet();

            fork
              begin
                driver[port_i].set_lock();
                driver[port_i].packet_to_check();
                driver[port_i].send();
                driver[port_i].release_lock();
              end

              begin
                in_box[port_i].get(pkt[port_i]);
                recv();
              end

            join
          end

          run_times[port_i] ++;
        end
      join_none // non-blocking thread
    end

    wait fork;  // wait for all forked threads in current scope to end

    repeat(10) @(rtr_io.cb);

    $finish;
  end
  
  task reset();
    $display($time, "ns : Reset Start ...");
    rtr_io.reset_n     = 1'b0;
    rtr_io.cb.frame_n <=  '1;
    rtr_io.cb.valid_n <=  '1;

    repeat(2) @rtr_io.cb;

    rtr_io.cb.reset_n <= 1'b1;

    repeat(15) @(rtr_io.cb);
    $display($time, "ns : Reset END.");
  endtask: reset

  task send();
    send_addrs();
    send_pad();
    send_payload();
  endtask: send

  task send_addrs();
    $display($time, "ns : Send Addrs Start ...");
    rtr_io.cb.frame_n[pkt[0].sa] <= 1'b0;    //start of packet
    for(int i=0; i<4; i++) begin
      rtr_io.cb.din[pkt[0].sa] <= pkt[0].da[i]; // i'th bit of da
      @(rtr_io.cb);
    end
    $display($time, "ns : Send Addrs END.");
  endtask: send_addrs

  task send_pad();
    $display($time, "ns : Send Pad Start ...");
    rtr_io.cb.frame_n[pkt[0].sa] <= 1'b0;
    rtr_io.cb.din[pkt[0].sa] <= 1'b1;
    rtr_io.cb.valid_n[pkt[0].sa] <= 1'b1;
    repeat(5) @(rtr_io.cb);
    $display($time, "ns : Send Pad END.");
  endtask: send_pad

  task send_payload();
    $display($time, "ns : Send Payload Start ...");
    foreach(pkt[0].payload[index])
      for(int i=0; i<8; i++) begin
        rtr_io.cb.din[pkt[0].sa] <= pkt[0].payload[index][i];
        rtr_io.cb.valid_n[pkt[0].sa] <= 1'b0; //driving a valid bit
        rtr_io.cb.frame_n[pkt[0].sa] <= ((i == 7) && (index == (pkt[0].payload.size() - 1)));
        @(rtr_io.cb);
      end
    rtr_io.cb.valid_n[pkt[0].sa] <= 1'b1;
    $display($time, "ns : Send Payload END.");
  endtask: send_payload

  task recv();
    //Add static int pkt_cnt before the call to get_payload()
    static int pkt_cnt = 0;
    
    get_payload();

    //Assign pkt2cmp.da with global da
    pkt2cmp.da = pkt[0].da;

    //Assign pkt2cmp.payload with pkt2cmp_payload
    pkt2cmp_payload = pkt[0].payload;

    //Set a unique name for pkt2cmp. Use pkt_cnt
    pkt2cmp.name = $sformatf("rcvdPkt[%0d]", pkt_cnt++);
  
  endtask: recv

  task get_payload();
    $display($time, "ns : Get Payload Start ...");

    pkt2cmp_payload.delete();

    fork
      begin: wd_timer_fork
      fork: frameo_wd_timer
        //Do not use @(negedge rtr_io.cb.frameo_n[da]);
		    //This may cause timing issues because of how the LRM defines it.
        begin
          wait(rtr_io.cb.valido_n[pkt[0].da] != 0);
          @(rtr_io.cb iff(rtr_io.cb.valido_n[pkt[0].da] == 0 ));
        end

        begin                              //this is another thread
          repeat(1000) @(rtr_io.cb);
          $display("\n%m\n[ERROR]%t Frame signal timed out!\n", $realtime);
          $finish;
        end

      join_any: frameo_wd_timer

      disable fork;
      end: wd_timer_fork

    join

    forever 
    begin
      logic[7:0] datum;

      for(int i=0; i<8; i=i)  
      begin 
        if(!rtr_io.cb.valido_n[pkt[0].da])
          datum[i++] = rtr_io.cb.dout[pkt[0].da];

        if(rtr_io.cb.frameo_n[pkt[0].da])
          if(i==8)
          begin          //byte alligned
            pkt2cmp_payload.push_back(datum);
            return;      //done with payload
          end

          else begin
            $display("\n%m\n[ERROR]%t Packet payload not byte aligned!\n", $realtime);
            $finish;
          end

        @(rtr_io.cb);
      end

      pkt2cmp_payload.push_back(datum);
    end
    $display($time, "ns : Get Pay load END.");
  endtask: get_payload

endprogram: test
