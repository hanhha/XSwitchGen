// HMTH (c)

// Below FIFO must have DEPTH that is power of 2
module XFifo #(parameter DW = 8, DEPTH = 4) (
    input  logic clk
  , input  logic rstn

  , input  logic we
  , input  logic re

	, input  [DW-1:0] din
	, output [DW-1:0] dout

  , output logic full_n
  , output logic empty_n
);

localparam AW = DEPTH > 1 ? $clog2(DEPTH) : 1;

logic [AW-1:0] rptr, wptr;
logic          we_ok;

XFifoCtrl #(DEPTH)
	Ctrl (.clk(clk), .rstn(rstn), .we(we), .re(re), .full_n(full_n), .empty_n(empty_n),
				.we_ok(we_ok), .wptr(wptr), .rptr(rptr));

XTPMem #(.DW(DW), .DEPTH(DEPTH))
	Mem (.clk(clk), .we(we_ok), .waddr(wptr), .raddr(rptr), .d(din), .q(dout));

endmodule

// Below FIFO must have DEPTH that is power of 2 and > 1
module XFifoCtrl #(parameter DEPTH = 4) (
    input  logic clk
  , input  logic rstn

  , input  logic we
  , input  logic re

	, output logic we_ok
	, output logic [$clog2(DEPTH)-1:0] wptr
	, output logic [$clog2(DEPTH)-1:0] rptr

  , output logic full_n
  , output logic empty_n
);

localparam AW = DEPTH > 1 ? $clog2(DEPTH) : 1;

`ifndef SYNTHESIS
	initial begin
		assert (DEPTH[0] == 1'b0);
	end
`endif

logic re_ok;
logic [AW-1:0] nxt_rptr;
logic r_ovf, nxt_r_ovf, tmp_nxt_r_ovf;

logic [AW-1:0] nxt_wptr;
logic w_ovf, nxt_w_ovf, tmp_nxt_w_ovf;

assign re_ok                     = re & empty_n;
assign {tmp_nxt_r_ovf, nxt_rptr} = re_ok ? rptr + 1'b1 : {1'b0, rptr}; 
assign nxt_r_ovf                 = r_ovf ^ tmp_nxt_r_ovf;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (rstn == 1'b0) begin
    {r_ovf, rptr} <= {1'b0, {AW{1'b0}}};
    empty_n       <= 1'b0;
  end else begin
    {r_ovf, rptr} <= {nxt_r_ovf, nxt_rptr};
		empty_n       <= {nxt_w_ovf, nxt_wptr} == {nxt_r_ovf, nxt_rptr} ? 1'b0 : 1'b1;
  end
end

assign we_ok                     = we & full_n;
assign {tmp_nxt_w_ovf, nxt_wptr} = we_ok ? wptr + 1'b1 : {1'b0, wptr}; 
assign nxt_w_ovf                 = w_ovf ^ tmp_nxt_w_ovf;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (rstn == 1'b0) begin
    {w_ovf, wptr} <= {1'b0, {AW{1'b0}}};
    full_n        <= 1'b1;
  end else begin
    {w_ovf, wptr} <= {nxt_w_ovf, nxt_wptr};
		full_n        <= {nxt_w_ovf, nxt_wptr} == {~nxt_r_ovf, nxt_rptr} ? 1'b0 : 1'b1;
  end
end

`ifndef SYNTHESIS
`ifdef FORMAL
logic init = 1'b1;
always @(posedge clk) begin
  if (init) assume (~rstn);
  init <= 1'b0;
end

// Validating FIFO's behaviors
logic [AW:0] entry_cnt;

always @(posedge clk or negedge rstn) begin
  if (~rstn) entry_cnt <= {(AW+1){1'b0}};
  else begin
    case ({we & full_n, re & empty_n})
      2'b00, 2'b11: entry_cnt <= entry_cnt;
      2'b01: entry_cnt <= entry_cnt - 1'b1;
      2'b10: entry_cnt <= entry_cnt + 1'b1;
      default: entry_cnt <= entry_cnt;
    endcase
  end
end

always @(posedge clk) begin
  if (rstn) begin
    assert (entry_cnt >= 0 && entry_cnt <= DEPTH); // Entry counter must not overflow/underflow
    if (empty_n == 1'b0) assert (entry_cnt == 0);
    if (full_n  == 1'b0) assert (entry_cnt == DEPTH);
  end
end
`endif
`endif
endmodule
// EOF
