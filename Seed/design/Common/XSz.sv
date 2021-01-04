// HMTH (c)

// Non bufferred, bytelane based Upsizer/Downsizer for data
module XSz #(parameter AW = 19, DWI = 32, DWO = 64) (
    input  logic [AW-1:0]      req_adr_s
  , input  logic [DWI-1:0]     req_dat_s
	, input  logic [(DWI/8)-1:0] req_strb_s

  , output logic [AW-1:0]      req_adr_m
  , output logic [DWO-1:0]     req_dat_m
	, output logic [(DWO/8)-1:0] req_strb_m
);

localparam HIDX = $clog2 (DWO / 8) - 1;
localparam LIDX = $clog2 (DWI / 8);

localparam STRBO  = DWO / 8;

localparam MUL_DW       = $clog2(DWI);
localparam MUL_DW_1_8th = $clog2(DWI/8);

/* verilator lint_off WIDTH */
generate
  if (DWI < DWO) begin: upsizer
    always @(*) begin
    	req_strb_m = {(STRBO){1'b0}};
    	req_dat_m  = {(DWO){1'b0}};
    	req_strb_m [(req_adr_s [HIDX:LIDX] << MUL_DW_1_8th) +: (DWI/8)] = req_strb_s;
    	req_dat_m  [(req_adr_s [HIDX:LIDX] << MUL_DW) +: DWI] = req_dat_s;
    end
  end else if (DWI > DWO) begin: downsizer
    assign req_dat_m  = req_dat_s  [(req_adr_s [HIDX:LIDX] << MUL_DW) +: DWI];
    assign req_strb_m = req_strb_s [(DWO + (req_adr_s [HIDX:LIDX] << MUL_DW_1_8th)) +: (DWI/8)];
  end else begin: keepsizer
    assign req_dat_m  = req_dat_s;
    assign req_strb_m = req_strb_s;
  end
endgenerate
/* verilator lint_on WIDTH */

assign req_adr_m = req_adr_s;

endmodule
// EOF
