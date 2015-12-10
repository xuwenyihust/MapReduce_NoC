/******************FIFO_MUX************************/
module mux #(parameter int wl=36)
(
input logic [wl-1:0]data_pop,
input logic [wl-1:0]data_pop_next,  
input logic pop,
output logic [wl-1:0]data_temp
);

always_comb
begin
  
  if(pop==0) begin
    data_temp<=data_pop;
  end else begin
    data_temp<=data_pop_next;
  end

end

endmodule



/******************GENERATING RDY_EN************************/

module rdy_en (
input logic clk,
//input logic [4:0] post_priority [4:0],
//input logic out_full [4:0],
input logic [2:0] data_right_src_addr [4:0],
input logic next_local_pop [4:0],
output logic rdy_en [4:0]
);
  


//always_ff @ (posedge clk)  
always_comb

begin 

 if (data_right_src_addr[0]==3'b111) begin 
   rdy_en[0]<=0;
 end else begin
   rdy_en[0]<=next_local_pop[data_right_src_addr[0]];
 end

end


//always_ff @ (posedge clk)  
always_comb
begin 

 if (data_right_src_addr[1]==3'b111) begin 
   rdy_en[1]<=0;
 end else begin
   rdy_en[1]<=next_local_pop[data_right_src_addr[1]];
 end

end


//always_ff @ (posedge clk)  
always_comb
begin 

 if (data_right_src_addr[2]==3'b111) begin 
   rdy_en[2]<=0;
 end else begin
   rdy_en[2]<=next_local_pop[data_right_src_addr[2]];
 end

end


//always_ff @ (posedge clk)  
always_comb
begin 

 if (data_right_src_addr[3]==3'b111) begin 
   rdy_en[3]<=0;
 end else begin
   rdy_en[3]<=next_local_pop[data_right_src_addr[3]];
 end

end


//always_ff @ (posedge clk)  
always_comb
begin 

 if (data_right_src_addr[4]==3'b111) begin 
   rdy_en[4]<=0;
 end else begin
   rdy_en[4]<=next_local_pop[data_right_src_addr[4]];
 end

end

    

endmodule


/********************CROSSBAR*****************************/

module crossbar #(parameter int wL=36,parameter int lhsCount=5,parameter int rhsCount=5)
(
input logic clk,
input logic [wL-1:0] rst_val,
input logic [wL-1:0] data_left[lhsCount-1:0],
input logic [2:0] data_right_src_addr[rhsCount-1:0],
output logic [wL-1:0] data_right[rhsCount-1:0] 
);

always_comb 
begin

if (data_right_src_addr[0]==3'b111) begin 
  data_right[0]<=rst_val;
end else begin
  data_right[0]<=data_left[data_right_src_addr[0]];
end
end

always_comb 
begin

if (data_right_src_addr[1]==3'b111) begin 
  data_right[1]<=rst_val;
end else begin
  data_right[1]<=data_left[data_right_src_addr[1]];
end
end

always_comb 
begin

if (data_right_src_addr[2]==3'b111) begin 
  data_right[2]<=rst_val;
end else begin
  data_right[2]<=data_left[data_right_src_addr[2]];
end
end

always_comb 
begin

if (data_right_src_addr[3]==3'b111) begin 
  data_right[3]<=rst_val;
end else begin
  data_right[3]<=data_left[data_right_src_addr[3]];
end
end

always_comb 
begin

if (data_right_src_addr[4]==3'b111) begin 
  data_right[4]<=rst_val;
end else begin
  data_right[4]<=data_left[data_right_src_addr[4]];
end
end



endmodule

/*************************FIFO**************************/

module FIFO #(parameter int wL=36,parameter int d=8)
(
input logic push, 
input logic pop, 
output logic almost_full, 
output logic empty,
output logic almost_empty, 
input logic rst,
input logic clk,
input logic [wL-1:0] rst_val,

input logic full_pre,
output logic full,
input logic [2:0] counter_pre,
output logic [2:0] counter,
input logic [2:0] wrtPtr_next_pre,
output logic [2:0] wrtPtr_next,
input logic [2:0] rdPtr_next_pre,
output logic [2:0] rdPtr_next,

input logic [wL-1:0] data_push,
output logic [wL-1:0] data_pop_next,
output logic [wL-1:0] data_pop
);

//parameter addL = $clog2(d); 

logic [wL-1:0] mem[d-1:0];
logic [2:0] wrtPtr;
logic [2:0] rdPtr;
//logic full_next, empty_next, almost_full_next, almost_empty_next;
//logic [2:0] counter ;


//always_ff @( posedge clk )
always_comb
begin

if(~rst)
begin
	
	wrtPtr=0;  
	rdPtr=0; 
	//full_next <= 0;    
	//almost_full_next <= 0; 
	//empty_next <= 1;   
	//almost_empty_next <= 1; 
	counter=0;
	
	mem[0]=rst_val; mem[4]=rst_val; 
	mem[1]=rst_val; mem[6]=rst_val; 
	mem[2]=rst_val; mem[5]=rst_val; 
	mem[3]=rst_val; mem[7]=rst_val; 
	//data_pop<=rst_val;
	
end
else 
begin
	
	
	begin
	if(push && ~full_pre && ~pop )
	begin
			counter=counter_pre+1;
			wrtPtr=wrtPtr_next_pre;
			mem[wrtPtr]=data_push;
	end
	
		
	if(pop && (~push ||~full_pre))
	begin
	counter=counter_pre-1;
	rdPtr=rdPtr_next_pre;
	end
	
	
	if(pop && push && ~full)
	begin
	  counter=counter_pre;
		wrtPtr=wrtPtr_next_pre;
		mem[wrtPtr]=data_push;
		rdPtr=rdPtr_next_pre;
	end
	
	//if (~empty)
  //begin
  //data_pop<=mem[rdPtr];
  //end
	
end
end
end

always_comb 
begin

if(~rst) begin
    data_pop = rst_val;
    data_pop_next = rst_val;
  end else begin
    data_pop = mem[(rdPtr+3'b001)];
    data_pop_next = mem[(rdPtr+3'b010)];
  end
end

always_comb
begin
wrtPtr_next=wrtPtr+1;
rdPtr_next=rdPtr+1;

unique case (counter_pre)
	4'b000:begin empty=1;almost_empty=1;almost_full=0;full=0;end
	4'b001:begin empty=0;almost_empty=1;almost_full=0;full=0;end
	4'b110:begin empty=0;almost_empty=0;almost_full=1;full=0;end
	4'b111:begin empty=0;almost_empty=0;almost_full=1;full=1;end
	default:begin empty=0;almost_empty=0;almost_full=0;full=0;end
endcase
end

endmodule


/******************FIFO_OUT**************************/

module matrix #(parameter int WIDTH=36)
(
input logic [WIDTH-1:0] data_temp [4:0],
output logic[WIDTH-1:0] data_temp0,data_temp1,data_temp2,data_temp3,data_temp4
);

always_comb 
begin
  
data_temp0=data_temp[0];
data_temp1=data_temp[1];
data_temp2=data_temp[2];
data_temp3=data_temp[3];
data_temp4=data_temp[4]; 

end
endmodule



/******************FIND BLOCK**************************/

module findblock (
//input logic [4:0] request [4:0],
input logic [4:0] post_priority [4:0],
input logic rst,
input logic clk,
//input logic local_empty [4:0],
output logic next_local_pop [4:0]
);

//logic [4:0] xortemp [4:0];
logic [4:0] temp_post_priority0,temp_post_priority1,temp_post_priority2,temp_post_priority3,temp_post_priority4;
logic [4:0] temp_block0,temp_block1,temp_block2,temp_block3,temp_block4;
logic blocked [4:0];
//logic [4:0] ortemp;
  
always_comb 
begin
if (~rst) begin
blocked[0]=0;
blocked[1]=0;
blocked[2]=0;
blocked[3]=0;
blocked[4]=0;
end

temp_post_priority0=post_priority[0];
temp_post_priority1=post_priority[1];
temp_post_priority2=post_priority[2];
temp_post_priority3=post_priority[3];
temp_post_priority4=post_priority[4];

/*xortemp[0]=request[0]^temp_post_priority0;
xortemp[1]=request[1]^temp_post_priority1;
xortemp[2]=request[2]^temp_post_priority2;
xortemp[3]=request[3]^temp_post_priority3;
xortemp[4]=request[4]^temp_post_priority4;
ortemp=xortemp[0] | xortemp[1] | xortemp[2] | xortemp[3] | xortemp[4];
blocked[0]=((ortemp&5'b00001))?1:0;
blocked[1]=((ortemp&5'b00010))?1:0;
blocked[2]=((ortemp&5'b00100))?1:0;
blocked[3]=((ortemp&5'b01000))?1:0;
blocked[4]=((ortemp&5'b10000))?1:0;*/   

temp_block0={temp_post_priority0[0],temp_post_priority1[0],temp_post_priority2[0],temp_post_priority3[0],temp_post_priority4[0]};
temp_block1={temp_post_priority0[1],temp_post_priority1[1],temp_post_priority2[1],temp_post_priority3[1],temp_post_priority4[1]};
temp_block2={temp_post_priority0[2],temp_post_priority1[2],temp_post_priority2[2],temp_post_priority3[2],temp_post_priority4[2]};
temp_block3={temp_post_priority0[3],temp_post_priority1[3],temp_post_priority2[3],temp_post_priority3[3],temp_post_priority4[3]};
temp_block4={temp_post_priority0[4],temp_post_priority1[4],temp_post_priority2[4],temp_post_priority3[4],temp_post_priority4[4]};

blocked[0]=(temp_block0)?0:1;
blocked[1]=(temp_block1)?0:1;
blocked[2]=(temp_block2)?0:1;
blocked[3]=(temp_block3)?0:1;
blocked[4]=(temp_block4)?0:1;

//next_local_pop[0]=(~blocked[0] && ~local_empty[0])?1:0;
//next_local_pop[1]=(~blocked[1] && ~local_empty[1])?1:0;
//next_local_pop[2]=(~blocked[2] && ~local_empty[2])?1:0;
//next_local_pop[3]=(~blocked[3] && ~local_empty[3])?1:0;
//next_local_pop[4]=(~blocked[4] && ~local_empty[4])?1:0;

next_local_pop[0]=~blocked[0];
next_local_pop[1]=~blocked[1];
next_local_pop[2]=~blocked[2];
next_local_pop[3]=~blocked[3];
next_local_pop[4]=~blocked[4];

end 
      
endmodule 


/*******************ARBITER*************************/


module priority_encoder (
input logic [4:0] din,
input logic bustorouter_ready,
input logic clk,
input logic rst,
output logic [2:0] dout3,
output logic [4:0] dout5
);

always_comb
begin

  if (~rst)                   begin dout3 =3'b111; dout5 = 5'b00000; end
  else if (bustorouter_ready) begin dout3 =3'b111; dout5 = 5'b00000; end
  else if    (din [0]==1)     begin dout3 =3'b000; dout5 = 5'b00001; end
  else if    (din [1]==1)     begin dout3 =3'b001; dout5 = 5'b00010; end
  else if    (din [2]==1)     begin dout3 =3'b010; dout5 = 5'b00100; end
  else if    (din [3]==1)     begin dout3 =3'b011; dout5 = 5'b01000; end
  else if    (din [4]==1)     begin dout3 =3'b100; dout5 = 5'b10000; end
  else                        begin dout3 =3'b111; dout5 = 5'b00000; end

end

endmodule


 /*********************Decoder***************************/
 
 module decoder(
 input logic enable, 
 input logic rst,
 input logic [3:0]dst_N,
 input logic [3:0]dst_E,
 input logic [3:0]dst_S,
 input logic [3:0]dst_W,
 input logic [3:0]dst_L,
 input logic [3:0]pos,
 output logic [4:0]in_N,
 output logic [4:0]in_E,
 output logic [4:0]in_S,
 output logic [4:0]in_W,
 output logic [4:0]in_L
 ); 
 

 
 always_comb  begin
 
 if(~rst) 
   in_N=5'b00000;
   else if (dst_N==4'b0000)
     in_N=5'b00000;
     else if (dst_N[1:0]>pos[1:0]) 
       in_N=5'b00001;
       else if (dst_N[3:2]>pos[3:2])
         in_N=5'b00010;
         else if  (dst_N[1:0]<pos[1:0])
           in_N=5'b00100;
           else if  (dst_N[3:2]<pos[3:2])
             in_N=5'b01000;
             else in_N=5'b10000;
 
end
 

 always_comb  begin
 
 if(~rst) 
   in_E=5'b00000;
   else if (dst_E==4'b0000)
     in_E=5'b00000;
     else if (dst_E[1:0]>pos[1:0]) 
       in_E=5'b00001;
       else if (dst_E[3:2]>pos[3:2])
         in_E=5'b00010;
         else if  (dst_E[1:0]<pos[1:0])
           in_E=5'b00100;
           else if  (dst_E[3:2]<pos[3:2])
             in_E=5'b01000;
             else in_E=5'b10000;
 
end
 
 
 
 always_comb  begin
 
 if(~rst) 
   in_S=5'b00000;
   else if (dst_S==4'b0000)
     in_S=5'b00000;
     else if (dst_S[1:0]>pos[1:0]) 
       in_S=5'b00001;
       else if (dst_S[3:2]>pos[3:2])
         in_S=5'b00010;
         else if  (dst_S[1:0]<pos[1:0])
           in_S=5'b00100;
           else if  (dst_S[3:2]<pos[3:2])
             in_S=5'b01000;
             else in_S=5'b10000;
 
end
 
 
 
 always_comb  begin
 
 if(~rst) 
   in_W=5'b00000;
   else if (dst_W==4'b0000)
     in_W=5'b00000;
     else if (dst_W[1:0]>pos[1:0]) 
       in_W=5'b00001;
       else if (dst_W[3:2]>pos[3:2])
         in_W=5'b00010;
         else if  (dst_W[1:0]<pos[1:0])
           in_W=5'b00100;
           else if  (dst_W[3:2]<pos[3:2])
             in_W=5'b01000;
             else in_W=5'b10000;
 
end
 
 
 
 always_comb  begin
 
 if(~rst) 
   in_L=5'b00000;
   else if (dst_L==4'b0000)
     in_L=5'b00000;
     else if (dst_L[1:0]>pos[1:0]) 
       in_L=5'b00001;
       else if (dst_L[3:2]>pos[3:2])
         in_L=5'b00010;
         else if  (dst_L[1:0]<pos[1:0])
           in_L=5'b00100;
           else if  (dst_L[3:2]<pos[3:2])
             in_L=5'b01000;
             else in_L=5'b10000;
 
end
  
  
 endmodule
        


module decoder_2(
input logic [4:0]in_N,
input logic [4:0]in_E,
input logic [4:0]in_S,
input logic [4:0]in_W,
input logic [4:0]in_L,
output logic [4:0]out_N,
output logic [4:0]out_E,
output logic [4:0]out_S,
output logic [4:0]out_W,
output logic [4:0]out_L
);

always_comb
 begin
 out_N[4:0]<={in_L[0],in_W[0],in_S[0],in_E[0],in_N[0]};
 out_E[4:0]<={in_L[1],in_W[1],in_S[1],in_E[1],in_N[1]};
 out_S[4:0]<={in_L[2],in_W[2],in_S[2],in_E[2],in_N[2]};
 out_W[4:0]<={in_L[3],in_W[3],in_S[3],in_E[3],in_N[3]};
 out_L[4:0]<={in_L[4],in_W[4],in_S[4],in_E[4],in_N[4]};
 end

endmodule



/*********************FF***************************/


module dffr #(parameter int size = 36 )
               (
                 input logic [size-1:0] din,
                 input logic clk,
                 input logic rst,
                 input logic [size-1:0] rst_val,
                 input logic en,
                 output logic [size-1:0] q
               );
 
 
                 logic [size-1:0] d ;
                 bit [size-1:0] q_val; //FlipFlop State
                 
                 assign d[size-1:0] = din[size-1:0]; //Delay data in to prevent inf. loops
                 assign q = q_val ;
 
                 always @ (posedge clk) begin //Flops CLK
                      assert ( ~$isunknown(d) || ~rst ) else $error("Error:d is X or Z") ; //Do Not Flop an X
 
                      priority case ( 1'b1 )
                          (~rst): q_val[size-1:0] <= rst_val[size-1:0] ; //Reset is active low
                          ( en): q_val[size-1:0] <= d[size-1:0] ; //Enable is active high
                          (~en): q_val[size-1:0] <= q[size-1:0] ; //Enable is active high
                    endcase //end priority case
                end //end always_ff
 
endmodule //dffr


module dffr1 #(parameter int size = 1 )
               (
                 input logic [size-1:0] din,
                 input logic clk,
                 input logic rst,
                 input logic [size-1:0] rst_val,
                 input logic en,
                 output logic [size-1:0] q
               );
 
 
                 logic [size-1:0] d ;
                 bit [size-1:0] q_val; //FlipFlop State
                 
                 assign d[size-1:0] = din[size-1:0]; //Delay data in to prevent inf. loops
                 assign q = q_val ;
 
                 always @ (posedge clk) begin //Flops CLK
                      assert ( ~$isunknown(d) || ~rst ) else $error("Error:d is X or Z") ; //Do Not Flop an X
 
                      priority case ( 1'b1 )
                          (~rst): q_val[size-1:0] <= rst_val[size-1:0] ; //Reset is active low
                          ( en): q_val[size-1:0] <= d[size-1:0] ; //Enable is active high
                          (~en): q_val[size-1:0] <= q[size-1:0] ; //Enable is active high
                    endcase //end priority case
                end //end always_ff
 
endmodule //dffr1


module dffr2 #(parameter int size = 5 )
               (
                 input logic [size-1:0] din,
                 input logic clk,
                 input logic rst,
                 input logic [size-1:0] rst_val,
                 input logic en,
                 output logic [size-1:0] q
               );
 
 
                 logic [size-1:0] d ;
                 bit [size-1:0] q_val; //FlipFlop State
                 
                 assign d[size-1:0] = din[size-1:0]; //Delay data in to prevent inf. loops
                 assign q = q_val ;
 
                 always @ (posedge clk) begin //Flops CLK
                      assert ( ~$isunknown(d) || ~rst ) else $error("Error:d is X or Z") ; //Do Not Flop an X
 
                      priority case ( 1'b1 )
                          (~rst): q_val[size-1:0] <= rst_val[size-1:0] ; //Reset is active low
                          ( en): q_val[size-1:0] <= d[size-1:0] ; //Enable is active high
                          (~en): q_val[size-1:0] <= q[size-1:0] ; //Enable is active high
                    endcase //end priority case
                end //end always_ff
 
endmodule //dffr2


module dffr3 #(parameter int size = 3 )
               (
                 input logic [size-1:0] din,
                 input logic clk,
                 input logic rst,
                 input logic [size-1:0] rst_val,
                 input logic en,
                 output logic [size-1:0] q
               );
 
 
                 logic [size-1:0] d ;
                 bit [size-1:0] q_val; //FlipFlop State
                 
                 assign d[size-1:0] = din[size-1:0]; //Delay data in to prevent inf. loops
                 assign q = q_val ;
 
                 always @ (posedge clk) begin //Flops CLK
                      assert ( ~$isunknown(d) || ~rst ) else $error("Error:d is X or Z") ; //Do Not Flop an X
 
                      priority case ( 1'b1 )
                          (~rst): q_val[size-1:0] <= rst_val[size-1:0] ; //Reset is active low
                          ( en): q_val[size-1:0] <= d[size-1:0] ; //Enable is active high
                          (~en): q_val[size-1:0] <= q[size-1:0] ; //Enable is active high
                    endcase //end priority case
                end //end always_ff
 
endmodule //dffr3


/*module dffrx
    #(parameter int size1 = 1, 
       parameter int size2 = 1)
(
      input logic [size2-1:0] din[size1-1:0], 
      input logic clk, 
      input logic rst, 
      input logic [size2-1:0] rst_val[size1-1:0],
      input logic en, 
      output logic [size2-1:0] q[size1-1:0]
);
      genvar i ;
 
      generate
         for( i = 0 ; i < size1 ; i++ ) begin: loop_c 
             dffr #( size2 ) dnnn( din[i] , clk, rst, rst_val[i], en, q[i] );
         end 
       endgenerate 

endmodule //dffx*/