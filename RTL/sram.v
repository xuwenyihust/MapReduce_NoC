module sram(clk, rst, address, data, read_en, out_en);
	
	parameter MEM_WIDTH = 36;
	parameter MEM_DEPTH = 128;
	
	input clk;
	input rst;
	// 2^6 = 64 = MEM_DEPTH
	input [31:0] address;
	
	// Connects routertobus_valid[L]
	input read_en;	
	output out_en;
	
	assign out_en = read_en;
	
	wire [5:0] address_6bit;
	assign address_6bit = address[9:4];
	
	output  [MEM_WIDTH-1:0] data;
	reg [MEM_WIDTH-1:0] data_out;
	
	reg read_en_reg;
	//wire read_en_wire;
	//assign read_en_wire = read_en;
	/*always@(posedge clk or negedge rst)
		if(!rst)
			read_en_reg <= 1;
		else if(read_en == 0)
			read_en_reg <= 0;*/
			
	assign data = (read_en)?data_out:36'hzzzzzzzzz; 
	//assign data_out[3:0] = 4'b0001;
	
	reg [9:0] i; // Initialize the mem.
	reg [MEM_WIDTH-1:0] mem [MEM_DEPTH-1:0]; 
	
	
	always@(posedge clk or negedge rst)
		if(!rst)
			begin  
				
				data_out <= 36'h00000001;
				
				
				//*******************************************************
				//	Test Case 0: 
				//	Keyword:	themselves
				//	Text:		They went themselves. They themselves 
				//				made the decision, they hurt themselves.
				//******************************************************* 
				// Beginning of annotation
				/*
				// Number of keywords 
				mem[0] <= 32'h00000001;	
				// Number of textfiles
				mem[1] <= 32'h00000001;
				
				// Row 0 of keyword
				mem[2] <= 32'h6d656874;
				// Row 0 of keyword
				mem[3] <= 32'h766c6573;
				// Row 0 of keyword
				mem[4] <= 32'h00007365;	
				// Row 0 of keyword
				mem[5] <= 32'h00000000;
				
				// Start of textfile
				mem[6] <= 32'h79656854;	
				
				mem[7] <= 32'h6e657720;
				mem[8] <= 32'h68742074;
				mem[9] <= 32'h65736d65;
				mem[10] <= 32'h7365766c;
				mem[11] <= 32'h6854202e;
				mem[12] <= 32'h74207965;
				mem[13] <= 32'h736d6568;
				mem[14] <= 32'h65766c65;
				mem[15] <= 32'h616d2073;
				mem[16] <= 32'h74206564;
				mem[17] <= 32'h64206568;
				mem[18] <= 32'h73696365;
				mem[19] <= 32'h2c6e6f69;
				mem[20] <= 32'h65687420;
				mem[21] <= 32'h75682079;
				mem[22] <= 32'h74207472;
				mem[23] <= 32'h736d6568;
				mem[24] <= 32'h65766c65;
				mem[25] <= 32'h00002e73;
				mem[26] <= 32'hffffffff;
				mem[27] <= 32'hffffffff;  
				mem[28] <= 32'hffffffff;
				mem[29] <= 32'hffffffff;
				mem[30] <= 32'hffffffff;
				mem[31] <= 32'hffffffff;
				mem[32] <= 32'hffffffff;
				mem[33] <= 32'hffffffff;
				mem[34] <= 32'hffffffff;
				mem[35] <= 32'hffffffff;  
				mem[36] <= 32'hffffffff;
				mem[37] <= 32'hffffffff;
				mem[38] <= 32'hffffffff;
				mem[39] <= 32'hffffffff;
				
				mem[40] <= 32'hffffffff;
				mem[41] <= 32'hffffffff;  
				mem[42] <= 32'hffffffff;
				mem[43] <= 32'hffffffff;  
				mem[44] <= 32'hffffffff;
				mem[45] <= 32'hffffffff;
				mem[46] <= 32'hffffffff;
				mem[47] <= 32'hffffffff;
				mem[48] <= 32'hffffffff;
				mem[49] <= 32'hffffffff;
				mem[50] <= 32'hffffffff;
				mem[51] <= 32'hffffffff;  
				mem[52] <= 32'hffffffff;
				mem[53] <= 32'hffffffff;
				mem[54] <= 32'hffffffff;
				mem[55] <= 32'hffffffff;
				mem[56] <= 32'hffffffff;
				mem[57] <= 32'hffffffff; 
				mem[58] <= 32'hffffffff;
				mem[59] <= 32'hffffffff;  
				mem[60] <= 32'hffffffff;
				mem[61] <= 32'hffffffff;
				mem[62] <= 32'hffffffff;
				mem[63] <= 32'hffffffff; 
				*/	
				// End of annotation
				
				//*******************************************************
				
				//*******************************************************
				//	Test Case 1: 
				//	Keyword:	one	
				//	Textfile:	Lead is one of the softer metals. 
				//				The conversation drifted from one 
				//				subject to another. 
				//				I have just one question, 
				//				the small town boasted only one school.
				//*******************************************************
				// Beginning of annotation 
				
				// Number of keywords 
				mem[0] <= 32'h00000001;	
				// Number of textfiles
				mem[1] <= 32'h00000001;
				
				// Row 0 of keyword
				mem[2] <= 32'h00656e6f;
				// Row 0 of keyword
				mem[3] <= 32'h00000000;
				// Row 0 of keyword
				mem[4] <= 32'h00000000;	
				// Row 0 of keyword
				mem[5] <= 32'h00000000;
				
				// Start of textfile
				mem[6] <= 32'h6461656c;	
				mem[7] <= 32'h20736920;
				mem[8] <= 32'h20656e6f;
				mem[9] <= 32'h74206e6f;
				mem[10] <= 32'h73206568;
				mem[11] <= 32'h656d2072;	
				mem[12] <= 32'h736c6174;
				mem[13] <= 32'h6854202e;
				mem[14] <= 32'h6f732065;
				mem[15] <= 32'h7265766e;
				mem[16] <= 32'h69746173;	
				mem[17] <= 32'h64206e6f;
				mem[18] <= 32'h74666972;
				mem[19] <= 32'h66206465;
				mem[20] <= 32'h206d6f72;
				mem[21] <= 32'h20656e6f;	
				mem[22] <= 32'h6a627573;
				mem[23] <= 32'h20746365;
				mem[24] <= 32'h61206f74;
				mem[25] <= 32'h68746f6e;
				mem[26] <= 32'h202e7265;	
				mem[27] <= 32'h61682049;
				mem[28] <= 32'h6a206576;
				mem[29] <= 32'h20747375;
				mem[30] <= 32'h20656e6f;
				mem[31] <= 32'h73657571;	
				mem[32] <= 32'h6e6f6974;
				mem[33] <= 32'h6874202e;
				mem[34] <= 32'h6d732065;
				mem[35] <= 32'h206c6c61;
				mem[36] <= 32'h6e776f74;	
				mem[37] <= 32'h616f6220;
				mem[38] <= 32'h64657473;
				mem[39] <= 32'h6c6e6f20;
				mem[40] <= 32'h6e6f2079;
				mem[41] <= 32'h63732065;
				//mem[41] <= 32'h63732064;	
				mem[42] <= 32'h6c6f6f68;
				mem[43] <= 32'h0000002e;
				mem[44] <= 32'hffffffff;
				mem[45] <= 32'hffffffff;  
				mem[46] <= 32'hffffffff;
				mem[47] <= 32'hffffffff;
				mem[48] <= 32'hffffffff;
				mem[49] <= 32'hffffffff;
				mem[50] <= 32'hffffffff;
				mem[51] <= 32'hffffffff;
				mem[52] <= 32'hffffffff;
				mem[53] <= 32'hffffffff;
				mem[54] <= 32'hffffffff;
				mem[55] <= 32'hffffffff;
				mem[56] <= 32'hffffffff;
				mem[57] <= 32'hffffffff;
				mem[58] <= 32'hffffffff;
				mem[59] <= 32'hffffffff;
				mem[60] <= 32'hffffffff;
				mem[61] <= 32'hffffffff;
				mem[62] <= 32'hffffffff;
				mem[63] <= 32'hffffffff;
				mem[64] <= 32'hffffffff;
				mem[65] <= 32'hffffffff;  
				mem[66] <= 32'hffffffff;
				mem[67] <= 32'hffffffff;
				mem[68] <= 32'hffffffff;
				mem[69] <= 32'hffffffff;
				mem[70] <= 32'hffffffff;
				
				// End of annotation
			end	
		
		else
			begin
				mem <= mem;
				data_out[3:0] = 4'b0101;
				data_out[35:4] <= mem[address_6bit];
			end	 
		
	
	
	
	
	
endmodule