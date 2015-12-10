//************************************
//	Designed by:	Wenyi Xu
//	Last updated:	15/10/21
//************************************


module letter_div(clk, rst, data_in, data_wr, write_free, letter_out, out_en);
	
	parameter data_size = 32;	
	// Parameters for FSM  
	parameter START		= 4'b0000;
	parameter IDLE 		= 4'b0001;
	parameter RECEIVE	= 4'b0010;
	parameter CHECK_BL	= 4'b0011;
	
	input clk;	
	input rst;
	input [data_size-1:0] data_in;	 	// Input 32-bit data port
	input data_wr;						// data_wr signal informs that whether there are data sent in now	 
	
	output reg write_free;				// Indicate that in IDLE state, and pending data can be written to this block.
	output [7:0] letter_out;			// Output 8-bit values(letters) to word_com module.   	  
	output out_en;						// Indicates the word_com module that letter_div is sending letters to it.
	reg [7:0] letter_out_reg;			// output directly from 'mem_letter' cannot be directly sent out. 
	
//	wire [7:0] letter_out_1;				// Wants to delay the data output 1 cycle to meet the timing requirement of word_com
	
	reg data_wr_0;
	reg data_wr_1;
	reg data_wr_2;
	reg data_wr_3;
	reg data_wr_4;	   
	reg data_wr_5;
	reg data_wr_6;	  
	reg data_wr_7;
	reg letter_out_en; 
	reg letter_out_en_1;

	assign out_en = letter_out_en;

	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_0 <= 0;
		else
			data_wr_0 <= data_wr;

	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_1 <= 0;
		else
			data_wr_1 <= data_wr_0;
			
	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_2 <= 0;
		else
			data_wr_2 <= data_wr_1;
		
	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_3 <= 0;
		else
			data_wr_3 <= data_wr_2;
			
	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_4 <= 0;
		else
			data_wr_4 <= data_wr_3;
			
	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_5 <= 0;
		else
			data_wr_5 <= data_wr_4;
			
			
	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_6 <= 0;
		else
			data_wr_6 <= data_wr_5;
			
	always@(posedge clk or negedge rst)
		if(!rst)
			data_wr_7 <= 0;
		else
			data_wr_7 <= data_wr_6;
			
	always@(posedge clk or negedge rst)
		if(!rst)
			letter_out_en <= 0;
		else if(data_wr_1)
			letter_out_en <= 1;
		else if(data_wr_6)
			letter_out_en <= 0;		
			
	always@(posedge clk or negedge rst)
		if(!rst)
			letter_out_en_1 <= 0;
		else if(data_wr_2)
			letter_out_en_1 <= 1;
		else if(data_wr_6)
			letter_out_en_1 <= 0;
			
/*	always@(posedge clk or negedge rst)
		if(!rst)
			letter_out <= 0;
		else
			letter_out <= letter_out_1;	  */
	
	assign letter_out = letter_out_en_1==1?letter_out_reg:8'bzzzzzzzz;
	
	reg [data_size-1:0] mem_receive;		    // Store the recived data from data_in.
												// For now, can operate on at most 16 letters(including blanks & punctuations.
	reg [7:0] mem_letter [1023:0];				// Store the single letters. Support 16 letters for now.
//	reg mem_pt = 3;								// Write pointer of the mem.
	
	reg [4:0] current_state;
	reg [3:0] next_state;	  
	
	reg [3:0] check_pt;					// The pointer to 'mem_receive'
	reg [9:0] letter_pt;				// The pointer to the 'mem_letter'	
	reg [9:0] out_pt;					// The pointer to output values of 'mem_letter'
	
	always@(posedge clk or negedge rst)
		if(!rst)
			out_pt <= 0;
		else
			out_pt <= letter_pt;
	
	always@(posedge clk or negedge rst)
		if(!rst)
			letter_out_reg <= 8'h00;
		else
			letter_out_reg <= mem_letter[out_pt];
		
	
	always@(posedge clk or negedge rst)
		if(!rst)
			current_state <= IDLE;
		else
			current_state <= next_state;
			
	always@*
		begin
			case(current_state)	  
				START:	begin
					if(data_wr == 1)	next_state = RECEIVE;	
					else 				next_state = START;
				end	   
				IDLE:	begin
							if(data_wr == 1)	next_state = RECEIVE;		  
							else 				next_state = IDLE;	  
						end
				RECEIVE:	begin
								next_state = CHECK_BL;		
				end
				CHECK_BL:	begin
								if(check_pt == 1)	next_state = IDLE;	   
								else				next_state = CHECK_BL;
				end
				default:	begin
								next_state = START;
				end
			endcase
		end
			
	
	always@(posedge clk)
		case(current_state)	 
			START:	begin
				letter_pt = 1;		// Start from 1, since mem_word[0] must be 32'h23333333.
				write_free = 1'b1;
				check_pt = 7;	
			end
			IDLE:	begin
						write_free = 1'b1;
						check_pt = 7;					
			end
			RECEIVE:	begin
							write_free = 1'b0;
							mem_receive[data_size-1:0] = data_in;
			end
			CHECK_BL:	begin
							write_free = 1'b0;					 
							mem_letter[0] = 8'h00;	 
							case(check_pt)
								7: begin
										// If mem_receive[xx] equals blank or punctuations, store as 8'h00
										if( (mem_receive[7:0]<=8'h2f && mem_receive[7:0]>=8'h20)||(mem_receive[7:0]==8'h3a)||(mem_receive[7:0]==8'h3b)||(mem_receive[7:0]==8'h3f) ) begin
											mem_letter[letter_pt] = 8'h00;	
										end
										else begin
											mem_letter[letter_pt] = mem_receive[7:0];
										end	
									end	   
								5: begin
										if( (mem_receive[15:8]<=8'h2f && mem_receive[15:8]>=8'h20)||(mem_receive[15:8]==8'h3a)||(mem_receive[15:8]==8'h3b)||(mem_receive[15:8]==8'h3f) ) begin
											mem_letter[letter_pt] = 8'h00;	
										end
										else begin
											mem_letter[letter_pt] = mem_receive[15:8];
										end	
								end
								3: begin
										if( (mem_receive[23:16]<=8'h2f && mem_receive[23:16]>=8'h20)||(mem_receive[23:16]==8'h3a)||(mem_receive[23:16]==8'h3b)||(mem_receive[23:16]==8'h3f) ) begin
											mem_letter[letter_pt] = 8'h00;	
										end
										else begin
											mem_letter[letter_pt] = mem_receive[23:16];
										end	
								end
								1: begin
										if( (mem_receive[31:24]<=8'h2f && mem_receive[31:24]>=8'h20)||(mem_receive[31:24]==8'h3a)||(mem_receive[31:24]==8'h3b)||(mem_receive[31:24]==8'h3f) ) begin
											mem_letter[letter_pt] = 8'h00;	
										end
										else begin
											mem_letter[letter_pt] = mem_receive[31:24];
										end	
									end
								default: begin
										end
							endcase	
							if(letter_pt == 1023) letter_pt = 1;
							else letter_pt = letter_pt + 1'b1; 
							check_pt = check_pt - 2;
			end
			default: begin  end	
		endcase
	
	
endmodule