// HMTH (c)

// Non buffer Upsizer/Downsizer for data
module XSizer #(parameter AW = 19, DWI = 32, DWO = 64) (
  , input  logic [AW-1:0]      req_adr_i
  , input  logic [DWI-1:0]     req_dat_i
	, input  logic [(DWI/8)-1:0] req_strb_i

  , output logic [AW-1:0]      req_adr_o
  , output logic [DWO-1:0]     req_dat_o
	, output logic [(DWO/8)-1:0] req_strb_o
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
    	req_strb_o = {(STRBO){1'b0}};
    	req_dat_o  = {(DWO){1'b0}};
    	req_strb_o [(req_adr_i [HIDX:LIDX] << MUL_DW_1_8th) +: (DWI/8)] = req_strb; 
    	req_dat_o  [(req_adr_i [HIDX:LIDX] << MUL_DW) +: DWI] = req_dat; 
    end
  end if (DWI > DWO) else begin: downsizer
    assign req_dat_o  = req_dat_i  [(req_adr_i [HIDX:LIDX] << MUL_DW) +: DW];
    assign req_strb_o = req_strb_i [(DWO + (req_adr_i [HIDX:LIDX] << MUL_DW_1_8th)) +: (DWI/8)];
  end else begin: keepsizer
    assign req_dat_o  = req_dat_i;
    assign req_strb_o = req_strb_i;
  end
endgenerate
/* verilator lint_on WIDTH */

assign req_adr_o = req_adr_i;

endmodule
// EOF
