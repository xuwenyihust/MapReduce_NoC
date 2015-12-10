//************************************
//	Designed by:	Wenyi Xu
//	Last updated:	15/10/26
//************************************

module mapper(clk, rst, data_in_1, keyword, key_en, data_wr, write_free, pair, pair_out); 
	
	parameter data_size = 32;	 
	
	// FSM for keyword receiving
	parameter IDLE		=	3'b000;
	parameter RECEIVE0	=	3'b001;
	parameter RECEIVE1	=	3'b010;
	parameter RECEIVE2	=	3'b011;
	parameter RECEIVE3	=	3'b100;	 	// The longest keyword is 128bit whcih needs 128/32=4 cycles to receive	 
	
	// FSM for keyword comparison 
	parameter COM_IDLE	=	4'b0101;
	parameter COM_DO	=	4'b0110;
	parameter COM_SEND	=	4'b0111;
	
	// FSM for pair sending
	parameter SEND0	=	4'b1000;	 
	parameter SEND1	=	4'b1001;
	parameter SEND2	=	4'b1010;
	parameter SEND3	=	4'b1011;
	parameter SEND4 =	4'b1100;
	
	input clk;
	input rst;
	
	input [data_size-1:0] data_in_1;	// Input 32-bit data
										// From Scheduler module (dataout)
										// Will be sent to letter_div sub-module
	
	input [data_size-1:0] keyword;		// Input keyword;	From scheduler module		 
										// Want to convert the order of letters of the keyword for comparison
	input data_wr;						// Informs that whether there are data sent from scheduler now.

	input key_en;
	wire key_en_reg;
	reg key_en_0;
	reg key_en_1;
	
	output write_free;					// Indicates that scheduler can send data to the mapper now.  
										// Output connects to scheduler	  
	output reg [data_size-1:0] pair;		// Output the keyword that hits, can omit the accompany value '1'.
	output pair_out;
	
	wire data_in_2;						// Connects out_en from letter_div to data_in from word_com    
	wire [7:0] letter;					// 8-bit (8'hxx) letters from letter_div to word_com  
	
	
	reg [5:0] row_pt_reg;						// Reg the col_pt from word_com	
	wire row_pt_pulse;
											
	
	reg [2:0] current_state;
	reg [2:0] next_state;  
	reg [3:0] com_cu_state;
	reg [3:0] com_ne_state;
	reg [3:0] send_cu_state;
	reg [3:0] send_ne_state;
	
	
	reg [data_size-1:0] keyword_0;
	reg [data_size-1:0] keyword_1;
	reg [127:0] keyword_conv;	
	

	assign pair_out = (send_cu_state == SEND1)||(send_cu_state == SEND2)||(send_cu_state == SEND3)||(send_cu_state == SEND4);		
			
		
	
	always@(posedge clk or negedge rst)
		if(!rst)
			key_en_0 <= 0;
		else
			key_en_0 <= key_en; 
			
	always@(posedge clk or negedge rst)
		if(!rst)
			key_en_1 <= 0;
		else
			key_en_1 <= key_en_0;
	
	assign key_en_reg = key_en_1 | key_en;
	
	always@(posedge clk or negedge rst)
		if(!rst)
			keyword_0 <= 0;
		else if(key_en_reg || key_en)
			keyword_0 <= keyword;
		else
			keyword_0 <= 0;	 
			
	always@(posedge clk or negedge rst)
		if(!rst)
			keyword_1 <= 0;
		else if(key_en_reg || key_en)
			keyword_1 <= keyword_0;
		else
			keyword_1 <= 0;
			
	
	// Comparison FSM		
	always@(posedge clk or negedge rst)
		if(!rst)
			com_cu_state <= COM_IDLE;
		else
			com_cu_state <= com_ne_state;
			
	always@*
		case(com_cu_state)
			COM_IDLE: begin	
				if(row_pt_pulse == 1) com_ne_state = COM_DO;
				else com_ne_state = COM_IDLE;
			end
			COM_DO: begin
				if(keyword_conv == wc0.mem_word[wc0.row_pt-1]) com_ne_state = COM_SEND;
				else	com_ne_state = COM_IDLE;
			end
			COM_SEND: begin	
				com_ne_state = COM_IDLE;
			end		  
			default: begin 
				com_ne_state = COM_IDLE;
			end
		endcase	
		
	always@(posedge clk)
		case(com_cu_state)	 
			COM_IDLE: begin
			end
			COM_DO: begin 
			end
			default: begin
			end
		endcase
		
			
			
			
		
	// row_pt_pulse generation
	// For indicating the starting of comparision
	always@(posedge clk or negedge rst)
		if(!rst)
			row_pt_reg <= 0;
		else
			row_pt_reg <= wc0.row_pt; 
	
	assign row_pt_pulse = wc0.row_pt ^ row_pt_reg;		
	
	// Pair sending FSM
	always@(posedge clk or negedge rst)
		 if(!rst)
			send_cu_state <= SEND0;
		else
			send_cu_state <= send_ne_state;	
			
	always@*
		case(send_cu_state)
			SEND0: begin 
				if(com_cu_state == COM_SEND) send_ne_state = SEND1;
				else send_ne_state = SEND0; 
			end
			SEND1: begin 
				send_ne_state = SEND2; 
			end
			SEND2: begin
				send_ne_state = SEND3; 
			end
			SEND3: begin 
				send_ne_state = SEND4; 
			end
			SEND4: begin			 
				send_ne_state = SEND0; 
			end
		endcase
	
	always@(posedge clk)
		case(send_cu_state)
			SEND0: begin 
				pair <= 0;
			end
			SEND1: begin 
				pair <= keyword_conv[31:0];
			end
			SEND2: begin
				pair <= keyword_conv[63:32]; 
			end
			SEND3: begin 
				pair <= keyword_conv[95:64]; 
			end
			SEND4: begin			 
				pair <= keyword_conv[127:96]; 
			end
		endcase
	
	
	
	// Keyword receiving FSM 
	always@(posedge clk or negedge rst)
		if(!rst)
			current_state <= IDLE;
		else
			current_state <= next_state;
			
	
	always@*
		case(current_state)
			IDLE: begin
				if(key_en == 1) next_state = RECEIVE0;
				else	next_state = IDLE;
			end	
			RECEIVE0: begin
				if(key_en == 1) next_state = RECEIVE1;
				else	next_state = IDLE;
			end				
			RECEIVE1: begin
				if(key_en == 1) next_state = RECEIVE2;
				else	next_state = IDLE;
			end
			RECEIVE2: begin
				if(key_en == 1) next_state = RECEIVE3;
				else	next_state = IDLE;
			end
			RECEIVE3: begin
				if(key_en == 1) next_state = IDLE;
				else	next_state = IDLE;
			end
			default: next_state = IDLE;
		endcase
		
	always@(posedge clk)
		case(current_state)
			IDLE: begin
				//keyword_conv[127:0] <= 128'b0;
			end
			RECEIVE0: begin
				keyword_conv[7:0] <= keyword_0[7:0];
				keyword_conv[15:8] <= keyword_0[15:8];
				keyword_conv[23:16] <= keyword_0[23:16];
				keyword_conv[31:24] <= keyword_0[31:24];
			end	 
			RECEIVE1: begin
				keyword_conv[39:32] <= keyword_0[7:0];
				keyword_conv[47:40] <= keyword_0[15:8];
				keyword_conv[55:48] <= keyword_0[23:16];
				keyword_conv[63:56] <= keyword_0[31:24];
			end
			RECEIVE2: begin
				keyword_conv[71:64] <= keyword_0[7:0];
				keyword_conv[79:72] <= keyword_0[15:8];
				keyword_conv[87:80] <= keyword_0[23:16];
				keyword_conv[95:88] <= keyword_0[31:24];
			end
			RECEIVE3: begin
				keyword_conv[103:96] <= keyword_0[7:0];
				keyword_conv[111:104] <= keyword_0[15:8];
				keyword_conv[119:112] <= keyword_0[23:16];
				keyword_conv[127:120] <= keyword_0[31:24];
			end
			default: begin
			end
		endcase	  
			
			
			
	letter_div ld0(
	.clk(clk),
	.rst(rst), 
	// 32-bit input from scheduler
	.data_in(data_in_1),	 
	// Incoming data alert from scheduler
	.data_wr(data_wr), 
	// 'Can be written' signal to scheduler
	.write_free(write_free),
	.letter_out(letter),	  
	// High/Low signal from letter_div to word_com, indicates that letter_div is sending data to word_com
	.out_en(data_in_2));
	
	word_com wc0(
	.clk(clk),
	.rst(rst), 
	// High: Data can be written into 
	.data_in(data_in_2),  
	// 8-bit data from letter_div
	.letter_in(letter));
	
	
endmodule















