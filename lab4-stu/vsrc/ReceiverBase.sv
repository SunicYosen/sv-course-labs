class ReceiverBase;
	virtual Execute_io.TB Execute;	// interface signals
	virtual DUT_probe_if Prober;	// interface signals
	string   name;		// unique identifier
	
	OutputPacket   pkt_cmp;		// actual Packet object
	
	reg	[`REGISTER_WIDTH-1:0] 	aluout_cmp;
	reg 				carry_out_cmp;
	reg				 	mem_en_cmp;
	reg	[`REGISTER_WIDTH-1:0] 	memout_cmp;
	
	reg	[`REGISTER_WIDTH-1:0]	aluin1_cmp, aluin2_cmp; 
	reg	[2:0]			opselect_cmp;
	reg	[2:0]			operation_cmp;	
	reg	[4:0]          	shift_number_cmp;
	reg					enable_shift_cmp, enable_arith_cmp;
	reg		enable_cmp;
	int pkt_cnt = 0;
	

	extern function new(string name = "ReceiverBase", virtual Execute_io.TB Execute, virtual DUT_probe_if Prober);
	extern virtual task recv();
	extern virtual task get_payload();
	extern virtual task get_memdout();
endclass

function ReceiverBase::new(string name = "ReceiverBase", virtual Execute_io.TB Execute, virtual DUT_probe_if Prober);
	this.name = name;
	this.Execute = Execute;
	this.Prober = Prober;
	pkt_cmp = new();
endfunction

task ReceiverBase::recv();
	get_payload();
	
	pkt_cmp.name = $psprintf("rcvdPkt[%0d]", pkt_cnt++);
	
	pkt_cmp.aluout = aluout_cmp;
	pkt_cmp.carry_out=carry_out_cmp;
	pkt_cmp.mem_write_en = mem_en_cmp;
	pkt_cmp.mem_data_write_out = memout_cmp;
	
	pkt_cmp.aluin1 = aluin1_cmp; 
	pkt_cmp.aluin2 = aluin2_cmp; 	
	pkt_cmp.opselect = opselect_cmp;
	pkt_cmp.operation = operation_cmp;	
	pkt_cmp.shift_number = shift_number_cmp;
	pkt_cmp.enable_shift = enable_shift_cmp; 
	pkt_cmp.enable_arith = enable_arith_cmp;
	pkt_cmp.enable = enable_cmp;

	
endtask


/*
 * Task to get the Mem Write Out puts 
 * These are treated specially as these outputs are asynchronously created
 *
 */
task ReceiverBase:: get_memdout();

	memout_cmp = Execute.cb.mem_data_write_out;
	mem_en_cmp = Execute.cb.mem_write_en;

endtask





task ReceiverBase::get_payload();
	aluout_cmp = Execute.cb.aluout;
	//mem_en_cmp = Execute.cb.mem_write_en;
	//memout_cmp = Execute.cb.mem_data_write_out;
	carry_out_cmp=Execute.cb.carry;    

	// get the internals signals of the DUT as well 
	aluin1_cmp = Prober.cb.aluin1; 
	aluin2_cmp = Prober.cb.aluin2; 
	opselect_cmp = Prober.cb.opselect;
	operation_cmp = Prober.cb.operation;	
	shift_number_cmp = Prober.cb.shift_number;
	enable_shift_cmp = Prober.cb.enable_shift; 
	enable_arith_cmp = Prober.cb.enable_arith;

	// this is a bad example because there are no constructs of variable time for completion
	 //at the negative edge of the the next clock the output should be stable
endtask
