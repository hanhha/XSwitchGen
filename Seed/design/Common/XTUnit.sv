// HMTH (c)

// Read/Write Target Unit
// Payload has DST_ID (=LU_N) + SRC_ID + AccessType + ADDR + VC + ... + WrapType + Strb + real Data
// Response payload has SRC_ID + DST_ID + VC + ... + read Data

module XTUnit #(parameter N = 2, M = 3, A = 19, TP = 50, RP = 31, D = 32, DA = 32, VCN = 2, BUF = 4, ID = 0) (
    input logic clk
  , input logic rstn

  , input  logic          t_vld
  , input  logic [TP-1:0] t_pld
  , output logic          t_gnt

  , output logic                              req_vld
  , input  logic                              req_gnt
  , output logic [$clog2(VCN)-1:0]            req_vc
	, output logic                              req_wr
  , output logic [DA-1:0]                     req_adr
	, output logic [(D/8)-1:0]                  req_stb
  , output logic [D-1:0]                      req_dat
  , output logic [(TP-N-M-A-D-(D/8)-1-1)-1:0] req_sb

  , input  logic                   rsp_vld
  , output logic                   rsp_gnt
  , input  logic [$clog2(VCN)-1:0] rsp_vc
  , input  logic [DD-1:0]          rsp_dat
  , input  logic [(RP-N-M-D)-1:0]  rsp_sb

  , output logic                  r_vld
  , input  logic                  r_gnt
  , output logic [RP-1:0]         r_pld
);


XRs #(.D_WIDTH (FB_VDW))
	RspHndSk (.clk (clk), .rstn (rstn),
					  .vldi (rsp_vld),  .rdyi (rsp_gnt),
						.vldo (rpkt_vld), .rdyo (rpkt_gnt),
						.datai (tmp_rpkt_dat),
						.datao (rpkt_dat)
);

`ifndef SYNTHESIS
  `ifndef RICHMAN
		/* verilator lint_off WIDTH */
    always_ff @(posedge clk)  begin: assume_id 
      if (rstn) begin
        if (t_vld) assume (t_pld [TP-1 -: M] == ID [M-1:0]);
      end
    end
		/* verilator lint_on WIDTH */
  `else
  `endif
`endif

endmodule
