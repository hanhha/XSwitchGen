// HMTH (c)

// Non bufferred, bytelane based Upsizer/Downsizer for data
module XSz #(parameter A = 19, DI = 32, DO = 64, PI = 40, PO = 72) (
    input  logic [AW-1:0] adr_s
  , input  logic [PI-1:0] pld_s

  , output logic [AW-1:0] adr_m
  , output logic [PO-1:0] pld_m
);

localparam HIDX = $clog2 (DO / 8) - 1;
localparam LIDX = $clog2 (DI / 8);

localparam SO  = DO / 8;

localparam MUL_DW       = $clog2(DI);
localparam MUL_DW_1_8th = $clog2(DI/8);

logic [DI-1:0] i_dat_m;

/* verilator lint_off WIDTH */
generate
  if (DI < DO) begin: upsizer
    always @(*) begin
    	strb_m = {(SO){1'b0}};
    	dat_m  = {(DO){1'b0}};
    	strb_m [(adr_s [HIDX:LIDX] << MUL_DW_1_8th) +: (DI/8)] = strb_s;
    	dat_m  [(adr_s [HIDX:LIDX] << MUL_DW) +: DI] = dat_s;
    end
  end else if (DI > DO) begin: downsizer
    assign dat_m  = dat_s  [(adr_s [HIDX:LIDX] << MUL_DW) +: DI];
    assign strb_m = strb_s [(DWO + (adr_s [HIDX:LIDX] << MUL_DW_1_8th)) +: (DI/8)];
  end else begin: keepsizer
    assign dat_m  = dat_s;
    assign strb_m = strb_s;
  end
endgenerate
/* verilator lint_on WIDTH */

assign adr_m = adr_s;
assign sb_m  = sb_s;

endmodule
// EOF
