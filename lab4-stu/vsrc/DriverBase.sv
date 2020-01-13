//
class DriverBase;
	virtual   Execute_io.TB Execute;	
	string    name;		
	Packet    pkt2send;	

	reg	[6:0]					payload_control_in;
	reg	[`REGISTER_WIDTH-1:0]	payload_src1, payload_src2;
	reg	[`REGISTER_WIDTH-1:0]	payload_imm, payload_mem_data;
	reg							payload_enable;

	extern function new(string name = "DriverBase", virtual Execute_io.TB Execute);
	extern virtual task send();
	extern virtual task send_payload();
	
endclass

function DriverBase::new(string name = "DriverBase", virtual Execute_io.TB Execute);
	this.name   = name;
	this.Execute = Execute;
endfunction

task DriverBase::send();
	send_payload();
endtask

task DriverBase::send_payload();
	$display($time, "ns:  [DRIVER] Sending Payload Begin");
	
	Execute.cb.src1				<=	payload_src1;
	Execute.cb.src2				<=	payload_src2;
	Execute.cb.imm				<=	payload_imm;
	Execute.cb.mem_data_read_in	<=	payload_mem_data;
	Execute.cb.control_in 		<=  payload_control_in;
	Execute.cb.enable_ex		<=  payload_enable;
		
endtask
