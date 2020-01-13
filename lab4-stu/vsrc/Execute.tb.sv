program Execute_test(Execute_io.TB Execute, DUT_probe_if Prober);
	parameter   reg_wd    	=   `REGISTER_WIDTH;

	Generator  	generator;	// generator object
	Driver     	drvr;		// driver objects
	Scoreboard 	sb;			// scoreboard object
	Receiver 	rcvr;		// Receiver Object

	
	Packet 	pkt_sent = new();
	int 	number_packets;
	
	initial begin
		number_packets =1000;
        generator = new("Generator", number_packets);
		sb = new(); // NOTE THAT THERE ARE DEFAULT VALUES FOR THE NEW FUNCTION 
					// FOR THE SCOREBOARD 
		drvr = new("drvr[0]", generator.in_box, sb.driver_mbox, Execute);
		rcvr = new("rcvr[0]", sb.receiver_mbox, Execute, Prober);
		reset();
		generator.start();
		drvr.start(); 
		sb.start();
		rcvr.start();
    	repeat(number_packets+1) @(Execute.cb);
		$display($time, "WE ARE DONE .. GO HOME AND SLEEP!!! .. ACTUALLY NOT YET .. ");
  	end

	task reset();
		$display ($time, "ns:  [RESET]  Design Reset Start");
		Execute.reset 				<= 1'b1; 
	  	Execute.cb.enable_ex 		<= 1'b0; 
		repeat(5) @(Execute.cb);
		Execute.cb.enable_ex   	 	<= 1'b1;
		Execute.reset 				<= 1'b0;
		$display ($time, "ns:  [RESET]  Design Reset End");
	endtask
	
endprogram
