module node_router(clk, rst, Data_in_N, Data_in_S, Data_in_W, Data_in_E, Data_in_ready_N, Data_in_ready_S, Data_in_ready_W,
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
	
	input [1:0] noc_locationx;
	input [1:0] noc_locationy;
	
	input [WIDTH-1:0] Data_in_N; 
	input [WIDTH-1:0] Data_in_S; 
	input [WIDTH-1:0] Data_in_W; 
	input [WIDTH-1:0] Data_in_E;
	//input [WIDTH-1:0] Data_in_L;
	
	input Data_in_ready_N;
	input Data_in_ready_S;
	input Data_in_ready_W;
	input Data_in_ready_E;
	//input Data_in_ready_L; 
	
	output [WIDTH-1:0] Data_out_N; 
	output [WIDTH-1:0] Data_out_S; 
	output [WIDTH-1:0] Data_out_W; 
	output [WIDTH-1:0] Data_out_E;
	//output [WIDTH-1:0] Data_out_L;
	
	output Data_out_ready_N;
	output Data_out_ready_E;
	output Data_out_ready_S;
	output Data_out_ready_W;
	//output Data_out_ready_L;
	

	input Data_in_valid_N;
	input Data_in_valid_E;
	input Data_in_valid_S;
	input Data_in_valid_W;	   
	
	output Data_out_valid_N;
	output Data_out_valid_E;
	output Data_out_valid_S;
	output Data_out_valid_W;
	
	wire [4:0] Data_out_valid;
	wire Valid_router2node;
	assign Data_out_valid_N = Data_out_valid[0];
	assign Data_out_valid_E = Data_out_valid[1] ;
	assign Data_out_valid_S = Data_out_valid[2] ;
	assign Data_out_valid_W = Data_out_valid[3] ; 
	assign Valid_router2node = Data_out_valid[4];
	// Data_out_valid[4] should connect to the enbalein of PE
	
	wire [31:0] Data_router2node;
	wire [WIDTH-1:0] Data_router2node_36;
	wire [31:0] Data_node2router; 
	wire [WIDTH-1:0] Data_node2router_36;
	wire Ready_router2node;
	wire Ready_node2router; 
	wire Valid_node2router;
	
	wire [5*WIDTH-1:0] Data_out;
	assign Data_out_N = Data_out[WIDTH-1:0];
	assign Data_out_E = Data_out[2*WIDTH-1:WIDTH]; 
	assign Data_out_S = Data_out[3*WIDTH-1:2*WIDTH];  
	assign Data_out_W =	Data_out[4*WIDTH-1:3*WIDTH];
	assign Data_router2node_36 =	Data_out[5*WIDTH-1:4*WIDTH];
	assign Data_router2node = Data_router2node_36[35:4];
	
	wire [4:0] Data_out_ready;
	assign Data_out_ready[0] = Data_out_ready_N;
	assign Data_out_ready[1] = Data_out_ready_E;
	assign Data_out_ready[2] = Data_out_ready_S;
	assign Data_out_ready[3] = Data_out_ready_W; 
	assign Data_out_ready[4] = Ready_router2node;
		
	wire [5*WIDTH-1:0] Data_in;
	assign Data_in[WIDTH-1:0] = Data_in_N;
	assign Data_in[2*WIDTH-1:WIDTH] = Data_in_E;
	assign Data_in[3*WIDTH-1:2*WIDTH] = Data_in_S;
	assign Data_in[4*WIDTH-1:3*WIDTH] = Data_in_W;
	assign Data_in[5*WIDTH-1:4*WIDTH] = Data_node2router_36;
	assign Data_node2router_36[35:4] = Data_node2router;
	// Reducer location: 1101
	assign Data_node2router_36[3:0] = (Valid_node2router==1 && (Data_node2router!=0))?4'b1101:4'b0000;
	
	wire [4:0] Data_in_valid;
	//assign Data_in_valid[4]
	assign Data_in_valid[0] = Data_in_valid_N; 
	assign Data_in_valid[1] = Data_in_valid_E;
	assign Data_in_valid[2] = Data_in_valid_S;
	assign Data_in_valid[3] = Data_in_valid_W;
	// Attention
	assign Data_in_valid[4] = Valid_node2router; 
	
	
	//Connect to 'bustorouter_ready' of router
	wire [4:0] Data_in_ready;
	assign Data_in_ready[0] = Data_in_ready_N;
	assign Data_in_ready[1] = Data_in_ready_E;
	assign Data_in_ready[2] = Data_in_ready_S;
	assign Data_in_ready[3] = Data_in_ready_W;
	assign Data_in_ready[4] = Ready_node2router; 
	// Attention
	//assign Ready_mapper2router = !Valid_mapper2router;
	assign Ready_node2router = 1'bz;
	
	

	
	
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
	
	node_noc node_noc0(
	.clk(clk),
	.rst(rst),
	.data_in(Data_router2node),
	.data_in_ready(Data_in_valid_W),
	.fifo_in_ready(1'b1),
	.data_out(Data_node2router),
	.data_out_ready(data_out_ready)
	);
	
	
endmodule