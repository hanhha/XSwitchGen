// HMTH (c)
// Arbitrate requests from masters
// There is no dupplicated request to same target at output

module rsp_XArbiter (
    input logic clk
  , input logic rstn

  , input  logic [2:0] I0_req
  , output logic [2:0] I0_vreq
  , input  logic [2:0] I1_req
  , output logic [2:0] I1_vreq
  , input  logic [2:0] I2_req
  , output logic [2:0] I2_vreq
  , input  logic [2:0] I3_req
  , output logic [2:0] I3_vreq
  , input  logic [2:0] I4_req
  , output logic [2:0] I4_vreq
  , input logic [2:0] T_rdy
);

logic [2:0] I0_req_avail;
assign I0_req_avail = I0_req & T_rdy;

logic [2:0] I1_req_avail;
assign I1_req_avail = I1_req & T_rdy;

logic [2:0] I2_req_avail;
assign I2_req_avail = I2_req & T_rdy;

logic [2:0] I3_req_avail;
assign I3_req_avail = I3_req & T_rdy;

logic [2:0] I4_req_avail;
assign I4_req_avail = I4_req & T_rdy;


logic [4:0] T0_gnt, req_T0;
assign req_T0 = {I4_req_avail [0], I3_req_avail [0], I2_req_avail [0], I1_req_avail [0], I0_req_avail [0]};
XArbiter_RR #(5) T0_RR (.clk (clk), .rstn (rstn), .req (req_T0), .gnt (T0_gnt));

logic [4:0] T1_gnt, req_T1;
assign req_T1 = {I4_req_avail [1], I3_req_avail [1], I2_req_avail [1], I1_req_avail [1], I0_req_avail [1]};
XArbiter_RR #(5) T1_RR (.clk (clk), .rstn (rstn), .req (req_T1), .gnt (T1_gnt));

logic [4:0] T2_gnt, req_T2;
assign req_T2 = {I4_req_avail [2], I3_req_avail [2], I2_req_avail [2], I1_req_avail [2], I0_req_avail [2]};
XArbiter_RR #(5) T2_RR (.clk (clk), .rstn (rstn), .req (req_T2), .gnt (T2_gnt));


assign I0_vreq = {T2_gnt [0], T1_gnt [0], T0_gnt [0]};
assign I1_vreq = {T2_gnt [1], T1_gnt [1], T0_gnt [1]};
assign I2_vreq = {T2_gnt [2], T1_gnt [2], T0_gnt [2]};
assign I3_vreq = {T2_gnt [3], T1_gnt [3], T0_gnt [3]};
assign I4_vreq = {T2_gnt [4], T1_gnt [4], T0_gnt [4]};

`ifndef SYNTHESIS
// Validating inputs
// All I*_req are onehot0
  `ifndef RICHMAN
    integer I0_ones;
    integer I1_ones;
    integer I2_ones;
    integer I3_ones;
    integer I4_ones;
    integer i;

/* verilator lint_off WIDTH */
    always @(*) begin
      I0_ones = 0;
      I1_ones = 0;
      I2_ones = 0;
      I3_ones = 0;
      I4_ones = 0;
      for (i = 0; i < 3; i++) begin 
        I0_ones = I0_ones + I0_req [i];
        I1_ones = I1_ones + I1_req [i];
        I2_ones = I2_ones + I2_req [i];
        I3_ones = I3_ones + I3_req [i];
        I4_ones = I4_ones + I4_req [i];
      end
      assume (I0_ones <= 1);
      assume (I1_ones <= 1);
      assume (I2_ones <= 1);
      assume (I3_ones <= 1);
      assume (I4_ones <= 1);
    end
/* verilator lint_on WIDTH */
  `else
    always @(*) begin
      assume ($onehot0(I0_req));
      assume ($onehot0(I1_req));
      assume ($onehot0(I2_req));
      assume ($onehot0(I3_req));
      assume ($onehot0(I4_req));
    end
  `endif

// Verifying output
  always @(*) begin
    assert ((I0_vreq ^ I1_vreq) == (I0_vreq | I1_vreq));
    assert ((I0_vreq ^ I2_vreq) == (I0_vreq | I2_vreq));
    assert ((I0_vreq ^ I3_vreq) == (I0_vreq | I3_vreq));
    assert ((I0_vreq ^ I4_vreq) == (I0_vreq | I4_vreq));
    assert ((I1_vreq ^ I2_vreq) == (I1_vreq | I2_vreq));
    assert ((I1_vreq ^ I3_vreq) == (I1_vreq | I3_vreq));
    assert ((I1_vreq ^ I4_vreq) == (I1_vreq | I4_vreq));
    assert ((I2_vreq ^ I3_vreq) == (I2_vreq | I3_vreq));
    assert ((I2_vreq ^ I4_vreq) == (I2_vreq | I4_vreq));
    assert ((I3_vreq ^ I4_vreq) == (I3_vreq | I4_vreq));
  end

`endif

endmodule
// EOF
