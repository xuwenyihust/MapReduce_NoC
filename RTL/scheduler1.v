module scheduler1(clk, reset, wen, enablein, datain, dataout, full, empty, enableout);

parameter data_width = 32;
//parameter data_width1 = 34;
// 
parameter data_width1 = 36;
parameter address_width = 5;
parameter FIFO_depth = 1024;


input clk,reset,wen,enablein;
input [data_width-1:0] datain;
output [data_width1-1:0] dataout;
output full,empty;
output enableout;


reg[31:0] write_p,read_p;
reg[address_width:0] counter;
reg[data_width-1:0] dataout1;
wire[data_width1-1:0] dataout;
reg [data_width-1:0] memory[FIFO_depth-1:0];
reg[data_width-1:0] keywordnumber,textfilenumber;
reg enableout1;
reg[3:0] routeraddress;
reg wen1;
reg [data_width-1:0] datain1;
reg ren;
reg counter1;


always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   wen1=0;
else 
if(wen)
   wen1=1;
else
//if(write_p!=0&&write_p!=1&&datain1==32'b11111111111111111111111111111111)
if(write_p!=0&&write_p!=1&&datain1==32'b11111111111111111111111111111111)
   wen1=0;
else
   wen1=wen1;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   ren=0;
else
//if(write_p!=0&&write_p!=1&&datain1==32'b11111111111111111111111111111111)
if(write_p!=0&&write_p!=1&&datain1==32'b11111111111111111111111111111111)
   ren=1;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   counter1=0;
else
if(wen&&counter1<2)
   counter1=counter1+1;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   dataout1=0;
else 
if(wen1&&(write_p<FIFO_depth-1)&&(enableout1==1))
   dataout1=dataout1+1;	
// Added by me.
else
	dataout1=0;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   //routeraddress=0;
   routeraddress=4'b0000;
else 
if(wen1&&(write_p<FIFO_depth-1)&&(enableout1==1))
   //routeraddress=2;
   routeraddress=4'b0001;
else
if(ren&&(read_p<write_p)&&(write_p<FIFO_depth-1))
   //routeraddress=1;
   routeraddress=4'b1001;
else
   //routeraddress=0; 
   routeraddress=4'b0000;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   enableout1=0;
else 
if(wen1)
   enableout1=1;
else
if(ren&&(read_p<write_p))
   enableout1=1;
else
   enableout1=0;
end



always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   read_p=2;
else if(ren&&(read_p<write_p)&&(read_p<FIFO_depth))
   read_p=read_p+1;
else
   read_p=read_p;
end


always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   dataout1=0; 
else if(ren&&(read_p<=write_p)&&(enableout1==1)) 
   dataout1=memory[read_p];
end


//*************
reg end_f;
always@(posedge clk or negedge reset)
	if(!reset)
		end_f <= 0;
	else if(datain == 32'hffffffff)
		end_f <= 1'b1;
	else 
		end_f <= end_f;
//*************

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   write_p=0;
else 								  
									
if(enablein&&(write_p<FIFO_depth-1)&&(end_f==0))
   write_p=write_p+1;
else
   write_p=write_p;
end

always@(posedge clk)
begin
if(wen1&&enablein==1)
   memory[write_p]=datain;
   datain1=datain;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
   counter=0;
else if(wen1&&!ren&&(counter!=FIFO_depth))
        counter=counter+1;
else if(ren&&!wen1&&(counter!=0))
        counter=counter-1;
end


always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
keywordnumber=0;
else if (write_p>=3)
keywordnumber=memory[2];
else
keywordnumber=0;
end

always@(posedge clk,negedge reset)
begin
//if(reset)	
if(!reset)
textfilenumber=0;
else if (write_p>=4)
textfilenumber=memory[3];
else
textfilenumber=0;
end


assign full=(counter==(FIFO_depth-1));
assign empty=(counter==0);
//
//assign dataout[31:0]=dataout1;
//assign dataout[33:32]=routeraddress; 
assign dataout[35:4]=dataout1;
assign dataout[3:0]=routeraddress; 
//
assign enableout=enableout1;





endmodule
