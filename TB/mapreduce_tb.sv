`timescale 1ns/100ps
module mapreduce_tb;
	
	reg clk;
	reg rst; 
	reg scheduler_wen;
	
	
	
	
	always #5	clk = ~clk;
		
	initial begin
		clk = 0;
		rst = 1;
		scheduler_wen = 0;
		
		repeat(5) @(posedge clk);
		rst = 0;
		repeat(5) @(posedge clk);
		rst = 1; 
		repeat(10) @(posedge clk);
		scheduler_wen = 1;
		repeat(1) @(posedge clk);
		scheduler_wen = 0;
		repeat(50) @(posedge clk);
		
		
		
		$stop;
	end	
	
		
	/*initial begin
		@(posedge mapreduce0.mapper_router0.router0.fifoL.pop)
		$display("push = %b.", mapreduce0.mapper_router0.router0.fifoL.push);
		$display("counter = %d.", mapreduce0.mapper_router0.router0.fifoL.counter);	 
		
		@(negedge mapreduce0.mapper_router0.router0.fifoL.pop)
		$display("push = %b.", mapreduce0.mapper_router0.router0.fifoL.push);
		$display("counter = %d.", mapreduce0.mapper_router0.router0.fifoL.counter);	
		$display("counter_pre = %d.", mapreduce0.mapper_router0.router0.fifoL.counter_pre);
	end*/	
		

	
	mapreduce mapreduce0(
	.clk(clk),
	.rst(rst),
	.scheduler_wen(scheduler_wen)
	);
	
	
	
endmodule



