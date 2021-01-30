// HMTH (c)

// Below FIFO must have DEPTH that is power of 2
module XFf #(parameter DW = 8, DEPTH = 4) (
    input  logic clk
  , input  logic rstn

  , input  logic we
  , input  logic re

	, input  [DW-1:0] d
	, output [DW-1:0] q

  , output logic full_n
  , output logic empty_n
);

localparam AW = DEPTH > 1 ? $clog2(DEPTH) : 1;

logic [AW-1:0] rptr, wptr;
logic          we_ok;

XCC #(.LENGTH(DEPTH), .INIT_FULL(0))
	Ctrl (.clk(clk), .rstn(rstn), .we(we), .re(re), .full_n(full_n), .empty_n(empty_n),
				.we_ok(we_ok), .wptr(wptr), .rptr(rptr), .length());

XTPMem #(.DW(DW), .DEPTH(DEPTH))
	Mem (.clk(clk), .we(we_ok), .waddr(wptr), .raddr(rptr), .d(d), .q(q));

endmodule
// EOF
