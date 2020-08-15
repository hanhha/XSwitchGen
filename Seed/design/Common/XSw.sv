// HMTH (c)

// N inputs x M outputs switch with built-in arbiter
module XSwNM #(parameter N = 2, M = 2, DW = 8) (
  input  logic clk,
  input  logic rstn,

  input  logic [N-1:0]    vld_i,
  input  logic [N*DW-1:0] dat_i,
  output logic [N-1:0]    gnt_i,

  input  logic [N*M-1:0]  sw_i,

  output logic [M-1:0]    vld_o,
  output logic [M*DW-1:0] dat_o,
  input  logic [M-1:0]    gnt_o
);

logic [N*M-1:0] i_vld, i_gnt;
logic [N*M*DW-1:0] i_dat;

genvar i, j, o;
generate
  for (i = 0; i < N; i++) begin: input_sw
  XSw1N #(.N(M), .DW(DW))
    Sw1N (.vld_i(vld_i[i]), .gnt_i(gnt_i[i]), .dat_i(dat_i[DW*i +: DW]), .sw_i(sw_i[M*i +: M]),
          .vld_o(i_vld[i*M +: M]), .gnt_o(i_gnt[i*M +: M]), .dat_o(i_dat[i*M*DW +: M*DW]));
  end

  if (N > 1) begin: NxM
    logic [N*M-1:0] o_vld, o_gnt;
    logic [N*M*DW-1:0] o_dat;

    for (o = 0; o < M; o++) begin: output_sw
      for (j = 0; j < N; j++) begin: internal // tranpose matrix
        assign o_vld [o*N+j] = i_vld [j*M+o];
        assign o_dat [DW*(o*N+j) +: DW] = i_dat [DW*(j*M+o) +: DW];
        assign i_gnt [j*M+o] = o_gnt [o*N+j];
      end

      XSwN1 #(.N(N), .DW(DW), .ARB_EN(1))
        SwN1 (.clk(clk), .rstn(rstn),
              .vld_i(o_vld[o*N +: N]), .gnt_i(o_gnt[o*N +: N]), .dat_i(o_dat[o*N*DW +: DW]),
              .vld_o(vld_o[o]), .gnt_o(gnt_o[o]), .dat_o(dat_o[DW*o +: DW]));

  end
  end else begin: 1xM 
    assign vld_o = i_vld;
    assign i_gnt = gnt_o;
    assign dat_o = i_dat;
  end

endgenerate

endmodule



// 1 to N switch
module XSw1N #(parameter N = 2, DW = 8) (
  input  logic          vld_i,
  input  logic [DW-1:0] dat_i,
  output logic          gnt_i,

  input  logic [N-1:0]  sw_i,

  output logic [N-1:0]    vld_o,
  output logic [N*DW-1:0] dat_o,
  input  logic [N-1:0]    gnt_o
);

integer i;
always_comb begin
  for (i = 0; i < N; i++) begin
    vld_o = vld_i & sw_i [i];
    dat_o [DW*i +: DW] = {N{sw_i}} & dat_i;
  end
end

assign gnt_i = |(gnt_o & sw_i);

endmodule



// N to 1 switch with built-in arbiter (if ARB_EN = 1)
module XSwN1 #(parameter N = 2, DW = 8, ARB_EN = 1) (
  input  logic clk,
  input  logic rstn,

  input  logic [N-1:0]    vld_i,
  input  logic [N*DW-1:0] dat_i,
  output logic [N-1:0]    gnt_i,

  output logic          vld_o,
  output logic [DW-1:0] dat_o,
  input  logic          gnt_o
);

assign vld_o = |vld_i;

integer i;
always_comb begin
  dat_o = {DW{1'b0}};
  for (i = 0; i < N; i++) begin
    dat_o = dat_o | ({DW{gnt_i [i]}} & dat_i [DW*i +: DW]);
  end
end

generate
  if (ARB_EN != 0) begin: need_arb
    XARR #(.N(N)) Arb (.clk(clk), .rstn(rstn), .req (vld_i), .gnt(gnt_i), .en(gnt_o));
  end else begin: no_arb
    gnt_i = {N{gnt_o}} & vld_i;
  end
endgenerate

`ifndef SYNTHESIS
  `ifndef RICHMAN
    integer ones;
    integer i;

		/* verilator lint_off WIDTH */
    always_comb begin
      ones = 0;
      for (i = 0; i < N; i++) begin 
        ones = ones + gnt_i [i];
      end
      assert ((ones == 1)||(ones == 0));
    end
		/* verilator lint_on WIDTH */
  `else
    always_comb begin
      assert ($onehot0 (gnt_i));
    end
  `endif
`endif

endmodule
// EOF
