`timescale 1ns/100ps
module node_tb;
	
	reg clk;
	reg rst;
	
	parameter data_size = 32;
	
	reg [data_size-1:0] textfile;
	reg data_wr;   
	reg [data_size-1:0] keyword; 
	reg key_en;
	 
	
	
	always #5	clk = ~clk;
	
	initial begin
		clk = 0;
		rst = 1;  
		key_en = 0;
		data_wr = 0;
		repeat(10) @(posedge clk);
		rst = 0;
		repeat(10) @(posedge clk);
		rst = 1;   
		
		repeat(10) @(posedge clk);
		fork
		
		// Write data
		begin
			
			repeat(4) @(posedge clk);
			
			write_data(32'h79656854);
				 
			repeat(6) @(posedge clk);
			write_data(32'h6e657720); 				
 
			repeat(6) @(posedge clk);
			write_data(32'h68742074); 
				
			repeat(6) @(posedge clk);
			write_data(32'h65736d65); 
			
			repeat(6) @(posedge clk);
			write_data(32'h7365766c); 	
			
			repeat(6) @(posedge clk);
			write_data(32'h6854202e);
			
			repeat(6) @(posedge clk);
			write_data(32'h74207965);
			
			repeat(6) @(posedge clk);
			write_data(32'h736d6568);
			
			repeat(6) @(posedge clk);
			write_data(32'h65766c65);
			
			repeat(6) @(posedge clk);
			write_data(32'h616d2073);
			
			repeat(6) @(posedge clk);
			write_data(32'h74206564);
			
			repeat(6) @(posedge clk);
			write_data(32'h64206568);
			
			repeat(6) @(posedge clk);
			write_data(32'h73696365);
			
			repeat(6) @(posedge clk);
			write_data(32'h2c6e6f69);
			
			repeat(6) @(posedge clk);
			write_data(32'h65687420);
			
			repeat(6) @(posedge clk);
			write_data(32'h75682079);
			
			repeat(6) @(posedge clk);
			write_data(32'h74207472);
			
			repeat(6) @(posedge clk);
			write_data(32'h736d6568); 
			
			repeat(6) @(posedge clk);
			write_data(32'h65766c65);
			
			repeat(6) @(posedge clk);
			write_data(32'h00002e73);
			
			repeat(50) @(posedge clk);		
		end	 
		begin
			write_keyword;
		end
		join
		
		$stop;
	end
	
	task write_data; 
	input [data_size-1:0] input_data;
	data_wr = 1'b1;
	textfile = input_data;	
	@(posedge clk) data_wr = 1'b0; 
	endtask
		
	task write_keyword;
	key_en = 1;
	keyword = 32'h6d656874;
	@(posedge clk);
	keyword = 32'h766c6573;	
	@(posedge clk);
	keyword = 32'h00007365;	   
	@(posedge clk);
	keyword = 32'h00000000;	
	@(posedge clk);
	key_en = 0;
	endtask

	
	// DUT Instantiation
	node node0(
	.clk(clk),
	.rst(rst),
	.textfile(textfile),
	.keyword(keyword),
	.data_wr(data_wr),
	.key_en(key_en));
	
endmodule