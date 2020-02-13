// HMTH (c)
// Arbitrate requests from masters
// There is no dupplicated request to same target at output

module req_XArbiter (
    input logic clk
  , input logic rstn

  , input  logic [4:0] I0_req
  , output logic [4:0] I0_vreq
  , input  logic [4:0] I1_req
  , output logic [4:0] I1_vreq
  , input  logic [4:0] I2_req
  , output logic [4:0] I2_vreq
  , input logic [4:0] T_rdy
);

logic [4:0] I0_req_avail;
assign I0_req_avail = I0_req & T_rdy;

logic [4:0] I1_req_avail;
assign I1_req_avail = I1_req & T_rdy;

logic [4:0] I2_req_avail;
assign I2_req_avail = I2_req & T_rdy;


logic [2:0] T0_gnt, req_T0;
assign req_T0 = {I2_req_avail [0], I1_req_avail [0], I0_req_avail [0]};
XArbiter_RR #(3) T0_RR (.clk (clk), .rstn (rstn), .req (req_T0), .gnt (T0_gnt));

logic [2:0] T1_gnt, req_T1;
assign req_T1 = {I2_req_avail [1], I1_req_avail [1], I0_req_avail [1]};
XArbiter_RR #(3) T1_RR (.clk (clk), .rstn (rstn), .req (req_T1), .gnt (T1_gnt));

logic [2:0] T2_gnt, req_T2;
assign req_T2 = {I2_req_avail [2], I1_req_avail [2], I0_req_avail [2]};
XArbiter_RR #(3) T2_RR (.clk (clk), .rstn (rstn), .req (req_T2), .gnt (T2_gnt));

logic [2:0] T3_gnt, req_T3;
assign req_T3 = {I2_req_avail [3], I1_req_avail [3], I0_req_avail [3]};
XArbiter_RR #(3) T3_RR (.clk (clk), .rstn (rstn), .req (req_T3), .gnt (T3_gnt));

logic [2:0] T4_gnt, req_T4;
assign req_T4 = {I2_req_avail [4], I1_req_avail [4], I0_req_avail [4]};
XArbiter_RR #(3) T4_RR (.clk (clk), .rstn (rstn), .req (req_T4), .gnt (T4_gnt));


assign I0_vreq = {T4_gnt [0], T3_gnt [0], T2_gnt [0], T1_gnt [0], T0_gnt [0]};
assign I1_vreq = {T4_gnt [1], T3_gnt [1], T2_gnt [1], T1_gnt [1], T0_gnt [1]};
assign I2_vreq = {T4_gnt [2], T3_gnt [2], T2_gnt [2], T1_gnt [2], T0_gnt [2]};

`ifndef SYNTHESIS
// Validating inputs
// All I*_req are onehot0
  `ifndef RICHMAN
    integer I0_ones;
    integer I1_ones;
    integer I2_ones;
    integer i;

/* verilator lint_off WIDTH */
    always @(*) begin
      I0_ones = 0;
      I1_ones = 0;
      I2_ones = 0;
      for (i = 0; i < 5; i++) begin 
        I0_ones = I0_ones + I0_req [i];
        I1_ones = I1_ones + I1_req [i];
        I2_ones = I2_ones + I2_req [i];
      end
      assume (I0_ones <= 1);
      assume (I1_ones <= 1);
      assume (I2_ones <= 1);
    end
/* verilator lint_on WIDTH */
  `else
    always @(*) begin
      assume ($onehot0(I0_req));
      assume ($onehot0(I1_req));
      assume ($onehot0(I2_req));
    end
  `endif

// Verifying output
  always @(*) begin
    assert ((I0_vreq ^ I1_vreq) == (I0_vreq | I1_vreq));
    assert ((I0_vreq ^ I2_vreq) == (I0_vreq | I2_vreq));
    assert ((I1_vreq ^ I2_vreq) == (I1_vreq | I2_vreq));
  end

`endif

endmodule
// EOF
