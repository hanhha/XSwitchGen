// HMTH (c)

// Below Circular Controller must have LENGTH that is power of 2 and > 1
module XCC #(parameter LENGTH = 4, INIT_FULL = 0) (
    input  logic clk
  , input  logic rstn

  , input  logic we
  , input  logic re

	, output logic we_ok
	, output logic [$clog2(LENGTH)-1:0] wptr
	, output logic [$clog2(LENGTH)-1:0] rptr

  , output logic full_n
  , output logic empty_n
  , output logic [AW:0] length
);

localparam AW = LENGTH > 1 ? $clog2(LENGTH) : 1;

logic re_ok;
logic [AW-1:0] nxt_rptr;
logic r_ovf, nxt_r_ovf, tmp_nxt_r_ovf;

logic [AW-1:0] nxt_wptr;
logic w_ovf, nxt_w_ovf, tmp_nxt_w_ovf;

assign length = {w_ovf, wptr} - {r_ovf, rptr};

assign re_ok                     = re & empty_n;
assign {tmp_nxt_r_ovf, nxt_rptr} = re_ok ? rptr + 1'b1 : {1'b0, rptr}; 
assign nxt_r_ovf                 = r_ovf ^ tmp_nxt_r_ovf;

`ifndef SELECT_SRSTn
always_ff @(posedge clk or negedge rstn) begin
`else
always_ff @(posedge clk) begin
`endif
  if (~rstn) begin
    {r_ovf, rptr} <= {1'b0, {AW{1'b0}}};
    empty_n       <= INIT_FULL == 0 ? 1'b0 : 1'b1;
  end else begin
    {r_ovf, rptr} <= {nxt_r_ovf, nxt_rptr};
		empty_n       <= {nxt_w_ovf, nxt_wptr} == {nxt_r_ovf, nxt_rptr} ? 1'b0 : 1'b1;
  end
end

assign we_ok                     = we & full_n;
assign {tmp_nxt_w_ovf, nxt_wptr} = we_ok ? wptr + 1'b1 : {1'b0, wptr}; 
assign nxt_w_ovf                 = w_ovf ^ tmp_nxt_w_ovf;

`ifndef SELECT_SRSTn
always_ff @(posedge clk or negedge rstn) begin
`else
always_ff @(posedge clk) begin
`endif
  if (~rstn) begin
    {w_ovf, wptr} <= INIT_FULL == 0 ? {1'b0, {AW{1'b0}}} : {1'b1, {AW{1'b0}}};
    full_n        <= INIT_FULL == 0 ? 1'b1 : 1'b0;
  end else begin
    {w_ovf, wptr} <= {nxt_w_ovf, nxt_wptr};
		full_n        <= {nxt_w_ovf, nxt_wptr} == {~nxt_r_ovf, nxt_rptr} ? 1'b0 : 1'b1;
  end
end

`ifndef SYNTHESIS
`ifdef FORMAL
initial restrict property (~rstn);

logic f_last_clk = 1'b0;
always @($global_clock) begin
  restrict property (clk == !f_last_clk);
  f_last_clk <= clk;
  if (!$rose(clk)) begin
    assume ($stable(rstn));
    assume ($stable(we));
    assume ($stable(re));
  end
end
`endif

logic f_past_vld = 1'b0;
always @(posedge clk)
  f_past_vld <= 1'b1;

initial assert (LENGTH[0] == 1'b0);

// Validating FIFO's behaviors
always @(posedge clk) begin
  assert (full_n | empty_n);    // Freemem buffer of allocator must be either full or empty exclusively
  if (f_past_vld & rstn)  begin
    if (($past(re) && ($past(empty_n) == 1'b0))) assert (rptr == $past(rptr));
    if (($past(we) && ($past(full_n) == 1'b0)))  assert (wptr == $past(wptr));
    if ($fell(full_n)) assert ($past(we));
    if ($rose(full_n)) assert ($past(re) & $past(empty_n));
    if ($fell(empty_n)) assert ($past(re));
    if ($rose(empty_n)) assert ($past(we) & $past(full_n));
    assert (((length == LENGTH) & (~full_n)) | ((length < LENGTH) & full_n));
    assert (((length == 0) & (~empty_n))     | ((length > 0) & empty_n));
    assert ((length[AW] == 1'b0) || (length[AW-1:0] == '0));
  end
end
`endif
endmodule
// EOF
