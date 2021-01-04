// HMTH (c)

// N inputs x M outputs switch with built-in arbiter
module XSwNM #(parameter N = 2, M = 2, DW = 8) (
  input  logic clk,
  input  logic rstn,

  input  logic [N-1:0]  vld_s,
  input  logic [DW-1:0] dat_s [0:N-1],
  output logic [N-1:0]  gnt_s,

  input  logic [M-1:0]  tgt_s [0:N-1],

  output logic [M-1:0]  vld_m,
  output logic [DW-1:0] dat_m [0:M-1],
  input  logic [M-1:0]  gnt_m
);

logic [M-1:0]  i_vld [0:N-1], i_gnt[0:N-1];
logic [DW-1:0] i_dat [0:N-1][0:M-1];

genvar i, j, o;
generate
  for (i = 0; i < N; i++) begin: input_sw
  XSw1N #(.N(M), .DW(DW))
    Sw1N (.vld_s(vld_s[i]), .gnt_s(gnt_s[i]), .dat_s(dat_s[i]), .tgt_s(tgt_s[i]),
          .vld_m(i_vld[i]), .gnt_m(i_gnt[i]), .dat_m(i_dat[i]));
  end

  if (N > 1) begin: NxM
    logic [N-1:0]  o_vld [0:M-1], o_gnt [0:M-1];
    logic [DW-1:0] o_dat [0:M-1][0:N-1];

    for (o = 0; o < M; o++) begin: output_sw
      for (j = 0; j < N; j++) begin: internal // tranpose matrix
        assign o_vld [o][j] = i_vld [j][o];
        assign o_dat [o][j] = i_dat [j][o];
        assign i_gnt [j][o] = o_gnt [o][j];
      end

      XSwN1 #(.N(N), .DW(DW), .ARB_EN(1))
        SwN1 (.clk(clk), .rstn(rstn),
              .vld_s(o_vld[o]), .gnt_s(o_gnt[o]), .dat_s(o_dat[o]),
              .vld_m(vld_m[o]), .gnt_m(gnt_m[o]), .dat_m(dat_m[o]));

  end
  end else begin: one_to_many 
    assign vld_m = i_vld;
    assign i_gnt = gnt_m;
    assign dat_m = i_dat;
  end

endgenerate

`ifndef SYNTHESIS
  `ifndef RICHMAN
    integer si, sj;
    integer stgt [0:M-1], stgt_gnt [0:M-1];
		/* verilator lint_off WIDTH */
    always @(posedge clk) begin
      if (rstn) begin
        for (si = 0; si < M; si++) begin
          if (vld_m [si] && gnt_m [si]) begin
            stgt [si] = 0;
            stgt_gnt [si] = 0;
            for (sj = 0; sj < N; sj++) begin
              stgt     [si] = stgt [si] + (tgt_s [sj][si] == 1'b1 ? vld_s [sj] : 1'b0);
              stgt_gnt [si] = stgt_gnt [si] + (tgt_s [sj][si] == 1'b1 ? (dat_m [si] == dat_s[sj]) & gnt_s [sj] & vld_s [sj] : 1'b0);
            end
            assert (stgt [si] > 1); // Had at least 1 access in slave side
            assert (stgt_gnt [si] == 1); // Only 1 req was acked
          end
        end
      end
    end
		/* verilator lint_on WIDTH */
  `else
  `endif
`endif

endmodule

// 1 to N switch
module XSw1N #(parameter N = 2, DW = 8) (
  input  logic          vld_s,
  input  logic [DW-1:0] dat_s,
  output logic          gnt_s,

  input  logic [N-1:0]  tgt_s,

  output logic [N-1:0]  vld_m,
  output logic [DW-1:0] dat_m [0:N-1],
  input  logic [N-1:0]  gnt_m
);

integer i;
always_comb begin
  for (i = 0; i < N; i++) begin
    vld_m [i] = vld_s & tgt_s [i];
    dat_m [i] = dat_s;
  end
end

`ifndef SYNTHESIS
  `ifndef RICHMAN
    integer ai;
    integer ones;

		/* verilator lint_off WIDTH */
    always_comb begin
      if (vld_s) begin
        ones = 0;
        for (ai = 0; ai < N; ai++) begin
          ones = ones + tgt_s [ai];
        end
        if (vld_s) assume ((ones == 1)); // Target list must be one hot 
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
module XSwN1 #(parameter N = 2, DW = 8, ARB_EN = 1) (
  input  logic clk,
  input  logic rstn,

  input  logic [N-1:0]  vld_s,
  input  logic [DW-1:0] dat_s [0:N-1],
  output logic [N-1:0]  gnt_s,

  output logic          vld_m,
  output logic [DW-1:0] dat_m,
  input  logic          gnt_m
);

assign vld_m = |vld_s;

integer i;
always_comb begin
  dat_m = {DW{1'b0}};
  for (i = 0; i < N; i++) begin
    dat_m = dat_m | ({DW{gnt_s [i]}} & dat_s [i]);
  end
end

generate
  if (ARB_EN == 1) begin: rr_arb
    XARR #(.N(N)) Arb (.clk(clk), .rstn(rstn), .req (vld_s), .gnt(gnt_s), .en(gnt_m));
  end else if (ARB_EN == 2) begin: pri_arb
    XAPr #(.N(N)) Arb (.req (vld_s), .gnt(gnt_s), .en(gnt_m));
  end else begin: no_arb
    assign gnt_s = {N{gnt_m}} & vld_s;
  end
endgenerate

`ifndef SYNTHESIS
  `ifndef RICHMAN
    integer ones;
    integer ai;

		/* verilator lint_off WIDTH */
    always @(posedge clk)  begin
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
