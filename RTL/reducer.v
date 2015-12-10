//************************************
//	Designed by:	Xiaoyu Sun
//	Last updated:	15/11/9
//************************************

module reducer(clk, rst, write_in, pair_in, result);
	
	parameter data_size = 32; 
	parameter word_length = 128;	
	parameter word_num	  = 64;		
	
	// FSM parameters	
	parameter START		= 4'b0000;
	parameter IDLE 		= 4'b0001; 
	parameter COMBINE	= 4'b0010;
	
	input clk;
	input rst;	
	input write_in;		// When write_in==1 COMBINE, when write_in==0 IDLE
	
	input [data_size-1:0] pair_in;		// The incoming pairs		
	output reg [31:0] result;
    
	// Only support 1 key
	reg [3:0] count; 
	reg count_flag;	  
	reg count_flag_1;
  	always@(posedge clk or negedge rst)
		  if(!rst) begin
			 count_flag <= 0;
		  end
	  	  else 
			count_flag <= write_in;
			
	always@(posedge clk or negedge rst)
		  if(!rst) begin
			 count_flag_1 <= 0;
		  end
		  else if(write_in && ~count_flag) 
		     count_flag_1 <= 1;
		else
			count_flag_1 <= 0;	   
			
	always@(posedge clk or negedge rst)	
		if(!rst)
			count <= 0;
		else if(count_flag_1)
			count <= count + 1;
			
			 
     
	
	reg [word_length-1:0] mem_word [word_num-1:0];		// The internal mem to store the combined words 
	reg [word_length-1:0] key_lut [3:0];
	reg [5:0] row_pt;			// Needs to point from 0 to 63	
	//
	reg [5:0] row_pt_pre;
	//
	reg [7:0] col_pt;			// Needs to point from 0 to 127	 and some margin 
	reg [7:0] pt;               //result pointer
	reg [2:0] lut_pt;           //Index LUT
	reg [6:0] i;				// Index the mem_word
     
	
	reg [3:0] current_state;
	reg [3:0] next_state; 
	
	
	// Delay row_pt
	always@(posedge clk or negedge rst)
		if(!rst)
			row_pt_pre <= 6'b0;
		else
			row_pt_pre <= row_pt;
	
	wire row_change;		
	assign row_change = (row_pt != row_pt_pre);		
	
	always@(posedge clk)	
		if(!rst)
			current_state <= START;
		else
			current_state <= next_state;
			
	always@*	  
		begin
			case(current_state)	
				START:	begin  
					if(write_in == 1)	next_state = COMBINE;
					else	next_state = START;
					end
				IDLE:	begin  
					if(write_in == 1)	next_state = COMBINE;
					else	next_state = IDLE;	
					end	
				COMBINE: begin 
					if(write_in == 0)	next_state = IDLE;
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
				for(i=0; i<=63; i=i+1)
					mem_word[i] <= 128'b0; 
			end
			IDLE: begin
			end	  
			COMBINE: begin	  
				if (col_pt == 128) begin
					row_pt <= row_pt + 1;
					col_pt <= 0;
				end
				else if(write_in == 1) begin
					mem_word[row_pt] <= mem_word[row_pt] + (pair_in<<col_pt);	  
					col_pt <= col_pt + 32;
				end
			end
		endcase

	
  always@(posedge clk)
  if (!rst)
    begin
    lut_pt <= 0;
    pt<= 0;
    result <= 32'b0;
    key_lut[0] <= 128'b0;
    key_lut[1] <= 128'b0;
    key_lut[2] <= 128'b0;
    key_lut[3] <= 128'b0;
  end


    else if ((mem_word[row_pt-1]!=key_lut[0]) && (mem_word[row_pt-1]!=key_lut[1]) && (mem_word[row_pt-1]!=key_lut[2]) && (mem_word[row_pt-1]!=key_lut[3])  && (col_pt==0)&&(row_change==1))
      begin
        result <= result + (8'b00000001 << pt);
        key_lut[lut_pt] <= mem_word[row_pt-1];
        lut_pt <= lut_pt +1;
        pt <= pt+8;
      end
      
      else if ((mem_word[row_pt-1]==key_lut[0]) && (key_lut[0]!=0)&& (col_pt==0)&&(row_change==1))
      begin
      result[7:0] <= result[7:0] + 1;
      end
      
      else if ((mem_word[row_pt-1]==key_lut[1]) && (key_lut[1]!=0)&& (col_pt==0)&&(row_change==1))
           begin
           result[15:8] <= result[15:8] + 1;
           end
      
      else if ((mem_word[row_pt-1]==key_lut[2]) && (key_lut[2]!=0)&& (col_pt==0)&&(row_change==1))
                 begin
                 result[23:16] <= result[23:16] + 1;
                 end
                 
                 else if ((mem_word[row_pt-1]==key_lut[3]) && (key_lut[3]!=0)&& (col_pt==0)&&(row_change==1))
                            begin
                            result[31:24] <= result[31:24] + 1;
                            end
	 
	   
	 
	
	
endmodule












