//************************************
//	Designed by:	Wenyi Xu
//	Last updated:	15/10/21
//************************************

module word_com(clk, rst, data_in, letter_in);
	
	parameter letter_size = 8; 
	parameter word_length = 128;	// 128-bit   128/8 = 16 letters in one word
	parameter word_num	  = 63;		// This value affects the row_pt
	
	// FSM parameters	
	parameter START		= 4'b0000;
	parameter IDLE 		= 4'b0001; 
	parameter COMBINE	= 4'b0010;
	
	input clk;
	input rst;	
	input data_in;		// When data_in==1 COMBINE, when data_in==0 IDLE
	
	input [letter_size-1:0] letter_in;		// The incoming letters		
	
//	output reg out_en;					// Tell te key_comp that word_com is sending data out
//	output reg [31:0] data_out;			// Output 32-bit data to key_comp
	
	reg [word_length-1:0] mem_word [word_num-1:0];		// The internal mem to store the combined words 
	reg [5:0] row_pt;			// Needs to point from 0 to 63	
	reg [7:0] col_pt;			// Needs to point from 0 to 127	 and some margin 
	reg [6:0] i;				// Index the mem_word
	
	reg [3:0] current_state;
	reg [3:0] next_state; 
	
//	reg data_in_reg;
	
//	always@(posedge clk or negedge rst)
//		if(!rst)
//			data_in_reg <= 0;
//		else
//			data_in_reg <= data_in;
	
	always@(posedge clk or negedge rst)	
		if(!rst)
			current_state <= START;
		else
			current_state <= next_state;
			
	always@*	  
		begin
			case(current_state)	
				START:	begin  
					if(data_in == 1)	next_state = COMBINE;
					else	next_state = START;
					end
				IDLE:	begin  
					if(data_in == 1)	next_state = COMBINE;
					else	next_state = IDLE;	
					end	
				COMBINE: begin 
					if(data_in == 0)	next_state = IDLE;
					else	next_state = COMBINE;
					end
				default: begin	
					next_state = START;
					end
			endcase
		end	  
		
	always@(posedge clk)
		case(current_state)
			START: begin 
				row_pt <= 0;
				col_pt <= 0;	  
				//mem_word[0] = 128'b0;
				for(i=0; i<=63; i=i+1)
					mem_word[i] <= 128'b0; 
			end
			IDLE: begin
			end	  
			COMBINE: begin	  
				if( (letter_in==8'h00)&&(col_pt==0)) begin
					row_pt <= row_pt;	
				end
				else if ( (letter_in==8'h00)&&(col_pt!=0) ) begin	 
					// Start from a new row, combine a new word.
					row_pt <= row_pt + 1; 
					col_pt <= 0;
				end	
				else if (col_pt == 128) begin
					row_pt <= row_pt + 1;
					col_pt <= 0;
				end
				else if(data_in == 1) begin
					mem_word[row_pt] <= mem_word[row_pt] + (letter_in<<col_pt);	  
					col_pt <= col_pt + 8;
				end
				else begin
				end
			end
			default: begin
			end
		endcase
	
	
	
	
	
	
	
	
	
endmodule