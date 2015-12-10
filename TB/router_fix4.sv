module router #(parameter WIDTH=36,DEPTH=8,ADDR=4,lhsCount=5,rhsCount=5)
( 
input clk, reset_b,
input [WIDTH-1:0] bustorouter_data[4:0],
input bustorouter_ready [4:0],
input bustorouter_valid [4:0],
input [1:0]X,Y,
output [WIDTH-1:0] routertobus_data [4:0],
output routertobus_ready [4:0],
output routertobus_valid [4:0]
); 

reg [WIDTH-1:0] routertobus_data_reg [4:0]; 
assign routertobus_data [0] = routertobus_data_reg [0];
assign routertobus_data [1] = routertobus_data_reg [1];
assign routertobus_data [2] = routertobus_data_reg [2];
assign routertobus_data [3] = routertobus_data_reg [3];
assign routertobus_data [4] = routertobus_data_reg [4];	 

logic routertobus_valid_reg [4:0];
assign routertobus_valid[0] = routertobus_valid_reg[0];	
assign routertobus_valid[1] = routertobus_valid_reg[1];
assign routertobus_valid[2] = routertobus_valid_reg[2];
assign routertobus_valid[3] = routertobus_valid_reg[3];
assign routertobus_valid[4] = routertobus_valid_reg[4];

logic[WIDTH-1:0] data_pop [4:0];
logic[WIDTH-1:0] data_pop_next [4:0];
logic[WIDTH-1:0] data_pop_temp [4:0];
logic[WIDTH-1:0] data_pop_final [4:0];
logic pop_pre [4:0];
logic pop_post [4:0];
logic local_empty [4:0];
logic local_almost_empty [4:0];
logic full [4:0];
logic full_pre [4:0];
logic [WIDTH-1:0] data_left[lhsCount-1:0];
logic [2:0] data_right_src_addr[rhsCount-1:0];
logic[WIDTH-1:0] data_temp0,data_temp1,data_temp2,data_temp3,data_temp4;
logic[4:0] request [4:0];
logic[4:0] request_temp [4:0];
logic[4:0] request_post [4:0];
logic[4:0] next_full [4:0];
logic blocked [4:0];
logic [4:0] post_priority [4:0];
//logic routertobus_valid_temp [4:0];
logic routertobus_ready_temp [4:0];
logic [WIDTH-1:0] data_push[4:0];
logic push [4:0];
logic [2:0] counter_pre [4:0];
logic [2:0] counter [4:0];
logic [2:0] wrtPtr_next_pre [4:0];
logic [2:0] wrtPtr_next [4:0];
logic [2:0] rdPtr_next_pre [4:0];
logic [2:0] rdPtr_next [4:0];



FIFO fifoN (
.counter_pre(counter_pre[0]),
.counter(counter[0]),
.wrtPtr_next_pre(wrtPtr_next_pre[0]),
.wrtPtr_next(wrtPtr_next[0]),
.rdPtr_next_pre(rdPtr_next_pre[0]),
.rdPtr_next(rdPtr_next[0]),
.full(full[0]),
.full_pre(full_pre[0]),
.data_push(data_push[0]),
.data_pop(data_pop[0]),
.data_pop_next(data_pop_next[0]),
.push(push[0]),
.pop(pop_post[0]),
.rst_val(36'h000000000),
.almost_full(routertobus_ready_temp[0]),
.empty(local_empty[0]),
.almost_empty(local_almost_empty[0]),
.rst(reset_b),
.clk(clk));


FIFO fifoE (
.counter_pre(counter_pre[1]),
.counter(counter[1]),
.wrtPtr_next_pre(wrtPtr_next_pre[1]),
.wrtPtr_next(wrtPtr_next[1]),
.rdPtr_next_pre(rdPtr_next_pre[1]),
.rdPtr_next(rdPtr_next[1]),
.full(full[1]),
.full_pre(full_pre[1]),
.data_push(data_push[1]),
.data_pop(data_pop[1]),
.data_pop_next(data_pop_next[1]),
.push(push[1]),
.pop(pop_post[1]),
.rst_val(36'h000000000),
.almost_full(routertobus_ready_temp[1]),
.empty(local_empty[1]),
.almost_empty(local_almost_empty[1]),
.rst(reset_b),
.clk(clk));


FIFO fifoS (
.counter_pre(counter_pre[2]),
.counter(counter[2]),
.wrtPtr_next_pre(wrtPtr_next_pre[2]),
.wrtPtr_next(wrtPtr_next[2]),
.rdPtr_next_pre(rdPtr_next_pre[2]),
.rdPtr_next(rdPtr_next[2]),
.full(full[2]),
.full_pre(full_pre[2]),
.data_push(data_push[2]),
.data_pop(data_pop[2]),
.data_pop_next(data_pop_next[2]),
.push(push[2]),
.pop(pop_post[2]),
.rst_val(36'h000000000),
.almost_full(routertobus_ready_temp[2]),
.empty(local_empty[2]),
.almost_empty(local_almost_empty[2]),
.rst(reset_b),
.clk(clk));


FIFO fifoW (
.counter_pre(counter_pre[3]),
.counter(counter[3]),
.wrtPtr_next_pre(wrtPtr_next_pre[3]),
.wrtPtr_next(wrtPtr_next[3]),
.rdPtr_next_pre(rdPtr_next_pre[3]),
.rdPtr_next(rdPtr_next[3]),
.full(full[3]),
.full_pre(full_pre[3]),
.data_push(data_push[3]),
.data_pop(data_pop[3]),
.data_pop_next(data_pop_next[3]),
.push(push[3]),
.pop(pop_post[3]),
.rst_val(36'h000000000),
.almost_full(routertobus_ready_temp[3]),
.empty(local_empty[3]),
.almost_empty(local_almost_empty[3]),
.rst(reset_b),
.clk(clk));


FIFO fifoL (
.counter_pre(counter_pre[4]),
.counter(counter[4]),
.wrtPtr_next_pre(wrtPtr_next_pre[4]),
.wrtPtr_next(wrtPtr_next[4]),
.rdPtr_next_pre(rdPtr_next_pre[4]),
.rdPtr_next(rdPtr_next[4]),
.full(full[4]),
.full_pre(full_pre[4]),
.data_push(data_push[4]),
.data_pop(data_pop[4]),
.data_pop_next(data_pop_next[4]),
.push(push[4]),
.pop(pop_post[4]),
.rst_val(36'h000000000),
.almost_full(routertobus_ready_temp[4]),
.empty(local_empty[4]),
.almost_empty(local_almost_empty[4]),
.rst(reset_b),
.clk(clk));



mux muxn (
.data_pop(data_pop[0]),
.data_pop_next(data_pop_next[0]),
.pop(pop_pre[0]),
.data_temp(data_pop_temp[0])
);

mux muxe (
.data_pop(data_pop[1]),
.data_pop_next(data_pop_next[1]),
.pop(pop_pre[1]),
.data_temp(data_pop_temp[1])
);

mux muxw (
.data_pop(data_pop[2]),
.data_pop_next(data_pop_next[2]),
.pop(pop_pre[2]),
.data_temp(data_pop_temp[2])
);

mux muxs (
.data_pop(data_pop[3]),
.data_pop_next(data_pop_next[3]),
.pop(pop_pre[3]),
.data_temp(data_pop_temp[3])
);

mux muxl (
.data_pop(data_pop[4]),
.data_pop_next(data_pop_next[4]),
.pop(pop_pre[4]),
.data_temp(data_pop_temp[4])
);



matrix decoder_0 (
.data_temp(data_pop_temp),
.data_temp0(data_temp0),
.data_temp1(data_temp1),
.data_temp2(data_temp2),
.data_temp3(data_temp3),
.data_temp4(data_temp4)
);




decoder decoder1(
.enable(clk),
.rst(reset_b),
.dst_N(data_temp0[3:0]),
.dst_E(data_temp1[3:0]),
.dst_S(data_temp2[3:0]),
.dst_W(data_temp3[3:0]),
.dst_L(data_temp4[3:0]),
.pos({X,Y}),
.in_N(request_temp[0]),
.in_E(request_temp[1]),
.in_S(request_temp[2]),
.in_W(request_temp[3]),
.in_L(request_temp[4])
);

decoder_2 decoder2(
.out_N(request[0]),
.out_E(request[1]),
.out_S(request[2]),
.out_W(request[3]),
.out_L(request[4]),
.in_N(request_temp[0]),
.in_E(request_temp[1]),
.in_S(request_temp[2]),
.in_W(request_temp[3]),
.in_L(request_temp[4])
);






priority_encoder encoder0 (
.clk(clk),
.rst(reset_b),
.din (request_post[0]),
.bustorouter_ready (bustorouter_ready[0]),
.dout3 (data_right_src_addr[0]),
.dout5 (post_priority[0])
);

priority_encoder encoder1 (
.clk(clk),
.rst(reset_b),
.din (request_post[1]),
.bustorouter_ready (bustorouter_ready[1]),
.dout3 (data_right_src_addr[1]),
.dout5 (post_priority[1])
);

priority_encoder encoder2 (
.clk(clk),
.rst(reset_b),
.din (request_post[2]),
.bustorouter_ready (bustorouter_ready[2]),
.dout3 (data_right_src_addr[2]),
.dout5 (post_priority[2])
);

priority_encoder encoder3 (
.clk(clk),
.rst(reset_b),
.din (request_post[3]),
.bustorouter_ready (bustorouter_ready[3]),
.dout3 (data_right_src_addr[3]),
.dout5 (post_priority[3])
);

priority_encoder encoder4 (
.clk(clk),
.rst(reset_b),
.din (request_post[4]),
.bustorouter_ready (bustorouter_ready[4]),
.dout3 (data_right_src_addr[4]),
.dout5 (post_priority[4])
);


findblock router_findblock (
//.request(request),
.post_priority(post_priority),
.clk(clk),
.rst(reset_b),
//.local_empty(local_empty),
.next_local_pop(pop_pre)
);


crossbar router_crossbar (
.clk(clk),
.rst_val(36'h000000000),
.data_left(data_pop_final),
.data_right_src_addr(data_right_src_addr),
.data_right(routertobus_data_reg)
);



rdy_en rdy_out_ins(
.clk(clk),
.data_right_src_addr(data_right_src_addr),
.next_local_pop(pop_pre),
.rdy_en(routertobus_valid_reg)
);



dffr dff_data_0(
.din(data_pop_temp[0]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_pop_final[0])
);

dffr dff_data_1(
.din(data_pop_temp[1]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_pop_final[1])
);

dffr dff_data_2(
.din(data_pop_temp[2]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_pop_final[2])
);

dffr dff_data_3(
.din(data_pop_temp[3]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_pop_final[3])
);

dffr dff_data_4(
.din(data_pop_temp[4]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_pop_final[4])
);


/*
dffr1 dff_r2b_0(
.din(routertobus_valid_temp[0]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_valid[0])
);

dffr1 dff_r2b_1(
.din(routertobus_valid_temp[1]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_valid[1])
);

dffr1 dff_r2b_2(
.din(routertobus_valid_temp[2]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_valid[2])
);

dffr1 dff_r2b_3(
.din(routertobus_valid_temp[3]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_valid[3])
);

dffr1 dff_r2b_4(
.din(routertobus_valid_temp[4]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_valid[4])
);
*/



dffr1 dff6_0(
.din(pop_pre[0]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(pop_post[0])
);

dffr1 dff6_1(
.din(pop_pre[1]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(pop_post[1])
);

dffr1 dff6_2(
.din(pop_pre[2]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(pop_post[2])
);

dffr1 dff6_3(
.din(pop_pre[3]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(pop_post[3])
);

dffr1 dff6_4(
.din(pop_pre[4]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(pop_post[4])
);



dffr1 dff7_0(
.din(routertobus_ready_temp[0]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_ready[0])
);

dffr1 dff7_1(
.din(routertobus_ready_temp[1]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_ready[1])
);

dffr1 dff7_2(
.din(routertobus_ready_temp[2]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_ready[2])
);

dffr1 dff7_3(
.din(routertobus_ready_temp[3]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_ready[3])
);

dffr1 dff7_4(
.din(routertobus_ready_temp[4]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(routertobus_ready[4])
);



dffr dff8_0(
.din(bustorouter_data[0]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_push[0])
);

dffr dff8_1(
.din(bustorouter_data[1]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_push[1])
);

dffr dff8_2(
.din(bustorouter_data[2]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_push[2])
);

dffr dff8_3(
.din(bustorouter_data[3]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_push[3])
);

dffr dff8_4(
.din(bustorouter_data[4]),
.clk(clk),
.rst(reset_b),
.rst_val(36'h000000000),
.en(1'b1),
.q(data_push[4])
);



dffr1 dff9_0(
.din(bustorouter_valid[0]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(push[0])
);

dffr1 dff9_1(
.din(bustorouter_valid[1]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(push[1])
);

dffr1 dff9_2(
.din(bustorouter_valid[2]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(push[2])
);

dffr1 dff9_3(
.din(bustorouter_valid[3]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(push[3])
);

dffr1 dff9_4(
.din(bustorouter_valid[4]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(push[4])
);


dffr1 dffa_0(
.din(full[0]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(full_pre[0])
);

dffr1 dffa_1(
.din(full[1]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(full_pre[1])
);

dffr1 dffa_2(
.din(full[2]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(full_pre[2])
);

dffr1 dffa_3(
.din(full[3]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(full_pre[3])
);

dffr1 dffa_4(
.din(full[4]),
.clk(clk),
.rst(reset_b),
.rst_val(1'b0),
.en(1'b1),
.q(full_pre[4])
);



dffr3 dffb_0(
.din(counter[0]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(counter_pre[0])
);

dffr3 dffb_1(
.din(counter[1]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(counter_pre[1])
);

dffr3 dffb_2(
.din(counter[2]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(counter_pre[2])
);

dffr3 dffb_3(
.din(counter[3]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(counter_pre[3])
);

dffr3 dffb_4(
.din(counter[4]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(counter_pre[4])
);


dffr3 dffc_0(
.din(wrtPtr_next[0]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(wrtPtr_next_pre[0])
);

dffr3 dffc_1(
.din(wrtPtr_next[1]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(wrtPtr_next_pre[1])
);

dffr3 dffc_2(
.din(wrtPtr_next[2]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(wrtPtr_next_pre[2])
);

dffr3 dffc_3(
.din(wrtPtr_next[3]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(wrtPtr_next_pre[3])
);

dffr3 dffc_4(
.din(wrtPtr_next[4]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(wrtPtr_next_pre[4])
);



dffr3 dffd_0(
.din(rdPtr_next[0]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(rdPtr_next_pre[0])
);

dffr3 dffd_1(
.din(rdPtr_next[1]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(rdPtr_next_pre[1])
);

dffr3 dffd_2(
.din(rdPtr_next[2]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(rdPtr_next_pre[2])
);

dffr3 dffd_3(
.din(rdPtr_next[3]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(rdPtr_next_pre[3])
);

dffr3 dffd_4(
.din(rdPtr_next[4]),
.clk(clk),
.rst(reset_b),
.rst_val(3'b000),
.en(1'b1),
.q(rdPtr_next_pre[4])
);



dffr2 dff2_0(
.din(request[0]),
.clk(clk),
.rst(reset_b),
.rst_val(5'b00000),
.en(1'b1),
.q(request_post[0])
);

dffr2 dff2_1(
.din(request[1]),
.clk(clk),
.rst(reset_b),
.rst_val(5'b00000),
.en(1'b1),
.q(request_post[1])
);

dffr2 dff2_2(
.din(request[2]),
.clk(clk),
.rst(reset_b),
.rst_val(5'b00000),
.en(1'b1),
.q(request_post[2])
);

dffr2 dff2_3(
.din(request[3]),
.clk(clk),
.rst(reset_b),
.rst_val(5'b00000),
.en(1'b1),
.q(request_post[3])
);

dffr2 dff2_4(
.din(request[4]),
.clk(clk),
.rst(reset_b),
.rst_val(5'b00000),
.en(1'b1),
.q(request_post[4])
);

endmodule

