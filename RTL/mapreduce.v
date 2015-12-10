//	4	3	2	1	0
//	L	W	S	E	N

// sram: 		x: 00	y: 10 
// scheduler:	x: 00	y: 01

module mapreduce(clk, rst, scheduler_wen);
	
	parameter WIDTH=36;
	parameter DEPTH=8;
	parameter ADDR=4;
	parameter lhsCount=5;
	parameter rhsCount=5;
	
	
	input clk;
	input rst;	 	 
	// Start the scheduler from the outside.
	// Since the scheduler is the trigger of the whole system, thus start the whole system.
	input scheduler_wen;
	
	// For version 0.0, the communication is only:
	// from scheduler to sram
	// from sram to scheduler
	// from scheduler to mapper
	// from mapper to reducer
	wire [WIDTH-1:0] link_sramtoscheduler;
	wire [WIDTH-1:0] link_schedulertosram; 
	wire [WIDTH-1:0] link_schedulertonode;
	wire [WIDTH-1:0] link_nodetoreducer; 
	

	

	// Define the locations of each submodule
	reg [1:0] sram_locationx;
	reg [1:0] sram_locationy;
	reg [1:0] scheduler_locationx;
	reg [1:0] scheduler_locationy;
	reg [1:0] node_locationx;
	reg [1:0] node_locationy;
	reg [1:0] reducer_locationx;
	reg [1:0] reducer_locationy;  
	
	wire [4:0] scheduler_valid_in_0; 
	reg [4:0] scheduler_valid_in_1;	 
	reg [4:0] scheduler_valid_in_2;

	// Modulate the timing		 
	// Delay the input to scheduler_valide_in_L.
	assign scheduler_valid_in_0[4] = scheduler_router0.sch0.enableout; 
	always@(posedge clk or negedge rst)
		if(!rst)
			scheduler_valid_in_1 <= 5'd0;
		else
			scheduler_valid_in_1 <= scheduler_valid_in_0;
	
	always@(posedge clk or negedge rst)
		if(!rst)
			scheduler_valid_in_2 <= 5'd0;
		else
			scheduler_valid_in_2 <= scheduler_valid_in_1;
	
			
	wire scheduler_valid_in_N;	
	wire scheduler_valid_in_S;
	wire scheduler_valid_in_W;
	wire scheduler_valid_in_E;
	
	assign scheduler_router0.Data_in_valid[4] = scheduler_valid_in_1[4];
	
	// Valid_in Definitions
	wire sram_valid_in_N;
	wire sram_valid_in_S;
	wire sram_valid_in_W;
	wire sram_valid_in_E; 
	wire node_valid_in_N;	  
	wire node_valid_in_S;
	wire node_valid_in_W;
	wire node_valid_in_E;	 
	
	// Valid_out Definitions
	wire scheduler_valid_out_N;	
	wire scheduler_valid_out_S;
	wire scheduler_valid_out_W;
	wire scheduler_valid_out_E;	
	wire sram_valid_out_N;
	wire sram_valid_out_S;
	wire sram_valid_out_W;
	wire sram_valid_out_E; 
	wire node_valid_out_N;
	wire node_valid_out_S;
	wire node_valid_out_W;
	wire node_valid_out_E;
	
	// Cross-router valid signal connection. 
	assign scheduler_valid_in_W = sram_valid_out_E;
	assign scheduler_valid_in_S = 0; 
	assign scheduler_valid_in_E = 0;
	assign scheduler_valid_in_N = 0;	
	
	assign sram_valid_in_W = 0;
	assign sram_valid_in_S = 0;
	assign sram_valid_in_E = scheduler_valid_out_W;	
	assign sram_valid_in_N = 0;
	
	assign node_valid_in_W = scheduler_valid_out_E; 	 
	assign node_valid_in_S = 0;
	assign node_valid_in_E = 0;
	assign node_valid_in_N = 0;  
	
	
	
	// PE locations.
	always@*
		if(!rst) begin 
			sram_locationx = 2'b00;
			sram_locationy = 2'b01;	
			scheduler_locationx = 2'b01;
			scheduler_locationy = 2'b01;  
			node_locationx = 2'b10;
			node_locationy = 2'b01;
		end
		else begin
			sram_locationx = 2'b00;
			sram_locationy = 2'b01;
			scheduler_locationx = 2'b01;
			scheduler_locationy = 2'b01;
			node_locationx = 2'b10;
			node_locationy = 2'b01; 
		end
	
	
	
	// Instantiations	
	sram_router sram_router0(
	.clk(clk),
	.rst(rst),
	.Data_in_N(),
	.Data_in_S(),
	.Data_in_W(),
	.Data_in_E(link_schedulertosram),
	.Data_in_ready_N(),
	.Data_in_ready_S(),
	.Data_in_ready_W(),
	.Data_in_ready_E(),
	.Data_out_N(),
	.Data_out_S(),
	.Data_out_W(),
	.Data_out_E(link_sramtoscheduler),
	.Data_out_ready_N(),
	.Data_out_ready_S(),
	.Data_out_ready_W(),
	.Data_out_ready_E(),	   
	.Data_in_valid_N(sram_valid_in_N),
	.Data_in_valid_S(sram_valid_in_S),
	.Data_in_valid_W(sram_valid_in_W),
	.Data_in_valid_E(sram_valid_in_E),
	.Data_out_valid_N(sram_valid_out_N),
	.Data_out_valid_S(sram_valid_out_S),
	.Data_out_valid_W(sram_valid_out_W),
	.Data_out_valid_E(sram_valid_out_E),
	.noc_locationx(sram_locationx),
	.noc_locationy(sram_locationy)
	);
	
	scheduler_router scheduler_router0(
	.clk(clk),
	.rst(rst),	
	.wen(scheduler_wen),
	.Data_in_N(),
	.Data_in_S(),
	.Data_in_W(link_sramtoscheduler),
	.Data_in_E(),
	.Data_in_ready_N(),
	.Data_in_ready_S(),
	.Data_in_ready_W(),
	.Data_in_ready_E(),
	.Data_out_N(),
	.Data_out_S(),
	.Data_out_W(link_schedulertosram),
	.Data_out_E(link_schedulertonode),
	.Data_out_ready_N(),
	.Data_out_ready_S(),
	.Data_out_ready_W(),
	.Data_out_ready_E(), 
	.Data_out_valid_N(scheduler_valid_out_N),
	.Data_out_valid_S(scheduler_valid_out_S),
	.Data_out_valid_W(scheduler_valid_out_W),
	.Data_out_valid_E(scheduler_valid_out_E),
	//.bustorouter_valid(scheduler_valid_in), 
	.Data_in_valid_N(scheduler_valid_in_N),
	.Data_in_valid_E(scheduler_valid_in_E),
	.Data_in_valid_S(scheduler_valid_in_S),
	.Data_in_valid_W(scheduler_valid_in_W),
	.noc_locationx(scheduler_locationx),
	.noc_locationy(scheduler_locationy)
	);
	
	
	
	node_router node_router0(
	.clk(clk),
	.rst(rst),
	.Data_in_N(),
	.Data_in_S(),
	.Data_in_W(link_schedulertonode),
	.Data_in_E(),
	.Data_in_ready_N(),
	.Data_in_ready_S(),
	.Data_in_ready_W(),
	.Data_in_ready_E(),
	.Data_out_N(),
	.Data_out_S(),
	.Data_out_W(),
	.Data_out_E(),
	.Data_out_ready_N(),
	.Data_out_ready_S(),
	.Data_out_ready_W(),
	.Data_out_ready_E(), 
	.Data_out_valid_N(node_valid_out_N),
	.Data_out_valid_S(node_valid_out_S),
	.Data_out_valid_W(node_valid_out_W),
	.Data_out_valid_E(node_valid_out_E),
	.Data_in_valid_N(node_valid_in_N),
	.Data_in_valid_E(node_valid_in_E),
	.Data_in_valid_S(node_valid_in_S),
	.Data_in_valid_W(node_valid_in_W),
	.noc_locationx(node_locationx),
	.noc_locationy(node_locationy)
	);	
	
	
endmodule