// HMTH (c)

// N inputs x M outputs switch with built-in arbiter
// Payload has DST_ID (=LU_N) + SRC_ID + AccessType + ADDR + ... + WrapType + Strb + real Data
module XSwNM #(parameter N = 2, M = 3, P = 10, D = 8) (
  // Quasi-static/Static configuration pins
  input  logic [M*M-1:0] lut, // lut [DEST_ID] = TGT_ID

  // Operation pins
  input  logic clk,
  input  logic rstn,

  input  logic [N-1:0]   vld_s,
  input  logic [N*P-1:0] pld_s, // [P-1:0] pld_s [0:N-1]
  output logic [N-1:0]   gnt_s,

  input  logic [N-1:0]   ocy,  // nth agent want to occupy slot from this transaction
  input  logic [N-1:0]   rel,  // nth agent want to release slot after this transaction

  output logic [M-1:0]   vld_m,
  output logic [M*P-1:0] pld_m, // [P-1:0] pld_m [0:M-1],
  input  logic [M-1:0]   gnt_m
);
localparam LU_N = $clog2(M);

logic [M-1:0]   i_vld [0:N-1], i_gnt [0:N-1];
logic [P*M-1:0] i_pld [0:N-1];
logic [M-1:0]   i_tgt [0:N-1];

genvar i, j, o;
generate
  for (i = 0; i < N; i++) begin: input_sw
    assign i_tgt [i] = lut [pld_s[(i+1)*P-1 -: LU_N]*M +: M];
    XSw1N #(.N(M), .D(P))
      Sw1N (.clk (clk), .rstn (rstn),
            .vld_s(vld_s[i]), .gnt_s(gnt_s[i]), .pld_s(pld_s[i*P +: P]), .tgt_s(i_tgt[i]),
            .vld_m(i_vld[i]), .gnt_m(i_gnt[i]), .pld_m(i_pld[i]));
  end

  if (N > 1) begin: NxM
    logic [N-1:0]   o_vld [0:M-1], o_gnt [0:M-1];
    logic [P*N-1:0] o_pld [0:M-1];

    for (o = 0; o < M; o++) begin: output_sw
      for (j = 0; j < N; j++) begin: internal // tranpose matrix
        assign o_vld [o][j]        = i_vld [j][o];
        assign o_pld [o][j*P +: P] = i_pld [j][o*P +: P];
        assign i_gnt [j][o]        = o_gnt [o][j];
      end

      XSwN1 #(.N(N), .D(P), .ARB_EN(1))
        SwN1 (.clk(clk), .rstn(rstn), .ocy(ocy), .rel(rel),
              .vld_s(o_vld[o]), .gnt_s(o_gnt[o]), .pld_s(o_pld[o]),
              .vld_m(vld_m[o]), .gnt_m(gnt_m[o]), .pld_m(pld_m[o*P +: P]));
    end
  end else begin: one_to_many 
    assign vld_m = i_vld;
    assign i_gnt = gnt_m;
    assign pld_m = i_pld;
  end

endgenerate

`ifndef SYNTHESIS
  `ifndef RICHMAN
    `ifdef FORMAL
      logic init = 1'b1;
      always_ff @(posedge clk) begin
        init <= 1'b0;
        if (init) assume (~rstn);
      end

      always_ff @(posedge clk)
        assume (lut == 9'b100_010_001);
    `endif
  `else
  `endif
`endif

endmodule

// 1 to N switch
module XSw1N #(parameter N = 2, D = 8) (
  input  logic         clk,
  input  logic         rstn,

  input  logic         vld_s,
  input  logic [D-1:0] pld_s,
  output logic         gnt_s,

  input  logic [N-1:0] tgt_s,

  output logic [N-1:0]   vld_m,
  output logic [N*D-1:0] pld_m,
  input  logic [N-1:0]   gnt_m
);

assign vld_m = {N{vld_s}} & tgt_s;

always_comb begin: pld_m_demux
  integer i;
  for (i = 0; i < N; i++)
    pld_m [i*D +: D] = pld_s;
end

`ifndef SYNTHESIS
  `ifndef RICHMAN
		/* verilator lint_off WIDTH */
    always_ff @(posedge clk) begin: onehot_check
      integer ai;
      integer ones;

      if (vld_s) begin
        ones = 0;
        for (ai = 0; ai < N; ai++) begin
          ones = ones + tgt_s [ai];
        end
        assume ((ones == 1)); // Target list must be one hot 
      end
    end
		/* verilator lint_on WIDTH */
  `else
  `endif
`endif

assign gnt_s = |(gnt_m & tgt_s);

endmodule

// N to 1 switch with built-in arbiter (if ARB_EN != 0)
// ARB_EN = 0 - No arbiter - input must guarantee onehot vector
// ARB_EN = 1 - Round robin
// ARB_EN = 2 - Priority
module XSwN1 #(parameter N = 2, D = 8, ARB_EN = 1) (
  input  logic clk,
  input  logic rstn,

  input  logic [N-1:0]   vld_s,
  input  logic [N*D-1:0] pld_s,
  output logic [N-1:0]   gnt_s,

  input  logic [N-1:0] ocy,
  input  logic [N-1:0] rel,

  output logic         vld_m,
  output logic [D-1:0] pld_m,
  input  logic         gnt_m
);

logic [N-1:0] fixed_gnt, nxt_fixed_gnt;
logic [N-1:0] i_vld_s;
logic occupied, nxt_occupied;

integer i;

always_comb begin
  for (i = 0; i < N; i++) begin
    nxt_fixed_gnt [i] = (~occupied & ocy [i] & gnt_s [i]) | (occupied & fixed_gnt [i] & ~rel [i]);
  end
end

`ifndef SELECT_SRSTn
always_ff @(posedge clk or negedge rstn) begin
`else
always_ff @(posedge clk) begin
`endif
  if (~rstn)
    fixed_gnt <= '0;
  else 
    fixed_gnt <= nxt_fixed_gnt;
end

always_comb begin
  nxt_occupied = 1'b0;
  for (i = 0; i < N; i++) begin
    nxt_occupied |= (~occupied & ocy [i] & gnt_s [i]);
  end
end

assign i_vld_s = fixed_gnt & vld_s;

assign vld_m = |i_vld_s;

always_comb begin
  pld_m = {D{1'b0}};
  for (i = 0; i < N; i++) begin
    pld_m = pld_m | ({D{gnt_s [i]}} & pld_s [i*D +: D]);
  end
end

generate
  if (ARB_EN == 1) begin: rr_arb
    XARR #(.N(N)) Arb (.clk(clk), .rstn(rstn), .req (i_vld_s), .gnt(gnt_s), .en(gnt_m));
  end else if (ARB_EN == 2) begin: pri_arb
    XAPr #(.N(N)) Arb (.req (i_vld_s), .gnt(gnt_s), .en(gnt_m));
  end else begin: no_arb
    assign gnt_s = {N{gnt_m}} & i_vld_s;
  end
endgenerate

`ifndef SYNTHESIS
  `ifndef RICHMAN
		/* verilator lint_off WIDTH */
    always_ff @(posedge clk)  begin: onehot1_check
      integer ones;
      integer ai;

      if (rstn) begin
        ones = 0;
        for (ai = 0; ai < N; ai++) begin 
          ones = ones + gnt_s [ai];
        end
        assert ((ones == 1)||(ones == 0));
      end
    end
		/* verilator lint_on WIDTH */
  `else
  `endif
`endif

endmodule
// EOF
