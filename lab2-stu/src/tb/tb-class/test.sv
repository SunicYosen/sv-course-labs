program automatic test(router_io.TB rtr_io);

  `include "Generator.sv"

  Packet  pkt= new();
  pkt_mbox in_box;
  int run_for_n_packets; // number of packets to test

  Generator gen[];       // generator


  logic[7:0] pkt2cmp_payload[$];      // actual packet data array

  //Declare and construct two Packets pkt2send and pkt2cmp

  Packet pkt2cmp  = new();

  initial 
  begin
    
    run_for_n_packets = 2000;

    gen = new[1];

    foreach (gen[i]) gen[i] = new($sformatf("gen[%0d]", i), i);

      reset();

    repeat(run_for_n_packets) 
    begin
      
      gen[0].start();
      in_box = gen[0].out_box;  //ADD
      in_box.get(pkt);

      fork
        send();
        recv();
      join
    
    end
    repeat(10) @(rtr_io.cb);
  end
  
  task reset();
    rtr_io.reset_n = 1'b0;
    rtr_io.cb.frame_n <= '1;
    rtr_io.cb.valid_n <= '1;
    repeat(2) @rtr_io.cb;
    rtr_io.cb.reset_n <= 1'b1;
    repeat(15) @(rtr_io.cb);
  endtask: reset


  task send();
    send_addrs();
    send_pad();
    send_payload();
  endtask: send

  task send_addrs();
    rtr_io.cb.frame_n[pkt.sa] <= 1'b0; //start of packet
    for(int i=0; i<4; i++) begin
      rtr_io.cb.din[pkt.sa] <= pkt.da[i]; //i'th bit of da
      @(rtr_io.cb);
    end
  endtask: send_addrs

  task send_pad();
    rtr_io.cb.frame_n[pkt.sa] <= 1'b0;
    rtr_io.cb.din[pkt.sa] <= 1'b1;
    rtr_io.cb.valid_n[pkt.sa] <= 1'b1;
    repeat(5) @(rtr_io.cb);
  endtask: send_pad

  task send_payload();
    foreach(pkt.payload[index])
      for(int i=0; i<8; i++) begin
        rtr_io.cb.din[pkt.sa] <= pkt.payload[index][i];
        rtr_io.cb.valid_n[pkt.sa] <= 1'b0; //driving a valid bit
        rtr_io.cb.frame_n[pkt.sa] <= ((i == 7) && (index == (pkt.payload.size() - 1)));
        @(rtr_io.cb);
      end
    rtr_io.cb.valid_n[pkt.sa] <= 1'b1;
  endtask: send_payload

  task recv();
    //Add static int pkt_cnt before the call to get_payload()
    static int pkt_cnt = 0;
    
    get_payload();

    //Assign pkt2cmp.da with global da
    pkt2cmp.da = pkt.da;

    //Assign pkt2cmp.payload with pkt2cmp_payload
    pkt2cmp_payload = pkt.payload;

    //Set a unique name for pkt2cmp. Use pkt_cnt
    pkt2cmp.name = $sformatf("rcvdPkt[%0d]", pkt_cnt++);
  
  endtask: recv

  task get_payload();

    pkt2cmp_payload.delete();

    fork
      begin: wd_timer_fork
      fork: frameo_wd_timer
        //Do not use @(negedge rtr_io.cb.frameo_n[da]);
		    //This may cause timing issues because of how the LRM defines it.
        begin
          wait(rtr_io.cb.frameo_n[pkt.da] != 0);
          @(rtr_io.cb iff(rtr_io.cb.frameo_n[pkt.da] == 0 ));
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
        if(!rtr_io.cb.valido_n[pkt.da])
          datum[i++] = rtr_io.cb.dout[pkt.da];

        if(rtr_io.cb.frameo_n[pkt.da])
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
  endtask: get_payload

endprogram: test
