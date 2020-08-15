// HMTH (c)

module XMSyncer #(parameter DW = 2, N = 2) (
  input logic clk,
  input logic rstn,

  input  logic [DW-1:0] d,
  output logic [DW-1:0] q
);

genvar i;
generate
	for (i = 0; i < DW; i = i + 1) begin: sync_all_bit
	  XSyncer #(.N(N)) bit_sync (.clk(clk), .rstn(rstn), .d(d[i]), .q(q[i]));
	end
endgenerate
endmodule
// EOF
