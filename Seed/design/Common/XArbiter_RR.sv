// HMTH (c)

// Round-robin arbiter

module XArbiter_RR #(parameter REQ_N = <%=n_initiators%>) (
    input logic clk
  , input logic rstn

  , input  logic [REQ_N-1:0] req
  , output logic [REQ_N-1:0] gnt
);

logic [REQ_N-1:0] mask, nxt_mask;
logic [REQ_N-1:0] masked_req;

XArbFirstOneBit #(.DW(REQ_N), .MASK_OUT(1)) mask_gen (.i(gnt), .o(nxt_mask));

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (~rstn) mask <= {REQ_N{1'b1}};
  else       mask <= |gnt ? nxt_mask : mask;
end

assign masked_req = req & mask;

logic [REQ_N-1:0] pre_gnt, pos_gnt;

// Before pivot
XArbFirstOneBit #(.DW(REQ_N), .MASK_OUT(0)) pre_gnt_gen (.i(req), .o(pre_gnt));

// After pivot
XArbFirstOneBit #(.DW(REQ_N), .MASK_OUT(0)) pos_gnt_gen (.i(masked_req), .o(pos_gnt));

assign gnt = |masked_req ? pos_gnt : pre_gnt;

`ifndef SYNTHESIS
  `ifndef RICHMAN
    integer ones;
    integer i;

		/* verilator lint_off WIDTH */
    always @(*) begin
      ones = 0;
      for (i = 0; i < REQ_N; i++) begin 
        ones = ones + gnt [i];
      end
      if (|req) assert (ones == 1);
    end
		/* verilator lint_on WIDTH */
  `else
    always @(*) begin
      assert (req |-> $onehot0 (gnt));
    end
  `endif
`endif

endmodule
// EOF
