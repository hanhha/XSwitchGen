// HMTH (c)

// Round-robin arbiter

module XARR #(parameter N = <%=n_initiators%>) (
    input logic clk
  , input logic rstn

  , input  logic         en
  , input  logic [N-1:0] req
  , output logic [N-1:0] gnt
);

logic [N-1:0] mask, nxt_mask;
logic [N-1:0] masked_req;

XArbFirstOneBit #(.DW(N), .MASK_OUT(1)) mask_gen (.i(gnt), .o(nxt_mask));

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (~rstn) mask <= {N{1'b0}};
  else if (en & nxt_mask[N-1]) mask <= {nxt_mask [N-2:0], 1'b0};
end

assign masked_req = req & mask;

logic [REQ_N-1:0] pre_mask, pos_mask;

XF1b #(N) pre_gnt_gen (.i(req), .o(pre_mask));
XF1b #(N) pos_gnt_gen (.i(masked_req), .o(pos_mask));

assign nxt_mask = pos_mask [N-1] ? pos_mask : pre_mask;
assign gnt = en ? nxt_mask ^ {nxt_mask[N-2:0], 1'b0} : {N{1'b0}};

`ifndef SYNTHESIS
  `ifndef RICHMAN
    integer ones;
    integer i;

		/* verilator lint_off WIDTH */
    always @(*) begin
      ones = 0;
      for (i = 0; i < N; i++) begin 
        ones = ones + gnt [i];
      end
      if (en)
        if (|req) assert (ones == 1);
      else
        assert (ones == 0);
    end
		/* verilator lint_on WIDTH */
  `endif
`endif

endmodule
// EOF
