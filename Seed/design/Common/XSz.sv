// HMTH (c)

// Non bufferred, bytelane based Upsizer/Downsizer for data
// Payload has DST_ID (=LU_N) + SRC_ID + AccessType + ADDR + ... + WrapType + Strb + real Data
module XSz #(parameter M = 3, N = 2, A = 19, DI = 32, DO = 64, PI = 50, PO = 86) (
    input  logic [PI-1:0] pld_s
  , output logic [PO-1:0] pld_m
);

localparam SO  = DO / 8;
localparam SI  = DI / 8;

localparam HIDX = $clog2 (SO) - 1;
localparam LIDX = $clog2 (SI);


localparam MUL_DW       = $clog2(DI);
localparam MUL_DW_1_8th = $clog2(SI);

logic [DI-1:0] i_dat;
logic [SI-1:0] i_stb;
logic [A-1:0]  i_adr;

logic [DO-1:0] o_dat;
logic [SO-1:0] o_stb;

assign i_dat = pld_s [DI-1 : 0];
assign i_stb = pld_s [DI  +: SI];
assign i_adr = pld_s [PI - ($clog2(N) + $clog2(M)) - 1 -: A];

assign pld_m = {pld_s [PI-1 : DI + SI], o_stb, o_dat};

/* verilator lint_off WIDTH */
generate
  if (DI < DO) begin: upsizer
    always @(*) begin
    	o_stb = {(SO){1'b0}};
    	o_dat = {(DO){1'b0}};
    	o_stb [(i_adr [HIDX:LIDX] << MUL_DW_1_8th) +: (SI)] = i_stb;
    	o_dat [(i_adr [HIDX:LIDX] << MUL_DW) +: DI] = i_dat;
    end
  end else if (DI > DO) begin: downsizer
    assign o_dat = i_dat [(i_adr [HIDX:LIDX] << MUL_DW) +: DI];
    assign o_stb = i_stb [(DO + (i_adr [HIDX:LIDX] << MUL_DW_1_8th)) +: (SI)];
  end else begin: keepsizer
    assign o_dat = i_dat;
    assign o_stb = i_stb;
  end
endgenerate
/* verilator lint_on WIDTH */

endmodule
// EOF
