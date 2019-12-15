`include "Generator.sv"
`include "Driver.sv"
`include "Receiver.sv"
`include "Scoreboard.sv"

/* Program TEST Module : Wrapper of test.
 * Note: 
 */ 

program automatic test(router_io.TB rtr_io);
  int I_PORTS_NUM       = 16;       // INPUT Ports
  int O_PORTS_NUM       = 16;       // Ouput ports
  int run_for_n_packets = 2000;     // number of packets to test
  int run_times[];                  // process of each port

  logic [7:0] pkt2cmp_payload[$];   // actual packet data array
  Packet      pkt[];                // Pkt get from gen to driver for each port.
  Packet      pkt2cmp = new();      // Declare and construct two Packets pkt2send and pkt2cmp
  
  Generator   gen[];                // Generator for each port
  Driver      driver[];             // Driver for each port
  Receiver    receiver[];           // Receiver for each output port
  Scoreboard  scoreboard[];

  initial 
  begin
    run_times = new[I_PORTS_NUM];     // new 
    pkt       = new[I_PORTS_NUM];     // Input packets
    gen       = new[I_PORTS_NUM];     // gen input ports Generator
    driver    = new[I_PORTS_NUM];     // new driver
    receiver  = new[O_PORTS_NUM];     // new receiver
    scoreboard= new[O_PORTS_NUM];     // new scoreboard

    foreach (run_times[i]) run_times[i] = 0; // Init runtimes for each input ports.

    reset();  //Reset.
    foreach (gen[i])    gen[i] = new($sformatf("gen[%0d]", i), i);    // initial generator object for each input ports.
    foreach (gen[i])    gen[i].start();   // Start Generator

    foreach (driver[i]) driver[i] = new($sformatf("driver[%0d]", i), rtr_io, gen[i].out_box);  // initial driver objects for each input port.
    foreach (receiver[i]) receiver[i] = new($sformatf("receiver[%0d]", i), rtr_io, i); // Initial Receiver object for each output port.
    foreach (scoreboard[i])  scoreboard[i] = new($sformatf("scoreboard[%0d]", i));     // Initial Socoreboard object for each output port.

    foreach (driver[i])   // Driver input ports one by one
    begin  
      fork                // fork for each port.
        automatic int port_i = i;  // Record which input port in this process.
        repeat(run_for_n_packets)  // Number of packets for each port.
        begin
          $display("-------------------port%3d: %4d/%4d-------------------", port_i, run_times[port_i]+1, run_for_n_packets);

          begin
            driver[port_i].get_packet();    // Get packet from generator first.
            driver[port_i].set_lock();      // Lock output semaphore
            
            fork  // fork for send and receive&check.
              begin
                $display("From %2d To %2d", driver[port_i].pkt_from_gen.sa, driver[port_i].pkt_from_gen.da);
                driver[port_i].packet_to_check();   // Send packet to scoreboard class
                driver[port_i].send();              // Send data to dut
              end
              
              begin
                receiver[driver[port_i].pkt_from_gen.da].recv();  // Read from DUT's output
                scoreboard[driver[port_i].pkt_from_gen.da].driver_mbox   = driver[port_i].out_box_to_check; // Set Scoreboard object driver mailbox.
                scoreboard[driver[port_i].pkt_from_gen.da].receiver_mbox = receiver[driver[port_i].pkt_from_gen.da].out_box_to_check; // Set Scoreboard object receiver mailbox
                scoreboard[driver[port_i].pkt_from_gen.da].check(); // Check and compare.
              end

            join

            driver[port_i].release_lock();   // Release the semaphore of output port 
          end

          run_times[port_i] ++; // Record runtimes for each input port.
        end

      join_none // non-blocking thread
    end

    wait fork;  // wait for all forked threads in current scope to end
    
    repeat(10) @(rtr_io.cb);
    $display("Score: %d/%d", scoreboard[0].scores, run_for_n_packets * I_PORTS_NUM );  // Show Scores.
    $finish;
  end
  
  // Reset task
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

endprogram: test
