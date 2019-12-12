`timescale  1ns/100ps

module testbench_fifo_final();

reg				clock,rst_n,r_en,w_en;
reg		[63:0]	in_data;
reg		[1:0]	size;
wire	[31:0]	out_data;
wire			full,empty,overflow;
wire			valid_out;

integer i;

FIFO	FIFO_inst(    
	.clock(clock),
	.reset_n(rst_n),
	.w_en(w_en),
	.data_in(in_data),
	.r_en(r_en),
	.size(size),
	.data_out(out_data),
	.empty(empty),
	.full(full),
	.overflow(overflow),
	.valid_out(valid_out)
	);

initial//test signals status  after reset(full empty overflow)
begin
	in_data=0;
	r_en=0;
	w_en=0;
	clock=1;
	rst_n=0;
	size = 0;
	#5 rst_n=1;
	
	$display("\n\ninitial done\n\n");
	if({empty,full,overflow,valid_out}!=4'b1000)
	begin
		$display("\nerror at time %0t:",$time);
		$display("after reset,status not asserted\n");
		$display("empty = %b full = %b overflow = %b valid_out = %b\n",empty,full,overflow,valid_out);
		$stop;
	end
	else
	begin
		$display("initial status right\nempty = %b full = %b overflow = %b valid_out = %b\n",empty,full,overflow,valid_out);
	end
   #5;
   	//causing full
	for (i=1;i<33;i=i+1)
	begin
	   @(negedge clock) 
	   w_en=1; in_data=$urandom_range(0,9e18); size = 0;
		$display("storing %d  w_en=%d r_en=%d\n data_in=%d  size=%d",i,w_en,r_en,in_data,size);
	end
	@(negedge clock) w_en=0;
	#50;
	if({empty,full,overflow}!=3'b010)
	begin
		$display("\nerror at time %0t:",$time);
		$display("half_full\n");
		$display("empty = %b full = %b overflow = %b\n",empty,full,overflow);
		$stop;
	end
	else
	begin
		$display("half_full status right\nempty = %b full = %b  overflow = %b\n",empty,full,overflow);
	end

	#5 rst_n=0;
	#5 rst_n=1;

	//causing overflow
	for (i=1;i<80;i=i+1)
	begin
	   @(negedge clock) 
	   w_en=1;r_en=0; in_data=$urandom_range(0,9e18); size = $urandom_range(0,3);
		$display("storing %d  w_en=%d r_en=%d\n data_in=%d  size=%d",i,w_en,r_en,in_data,size);
	end
	@(negedge clock) w_en=0;
	#50;
	if({empty,full,overflow}!=3'b011)
	begin
		$display("\nerror at time %0t:",$time);
		$display("overflow\n");
		$display("empty = %b full = %b overflow = %b\n",empty,full,overflow);
		$stop;
	end
	else
	begin
		$display("overflow status right\nempty = %b full = %b  overflow = %b\n",empty,full,overflow);
	end

	#5 rst_n=0;
	#5 rst_n=1;

	//cause valid_out=0;
	@(negedge clock) w_en=1;r_en=1;
	#1;
	for (i=1;i<4;i=i+1)
	fork
	begin
	   @(negedge clock) 
	  	in_data=i; size = 0;
	end
	begin
	   @(posedge clock);
		$display("reading data %d, your data %d\n",i,out_data);
		if(valid_out!=0)
		begin
			$display("error!!!  valid_out should be zero!");
		$stop;
		end
	end
	join

		//causing overflow
	for (i=1;i<34;i=i+1)
	begin
	   @(negedge clock) 
	   w_en=1;r_en=0; in_data=$urandom_range(0,9e18); size = $urandom_range(0,3);
		$display("storing %d  w_en=%d r_en=%d\n data_in=%d  size=%d",i,w_en,r_en,in_data,size);
	end
	@(negedge clock) w_en=0;
	#50;
	@(negedge clock) r_en=1;
	#50;
	if({empty,full,overflow}!=3'b100)
	begin
		$display("\nerror at time %0t:",$time);
		$display("empty = %b full = %b overflow = %b\n",empty,full,overflow);
		$stop;
	end
	else
	begin
		$display("empty status right\nempty = %b full = %b  overflow = %b\n",empty,full,overflow);
	end

	begin
		$display("********************\ndone, without error\n********************\n");
		$stop;
	end
end



always #1 clock=~clock;



endmodule


