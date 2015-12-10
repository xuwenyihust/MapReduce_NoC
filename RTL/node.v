

module node(clk, rst, textfile, keyword, data_wr, key_en);
	
	parameter data_size = 32;
	
	input clk;
	input rst;
	
	input [data_size-1:0] textfile;							// Input textfile from Scheduler for mapper submodule
	input [data_size-1:0] keyword;							// Input keyword from Scheduler for mapper submodule	
	input data_wr;											// Informs that whether there are text sent from scheduler now(pulse).		  
	input key_en;											// Inform that whether there are keyword sent from scheduler now(keep high).
	
	
	// Inter-submodule signal
	wire [data_size-1:0] pair;								// Output (keyword) from mapper to reducer
	wire pair_out;											// Output keyword notation from mapper to reducer
	wire write_in;											// Input of reducer  pair_out @^#& write_in
	
	// The width of pair_out doesn't meet the requirement of write_in.
	// Must do sth to add 1 cycle to the width of pair_out.
	reg pair_out_reg;
	wire pair_out_ext;
	always@(posedge clk or rst)
		if(!rst)
			pair_out_reg <= 1'b0;
		else
			pair_out_reg <= pair_out;  

	assign pair_out_ext = pair_out|pair_out_reg;
	assign write_in = pair_out_ext;		
	
	
	wire write_free;
	
	// Instantiation
	mapper mapper0(
	.clk(clk),
	.rst(rst),
	.data_in_1(textfile),
	.keyword(keyword),
	.key_en(key_en),
	.data_wr(data_wr),
	// Indicates that scheduler can send data to the mapper now. 
	// Temporarily not connected
	.write_free(write_free),
	.pair(pair),
	.pair_out(pair_out)
	);
	
	reducer reducer0(
	.clk(clk),
	.rst(rst),
	.write_in(write_in),
	.pair_in(pair),
	.result()
	);
	
endmodule