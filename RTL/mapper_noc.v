
module mapper_noc(clk, rst, data_in, data_in_ready, fifo_in_ready, data_out, data_out_ready);
	
	parameter IDLE 			= 4'b0000;
	parameter IDLE1			= 4'b1111;
	parameter KEYWORD		= 4'b0001;
	parameter TEXTFILE		= 4'b0010;	
	parameter TEXTFILE_1	= 4'b0011;	 
	
	parameter PAIR_NUM		= 10;
	
	input clk;
	input rst;	 
	input [31:0] data_in;
	input data_in_ready; 
	input fifo_in_ready;  					// mapper can write to router when fifo_in_ready==1 
	
	output reg [31:0] data_out;
	output reg data_out_ready;
	
	
	reg [31:0] text_in;
	wire [31:0] keyword_in;
	reg [31:0] keyword_in_reg; 
	
	wire [31:0] pair;
	wire pair_out;
	reg pair_out_reg;
	reg [127:0] pair_reg [PAIR_NUM-1:0];				// Store at most 10 pairs now.	 
	reg [4:0] i;										// Index the pair_reg  
	reg [4:0] pair_reg_index;													 
	reg [4:0] pair_reg_index_1;

	reg [2:0] pair_reg_counter;	 
	reg [2:0] pair_reg_counter_1;
	
	reg [3:0] current_state;
	reg [3:0] next_state; 
	
	reg [2:0] key_counter;					// Counter keyword reception for 4 cycles.	  
		
	reg key_en;	  
	reg text_en;	
	
	reg [127:0] mem [128:0];	 
	reg [31:0] pt_in;
	reg [31:0] pt_out;  
	
	reg data_wr;
	reg [2:0] data_wr_counter;	
	

	
	always@(posedge clk or negedge rst)
		if(!rst) begin
			data_out <= 0;
			data_out_ready <= 0;
			pair_reg_index_1 <= 0; 
			pair_reg_counter_1 <= 0;
		end
		else if(pair_reg_index_1<pair_reg_index && fifo_in_ready==1) begin 
			data_out_ready <= 1; 
			case(pair_reg_counter_1)
				0: begin
					data_out <= pair_reg[pair_reg_index_1][31:0]; 
					pair_reg_counter_1 <= 1;
				end
				1: begin
					data_out <= pair_reg[pair_reg_index_1][63:32];
					pair_reg_counter_1 <= 2;
				end
				2: begin
					data_out <= pair_reg[pair_reg_index_1][95:64];
					pair_reg_counter_1 <= 3;
				end
				3: begin
					data_out <= pair_reg[pair_reg_index_1][127:96];  
					pair_reg_index_1 <= pair_reg_index_1 + 1; 
					pair_reg_counter_1 <= 0;
				end	
				default: begin
				end
			endcase
		end	 
		else begin
		    data_out_ready <= 0;
			data_out <= 0;
		end
			
	
	
	always@(posedge clk or negedge rst)
		if(!rst) 
			pair_out_reg <= 0;
		else
			pair_out_reg <= pair_out;
	
	always@(posedge clk or negedge rst)
		if(!rst) begin	
			for(i=0; i<PAIR_NUM; i=i+1)
				pair_reg[i] <= 0;
			pair_reg_counter <= 0; 
			pair_reg_index <= 0;
		end
		else if(pair_out_reg == 1) begin 
			case(pair_reg_counter)
			0: begin
				pair_reg[pair_reg_index][31:0] <= pair;
				pair_reg_counter <= 1;
			end
			1: begin
				pair_reg[pair_reg_index][63:32] <= pair;
				pair_reg_counter <= 2;
			end
			2: begin  
				pair_reg[pair_reg_index][95:64] <= pair;
				pair_reg_counter <= 3;
			end
			3: begin  
				pair_reg[pair_reg_index][127:96] <= pair;
				pair_reg_counter <= 0;	
				pair_reg_index <= pair_reg_index + 1;
			end
			default: begin
				pair_reg[pair_reg_index] <= pair_reg[pair_reg_index];
			end
		endcase	
		//pair_reg_index <= pair_reg_index + 1;
		end
		else   
		 	pair_reg[pair_reg_index] <= pair_reg[pair_reg_index];

	/*always@(posedge clk or negedge rst)
		if(!rst) begin
			data_out <= 0;
			data_out_ready <= 0;
		end
		else if(fifo_in_ready==1) begin	 
			data_out <= 0;
			data_out_ready <= 0;
		end
		else begin
		end	 */
			 
			 
	assign keyword_in = (key_en == 1'b1)?keyword_in_reg:32'bz;
	
	always@(posedge clk or negedge rst)
		if(!rst)
			current_state <= IDLE;
		else
			current_state <= next_state;
			
	always@*
		case(current_state)
			IDLE: begin	 
				if(data_in_ready == 1'b1) next_state = IDLE1;
				else next_state = IDLE;
			end
			IDLE1: begin   
				next_state = KEYWORD;
			end
			KEYWORD: begin
				if(key_counter == 3) next_state = TEXTFILE;
				else next_state = KEYWORD; 
			end
			TEXTFILE: begin	 
				if( pt_out==pt_in && pt_in!=0 ) next_state = TEXTFILE_1;
				else next_state = TEXTFILE; 
			end	 
			TEXTFILE_1: begin
			end
			default: begin	
				next_state = IDLE;
			end
		endcase
		
	always@(posedge clk)
		case(current_state)	 
			IDLE: begin
				key_counter <= 0; 
				key_en <= 0;
				text_en <= 0; 
				pt_in <= 0;
				pt_out <= 0; 
				data_wr_counter <= 0;
			end	 
			IDLE1: begin
			end
			KEYWORD: begin
				key_counter <= key_counter + 1'd1; 
				key_en <= 1;  
				keyword_in_reg <= data_in[31:0];
			end
			TEXTFILE: begin
				key_en <= 0;
				text_en <= 1; 	 
				if(data_in_ready == 1)
					mem[pt_in] <= data_in;
				else begin 
				end	
				
				if(data_in_ready==1 && pt_in < 1024) begin
					pt_in <= pt_in + 1;	  
				end
				else if(pt_in < 1024) begin 
					pt_in <= pt_in;
				end
				else begin 
				    pt_in <= 0;
				end	  
				
				if(data_wr_counter == 6) begin
					data_wr_counter <=0;
				end
				else if(data_wr_counter == 1) begin
					data_wr <= 1'b1;
					data_wr_counter <= data_wr_counter + 1;
					text_in <= mem[pt_out];	 
					pt_out <= pt_out + 1;
				end
				else if(data_wr_counter == 2) begin
					data_wr <= 1'b0;  
					data_wr_counter <= data_wr_counter + 1;
				end
				else
					data_wr_counter <= data_wr_counter + 1;
			end	
			default: begin
			end
		endcase
	
	
	
	mapper mapper0(
	.clk(clk),
	.rst(rst),
	.data_in_1(text_in),
	.keyword(keyword_in),
	.key_en(key_en),
	.data_wr(data_wr),
	.write_free(),
	.pair(pair),
	//.pair_out(pair_out),
	.pair_out(pair_out));
	
endmodule







