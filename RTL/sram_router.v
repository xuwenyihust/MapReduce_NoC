module sram_router(clk, rst, Data_in_N, Data_in_S, Data_in_W, Data_in_E, Data_in_ready_N, Data_in_ready_S, Data_in_ready_W,
	Data_in_ready_E, Data_out_N, Data_out_S, Data_out_W, Data_out_E,
	Data_out_ready_N, Data_out_ready_S, Data_out_ready_W, Data_out_ready_E,	 
	Data_in_valid_N, Data_in_valid_E, Data_in_valid_S, Data_in_valid_W,  
	Data_out_valid_N, Data_out_valid_S, Data_out_valid_W, Data_out_valid_E,
	noc_locationx, noc_locationy);
	
	parameter WIDTH=36;
	parameter DEPTH=8;
	parameter ADDR=4;
	parameter lhsCount=5;
	parameter rhsCount=5;
	
	input clk;
	input rst;
	
	input [WIDTH-1:0] Data_in_N; 
	input [WIDTH-1:0] Data_in_E; 
	input [WIDTH-1:0] Data_in_S; 
	input [WIDTH-1:0] Data_in_W;
	//input [WIDTH-1:0] Data_in_L;
	
	input Data_in_ready_N;
	input Data_in_ready_E;
	input Data_in_ready_S;
	input Data_in_ready_W;
	//input Data_in_ready_L; 
	
	input Data_in_valid_N;
	input Data_in_valid_E;
	input Data_in_valid_S;
	input Data_in_valid_W;
	
	input [1:0] noc_locationx;
	input [1:0] noc_locationy;
	
	output [WIDTH-1:0] Data_out_N; 
	output [WIDTH-1:0] Data_out_E; 
	output [WIDTH-1:0] Data_out_S; 
	output [WIDTH-1:0] Data_out_W;
	//output [WIDTH-1:0] Data_out_L;
	
	output Data_out_ready_N;
	output Data_out_ready_E;
	output Data_out_ready_S;
	output Data_out_ready_W;
	//output Data_out_ready_L;	
	
	output Data_out_valid_N;
	output Data_out_valid_E;
	output Data_out_valid_S;
	output Data_out_valid_W;
	
	
	wire sram_out_en;
	wire [4:0] Data_in_valid;
	assign Data_in_valid[4] = sram_out_en;
	assign Data_in_valid[3] = Data_in_valid_W;	   
	assign Data_in_valid[2] = Data_in_valid_S;
	assign Data_in_valid[1] = Data_in_valid_E;
	assign Data_in_valid[0] = Data_in_valid_N;
	
	wire [WIDTH-1:0] Data_router2sram;
	wire [WIDTH-1:0] Data_sram2router;  
	wire Ready_router2sram;
	wire Ready_sram2router;

	
	wire [5*WIDTH-1:0] Data_out;
	assign Data_out_N = Data_out[WIDTH-1:0];
	assign Data_out_E = Data_out[2*WIDTH-1:WIDTH]; 
	assign Data_out_S = Data_out[3*WIDTH-1:2*WIDTH];  
	assign Data_out_W =	Data_out[4*WIDTH-1:3*WIDTH];
	assign Data_router2sram =	Data_out[5*WIDTH-1:4*WIDTH];
	
	wire [4:0] Data_out_ready;
	assign Data_out_ready[0] = Data_out_ready_N;
	assign Data_out_ready[1] = Data_out_ready_E;
	assign Data_out_ready[2] = Data_out_ready_S;
	assign Data_out_ready[3] = Data_out_ready_W; 
	assign Data_out_ready[4] = Ready_router2sram;
	
	wire [4:0] Data_out_valid;
	assign Data_out_valid_N = Data_out_valid[0];
	assign Data_out_valid_E = Data_out_valid[1] ;
	assign Data_out_valid_S = Data_out_valid[2] ;
	assign Data_out_valid_W = Data_out_valid[3] ;
	
	
	wire [5*WIDTH-1:0] Data_in;
	assign Data_in[WIDTH-1:0] = Data_in_N;
	assign Data_in[2*WIDTH-1:WIDTH] = Data_in_E;
	assign Data_in[3*WIDTH-1:2*WIDTH] = Data_in_S;
	assign Data_in[4*WIDTH-1:3*WIDTH] = Data_in_W;
	assign Data_in[5*WIDTH-1:4*WIDTH] = Data_sram2router; 
	
	/*reg [5*WIDTH-1:0] Data_in;
	always@*
		begin
		Data_in[WIDTH-1:0] = Data_in_N;
		Data_in[2*WIDTH-1:WIDTH] = Data_in_S;
		Data_in[3*WIDTH-1:2*WIDTH] = Data_in_W;
		Data_in[4*WIDTH-1:3*WIDTH] = Data_in_E;
		Data_in[5*WIDTH-1:4*WIDTH] = Data_sram2router; 
		end	*/
	
	//Connect to 'bustorouter_ready' of router
	wire [4:0] Data_in_ready;
	assign Data_in_ready[0] = Data_in_ready_N;
	assign Data_in_ready[1] = Data_in_ready_E;
	assign Data_in_ready[2] = Data_in_ready_S;
	assign Data_in_ready[3] = Data_in_ready_W;
	//assign Data_in_ready[4] = Ready_sram2router; 	
	
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	assign Data_in_ready[4] = !Data_in_valid_E;
	//assign Data_in_ready[4] = 0;
	
   	//wire routertobus_valid;
	wire sram_read_en;
	assign sram_read_en = Data_out_valid[4];
	

	
	
	router router0(
	.clk(clk),
	.reset_b(rst),
	.bustorouter_data(Data_in),	
	.bustorouter_ready(Data_in_ready),
	.bustorouter_valid(Data_in_valid),
	.X(noc_locationx),
	.Y(noc_locationy),
	.routertobus_data(Data_out),
	.routertobus_ready(),
	.routertobus_valid(Data_out_valid)		 
	); 
	
	sram sram0(
	.clk(clk),
	.rst(rst),  
	.address(Data_router2sram),
	.data(Data_sram2router),
	.read_en(sram_read_en),
	.out_en(sram_out_en)
	// Data_router2sram
	
	// Ready_router2sram
	);
	
	
endmodule