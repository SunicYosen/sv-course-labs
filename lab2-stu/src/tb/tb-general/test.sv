program automatic test(router_io.TB rtr_io);

  int        run_for_n_packets;     // number of packets to test
  bit  [3:0] sa;                    // source address
  bit  [3:0] da;                    // destination address
  logic[7:0] payload[$];            // expected packet data array
  logic[7:0] pkt2cmp_payload[$];    // actual packet data array


  initial 
  begin
    run_for_n_packets = 2000;      //the number of packets
  	reset();                       //subrouinte

    repeat(run_for_n_packets)
	  begin
      gen();  //call the gen() task.

      //Execute receive routine recv() concurrently with send()
      //followed by self-checking routine check()
      fork
        send();
        recv();
      join
        check();

    end
  
    // Advance simulation by 10 clocks
    // This will allow data coming out to be observed
    repeat(10) @rtr_io.cb;
  end

  //Define the reset() task
  task reset();
    $display($time, "ns : Reset Start ...");
    rtr_io.reset_n    <= 1'b0;
    rtr_io.cb.frame_n <=  '1;
    rtr_io.cb.valid_n <=  '1;

    repeat(2) @rtr_io.cb;
    rtr_io.cb.reset_n <= 1'b1;

    repeat(15) @rtr_io.cb;
    $display($time, "ns : Reset end.");
  endtask: reset

  //Define the gen() task
  task gen();
    $display($time, "ns : Gen Start ...");

    // Randomly generate sa and da
    sa = $urandom_range(-4,-6);
    da = $urandom_range(-5,-8);

    payload.delete();   //clear previous data

    repeat($urandom_range(4,2))
      payload.push_back($urandom);

    $display($time, "ns : Gen End.");

  endtask: gen

  //Define the send() task
  task send();
    send_addrs();
    send_pad();
    send_payload();
  endtask: send

  //Define the send_addrs() task
  task send_addrs();
    $display($time, "ns : Send Addrs Start ...");
    rtr_io.cb.frame_n[sa] <= 1'b0; //start of packet

    for(int i=0; i<4; i++)
    begin
      rtr_io.cb.din[sa] <= da[i];  //i'th bit of da
      @rtr_io.cb;
    end
    $display($time, "ns : Send Addrs End.");
  endtask: send_addrs

  //Define the send_pad() task
  //Define send_pad() task to drive some padding bits into router
  task send_pad();
    $display($time, "ns : Send Pad Start ...");
    rtr_io.cb.frame_n[sa] <= 1'b0;
    rtr_io.cb.din[sa]     <= 1'b1;
    rtr_io.cb.valid_n[sa] <= 1'b1;
    repeat(5) @rtr_io.cb;

    $display($time, "ns : Send Pad end.");
  endtask: send_pad

  //Define send_payload() task to drive payload(data) into port 'sa' of router
  task send_payload();
    $display($time, "ns : Send pay load start ...");
    
    //Write a loop to execute payload.size() number of times
    //In the loop, each 8-bit datum of payload[$] is transmitted 1 bit/clock
    //Remember to drive the valid bit, valid_n, of port 'sa' as per spec 
    //Make sure on last valid bit of payload[$], frame_n of port 'sa' is 1'b1 as per spec
    foreach(payload[index])
      for(int i=0; i<8; i++)
      begin
        rtr_io.cb.din[sa]     <= payload[index][i];
        rtr_io.cb.valid_n[sa] <= 1'b0;                //driving a valid bit
        rtr_io.cb.frame_n[sa] <= ((i == 7) && (index == (payload.size() - 1)));
        @rtr_io.cb;
      end
      
      rtr_io.cb.valid_n[sa] <= 1'b1;
      @rtr_io.cb;

      $display($time, "ns : Send pay load end.");
  endtask: send_payload


  //Declare the recv() task
  task recv();
    // In recv() task call get_payload() to retrieve payload.
    get_payload();
  endtask: recv


  //Declare the get_payload() task
  task get_payload();

    //In get_payload() delete content of pkt2cmp_payload[$]
    pkt2cmp_payload.delete();


    //Continuing in get_payload() wait for falling edge of output frame signal
	  //Implement a watchdog timer of 1000 clocks
    fork
      begin: wd_timer_fork
      fork: frameo_wd_timer
        //Do not use @(negedge rtr_io.cb.frameo_n[da]);
		    //This may cause timing issues because of how the LRM defines it.
		    
        begin
		      wait(rtr_io.cb.frameo_n[da] != 0);
		      @(rtr_io.cb iff(rtr_io.cb.frameo_n[da] == 0 ));
		    end
        
        begin                              //this is another thread
          repeat(1000) @rtr_io.cb;
      	  $display("\n%m\n[ERROR]%t Frame signal timed out!\n", $realtime);
          $finish;
        end
        join_any: frameo_wd_timer
        disable fork;
      end: wd_timer_fork

    join

    //Continuing in get_payload() sample output of the router:
    //Loop until end of frame is detected.
    //Within the loop, assemble a byte of data at a time(8 clocks)
    //Store each byte in pkt2cmp_payload[$]
    forever 
    begin
      logic[7:0] datum;
      for(int i=0; i<8; i=i+1)
      begin 
        $display($time, "i");
        if(!rtr_io.cb.valido_n[da])
          datum[i] = rtr_io.cb.dout[da];

        if(rtr_io.cb.frameo_n[da])
          if(i==8) begin // byte alligned
      	    pkt2cmp_payload.push_back(datum);
      	    return;      // done with payload
      	  end

          //If payload is not byte aligned, print message and end simulation
      	  else begin
      	    $display("\n%m\n[ERROR]%t Packet payload not byte aligned!\n", $realtime);
      	    $finish;
      	  end
        @rtr_io.cb;
      end
      pkt2cmp_payload.push_back(datum);
    end
  endtask: get_payload

  //Create function compare() which returns single bit
  //and has pass-by-reference string argument
  function bit compare(ref string message);

    //In compare() compare data payload[$] with pkt2cmp_payload[$]
    //If sizes do not match
    //   set string argument with description of error
    //   terminate subroutine by returning a 0
    //
    //If data matches (you can directly compare arrays using ==)
    //   set string argument with description of success
    //   terminate subroutine successfully by returning a 1
    //
    //If data does not match
    //   set string argument with description of error
    //   terminate subroutine by returning a 0
    if(payload.size() != pkt2cmp_payload.size()) 
    begin
      message = "Payload size Mismatch:\n";
      message = { message, $sformatf("payload.size() = %0d, pkt2cmp_payload.size() = %0d\n", payload.size(), pkt2cmp_payload.size()) };
      return (0);
    end

    if(payload == pkt2cmp_payload) ;

    else 
    begin
      message = "Payload Content Mismatch:\n";
      message = { message, $sformatf("Packet Sent:   %p\nPkt Received:   %p", payload, pkt2cmp_payload) };
      return (0);
    end

    message = "Successfully Compared";
    return(1);
  endfunction: compare


  //Create function called check()
  function void check();

    //In check() declare a string variable message
    //keep a count of packets checked with variable pkts_checked
    string message;
    static int pkts_checked = 0;


    //In check() call compare() to check the packet received
    //If error detected print error message and end simulation
    //If successful print message indicating number of packets checked
    if (!compare(message)) 
    begin
      $display("\n%m\n[ERROR]%t Packet #%0d %s\n", $realtime, pkts_checked, message);
      $finish;
    end

    $display("[NOTE]%t Packet #%0d %s", $realtime, pkts_checked++, message);
  endfunction: check

endprogram: test
