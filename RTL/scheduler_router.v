module scheduler_router(clk, rst, wen, Data_in_N, Data_in_S, Data_in_W, Data_in_E, Data_in_ready_N, Data_in_ready_S, Data_in_ready_W,
	Data_in_ready_E, Data_out_N, Data_out_S, Data_out_W, Data_out_E,
	Data_out_ready_N, Data_out_ready_S, Data_out_ready_W, Data_out_ready_E,	
	Data_out_valid_N, Data_out_valid_S, Data_out_valid_W, Data_out_valid_E, 
	Data_in_valid_N, Data_in_valid_E, Data_in_valid_S, Data_in_valid_W,
	noc_locationx, noc_locationy); 
	
	parameter WIDTH=36;
	parameter DEPTH=8;
	parameter ADDR=4;
	parameter lhsCount=5;
	parameter rhsCount=5;
	
	input clk;
	input rst;	
	input wen;
	
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
	
	input [1:0] noc_locationx;
	input [1:0] noc_locationy;
	
	input Data_in_valid_N;
	input Data_in_valid_E;
	input Data_in_valid_S;
	input Data_in_valid_W;
	wire [4:0] Data_in_valid; 
	assign Data_in_valid[0] = Data_in_valid_N;
	assign Data_in_valid[1] = Data_in_valid_E;
	assign Data_in_valid[2] = Data_in_valid_S;
	assign Data_in_valid[3] = Data_in_valid_W;
	
	wire [31:0] Data_router2scheduler;
	wire [WIDTH-1:0] Data_scheduler2router;  
	wire Ready_router2scheduler;
	wire Ready_scheduler2router;
	
	wire [5*WIDTH-1:0] Data_out;
	assign Data_out_N = Data_out[WIDTH-1:0];
	assign Data_out_E = Data_out[2*WIDTH-1:WIDTH]; 
	assign Data_out_S = Data_out[3*WIDTH-1:2*WIDTH];  
	assign Data_out_W =	Data_out[4*WIDTH-1:3*WIDTH];
	assign Data_router2scheduler =	Data_out[5*WIDTH-1:4*WIDTH+4];
	
	wire [4:0] Data_out_ready;
	assign Data_out_ready[0] = Data_out_ready_N;
	assign Data_out_ready[1] = Data_out_ready_E;
	assign Data_out_ready[2] = Data_out_ready_S;
	assign Data_out_ready[3] = Data_out_ready_W; 
	//assign Data_out_ready[4] = 1;
	//assign Ready_router2scheduler = 1;
	
	wire [4:0] Data_out_valid;
	assign Data_out_valid_N = Data_out_valid[0];
	assign Data_out_valid_E = Data_out_valid[1] ;
	assign Data_out_valid_S = Data_out_valid[2] ;
	assign Data_out_valid_W = Data_out_valid[3] ;  
	wire Valid_router2scheduler;
	assign Valid_router2scheduler = Data_out_valid[4];
	//assign Data_out_valid[4] = Ready_router2scheduler; 	
	
	/*
	reg [4:0] Data_out_ready;  
	always@* begin
		Data_out_ready[0] = Data_out_ready_N;
		Data_out_ready[1] = Data_out_ready_E;
		Data_out_ready[2] = Data_out_ready_S;
		Data_out_ready[3] = Data_out_ready_W; 
		Data_out_ready[4] = Ready_router2scheduler;
	end
	
	reg [4:0] Data_out_valid; 
	always@* begin
		Data_out_valid[0] = Data_out_valid_N;
		Data_out_valid[1] = Data_out_valid_E;
		Data_out_valid[2] = Data_out_valid_S;
		Data_out_valid[3] = Data_out_valid_W; 
	//assign Data_out_valid[4] = Ready_router2scheduler; 
	end
	*/
		
	wire [5*WIDTH-1:0] Data_in;
	assign Data_in[WIDTH-1:0] = Data_in_N;
	assign Data_in[2*WIDTH-1:WIDTH] = Data_in_E;
	assign Data_in[3*WIDTH-1:2*WIDTH] = Data_in_S;
	assign Data_in[4*WIDTH-1:3*WIDTH] = Data_in_W;
	assign Data_in[5*WIDTH-1:4*WIDTH] = Data_scheduler2router; 
	
	
	//Connect to 'bustorouter_ready' of router
	wire [4:0] Data_in_ready;
	assign Data_in_ready[0] = Data_in_ready_N;
	assign Data_in_ready[1] = Data_in_ready_E;
	assign Data_in_ready[2] = Data_in_ready_S;
	assign Data_in_ready[3] = Data_in_ready_W;
	//assign Data_in_ready[4] = Ready_scheduler2router;
	
	

	
	
	
	scheduler1 sch0(
	.clk(clk),
	.reset(rst),
	.wen(wen),
	.enablein(Valid_router2scheduler),
	.datain(Data_router2scheduler),
	.dataout(Data_scheduler2router),
	.full(),
	.empty(),
	.enableout(Ready_scheduler2router));
	
	router router0(
	.clk(clk),
	.reset_b(rst),
	.bustorouter_data(Data_in),	
	.bustorouter_ready(Data_in_ready), 
	// Input
	.bustorouter_valid(Data_in_valid),
	.X(noc_locationx),
	.Y(noc_locationy),
	.routertobus_data(Data_out),
	.routertobus_ready(Data_out_ready),
	.routertobus_valid(Data_out_valid)
	);
	
	
endmodule