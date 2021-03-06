// HMTH (c)

// Read-Writable Master with different bus width than system data bus
module XMstRWSTrans #(parameter AW = 19, DW = 8, VDW = 74, OUTSTANDING_NUM = 2, ID = 0, SYS_AW = 32, SYS_DW = 32) (
    input logic clk
  , input logic rstn

  , input  logic              req_vld
  , output logic              req_gnt
  , input  logic [AW-1:0]     req_adr
  , input  logic [DW-1:0]     req_dat
	, input  logic              req_wr
	, input  logic [(DW/8)-1:0] req_strb

  , output logic           tpkt_vld
  , output logic [VDW-1:0] tpkt_dat // {INITID, TGTID, LOAD = (S_ADR, WE, S_STRB, S_DATA) }
  , input  logic           tpkt_gnt

  , input  logic                               rpkt_vld
  , output logic                               rpkt_gnt
  , input  logic [VDW-SYS_AW-(SYS_DW/8)-1-1:0] rpkt_dat // {TGTID, INITID, LOAD = (S_DATA) }

  , output logic           rsp_vld
  , input  logic           rsp_gnt
  , output logic [DW-1:0]  rsp_dat
);

logic [2:0] tgtid;

logic T0_hit, T1_hit, T2_hit, T3_hit, T4_hit;

/* verilator lint_off WIDTH */
assign T0_hit = (req_adr & 24'hE0_0000) == 24'h20_0000 ? 1'b1 : 1'b0;
assign T1_hit = (req_adr & 24'hE0_0000) == 24'h40_0000 ? 1'b1 : 1'b0;
assign T2_hit = (req_adr & 24'hE0_0000) == 24'h60_0000 ? 1'b1 : 1'b0;
assign T3_hit = (req_adr & 24'hE0_0000) == 24'h00_0000 ? 1'b1 : 1'b0;
assign T4_hit = (req_adr & 24'hE0_0000) == 24'h80_0000 ? 1'b1 : 1'b0;
/* verilator lint_on WIDTH */

assign tgtid = {3{T0_hit}} & 3'd0 | {3{T1_hit}} & 3'd1 | {3{T2_hit}} & 3'd2 | {3{T3_hit}} & 3'd3 | {3{T4_hit}} & 3'd4;

localparam HIDX = $clog2 (SYS_DW / 8) - 1;
localparam LIDX = $clog2 (DW / 8);

localparam SYS_STRB  = SYS_DW / 8;
localparam LOC_VDW   = AW + SYS_DW + SYS_STRB + 1 + 3;

localparam FB_VDW = VDW - SYS_AW - SYS_STRB - 1;

localparam MUL_DW       = $clog2(DW);
localparam MUL_DW_1_8th = $clog2(DW/8);

logic [LOC_VDW-1:0]  req_pkt, tmp_tpkt_dat;
logic [SYS_DW-1:0]   aligned_req_dat;
logic [SYS_STRB-1:0] aligned_req_strb;

/* verilator lint_off WIDTH */
always @(*) begin
	aligned_req_strb = {(SYS_STRB){1'b0}};
	aligned_req_dat  = {(SYS_DW){1'b0}};
	aligned_req_strb [(req_adr [HIDX:LIDX] << MUL_DW_1_8th) +: (DW/8)] = req_strb; 
	aligned_req_dat  [(req_adr [HIDX:LIDX] << MUL_DW) +: DW] = req_dat; 
end
/* verilator lint_on WIDTH */

assign req_pkt = {tgtid, req_adr, req_wr, aligned_req_strb, aligned_req_dat};

logic [HIDX - LIDX : 0] rpkt_dat_idx;
logic wait_rsp;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
	if (rstn == 1'b0) begin
		wait_rsp <= 1'b0;
	end else begin
		if (tpkt_vld & tpkt_gnt) begin
			wait_rsp <= 1'b1;
			rpkt_dat_idx <= tpkt_dat [(SYS_DW + SYS_STRB + 1 + LIDX) +: (HIDX - LIDX + 1)];
		end else if (rsp_vld & rsp_gnt)
			wait_rsp <= 1'b0;
		else
			wait_rsp <= wait_rsp;
	end
end

logic tmp_tpkt_vld, tmp_tpkt_gnt;

assign tmp_tpkt_gnt = tpkt_gnt & ~wait_rsp;
assign tpkt_vld     = tmp_tpkt_vld & ~wait_rsp;

XFifo #(.DW(LOC_VDW), .DEPTH(OUTSTANDING_NUM))
  ReqBuff (.clk (clk), .rstn (rstn),
        .din    (req_pkt),      .we      (req_vld),
        .dout   (tmp_tpkt_dat), .re      (tmp_tpkt_gnt),
        .full_n (req_gnt),      .empty_n (tmp_tpkt_vld)
);

assign tpkt_dat = {ID[1:0], tmp_tpkt_dat [(LOC_VDW-1) -: 3], {(SYS_AW-AW){1'b0}}, tmp_tpkt_dat [SYS_DW + SYS_STRB + 1 + AW - 1 : 0]};

XHndSk #(.D_WIDTH (DW))
	RspHndSk (.clk (clk), .rstn (rstn),
					  .vldi  (rpkt_vld), .rdyi (rpkt_gnt),
						.vldo  (rsp_vld),  .rdyo (rsp_gnt),
						/* verilator lint_off WIDTH */
						.datai (rpkt_dat [(rpkt_dat_idx << MUL_DW) +: DW]),
						/* verilator lint_on WIDTH */
						.datao (rsp_dat)
);

`ifndef SYNTHESIS
// Validating address 
  `ifndef RICHMAN
		always @(posedge clk) begin
			if (rstn)
				if (req_vld) assume (T0_hit + T1_hit + T2_hit + T3_hit + T4_hit == 1);
		end
  `else
    asm_ADR_VLD: assume property (@(posedge clk) disable iff (~rstn) (req_vld |-> $onehot({T0_hit, T1_hit, T2_hit, T3_hit, T4_hit})));
  `endif
`endif

endmodule

// Read-Writable Slave with different bus width than system data bus
module XSlvRWSTrans #(parameter AW = 19, DW = 8, VDW = 74, SYS_AW = 32, SYS_DW = 32, OUTSTANDING_NUM = 2, ID = 0) (
    input logic clk
  , input logic rstn

  , input  logic           tpkt_vld
  , input  logic [VDW-1:0] tpkt_dat // {INITID, TGTID, LOAD = (S_ADR, WE, S_STRB, S_DATA) }
  , output logic           tpkt_gnt

  , output logic              req_vld
  , input  logic              req_gnt
	, output logic              req_wr
  , output logic [AW-1:0]     req_adr
	, output logic [(DW/8)-1:0] req_strb
  , output logic [DW-1:0]     req_dat

  , input  logic           rsp_vld
  , output logic           rsp_gnt
  , input  logic [DW-1:0]  rsp_dat

  , output logic                               rpkt_vld
  , input  logic                               rpkt_gnt
  , output logic [VDW-SYS_AW-(SYS_DW/8)-1-1:0] rpkt_dat // {TGTID, INITID, LOAD = (S_DATA) }
);

localparam SYS_STRB  = SYS_DW / 8;

`ifndef SYNTHESIS
// Validating input
	`ifndef RICHMAN
		logic [SYS_STRB-1:0] s_strb;
		/* verilator lint_off WIDTH */
		always @(posedge clk) begin
			if (rstn)
				if (tpkt_vld) begin
					s_strb = tpkt_dat [SYS_DW +: SYS_STRB];
					assume (s_strb [0] + s_strb [1] + s_strb [2] + s_strb [3] <= (DW / 8));
				end
		end
		/* verilator lint_on WIDTH */
	`else
		ast_TGT_ENOUGH: assert property (@(posedge clk) disable iff (~rstn) (tpkt_vld |-> $countones(tpkt_dat [SYS_DW +: SYS_STRB]) <= (DW / 8))); 
	`endif
`endif

localparam LOC_VDW = AW + DW + 2 + 1 + DW/8;
localparam FB_VDW = VDW - SYS_AW - SYS_STRB - 1;

localparam HIDX = $clog2 (SYS_DW / 8) - 1;
localparam LIDX = $clog2 (DW / 8);

localparam MUL_DW       = $clog2(DW);
localparam MUL_DW_1_8th = $clog2(DW/8);

logic [LOC_VDW-1:0] req_pkt, tmp_req_attr;
logic [DW-1:0]     tmp_req_dat;
logic [(DW/8)-1:0] tmp_req_strb;
logic [AW-1:0]     tmp_req_adr;
logic              tmp_req_wr;

assign tmp_req_adr  = tpkt_dat [(SYS_DW + SYS_STRB + 1) +: AW];
/* verilator lint_off WIDTH */
assign tmp_req_dat  = tpkt_dat [(tmp_req_adr [HIDX:LIDX] << MUL_DW) +: DW];
assign tmp_req_strb = tpkt_dat [(SYS_DW + (tmp_req_adr [HIDX:LIDX] << MUL_DW_1_8th)) +: (DW/8)];
/* verilator lint_on WIDTH */
assign tmp_req_wr   = tpkt_dat [SYS_DW + SYS_STRB];
assign req_pkt = {tpkt_dat[(VDW-1) -: 2], tmp_req_adr, tmp_req_wr, tmp_req_strb, tmp_req_dat};

XFifo #(.DW(LOC_VDW), .DEPTH(OUTSTANDING_NUM))
  ReqBuff (.clk (clk), .rstn (rstn),
        .din    (req_pkt),     .we      (tpkt_vld),
        .dout   (tmp_req_attr), .re      (req_gnt),
        .full_n (tpkt_gnt),    .empty_n (req_vld)
);

assign {req_adr, req_wr, req_strb, req_dat} = tmp_req_attr [DW + DW/8 + 1 + AW - 1 : 0];

logic [1:0] init_id;

XFifo #(.DW(2), .DEPTH(OUTSTANDING_NUM))
  IdBuff (.clk (clk), .rstn (rstn),
        .din    (tmp_req_attr [(LOC_VDW-1) -: 2]), .we (req_vld & req_gnt),
        .dout   (init_id),                       .re (rsp_vld & rpkt_gnt),
        .full_n (), .empty_n ()
);

logic [HIDX - LIDX : 0] rsp_dat_idx;

XFifo #(.DW(HIDX - LIDX + 1), .DEPTH(OUTSTANDING_NUM))
  AdrBuff (.clk (clk), .rstn (rstn),
        .din    (tmp_req_attr [(DW + DW/8 + 1 + LIDX) +: (HIDX - LIDX + 1)]), .we (req_vld & req_gnt),
        .dout   (rsp_dat_idx),                       .re (rsp_vld & rpkt_gnt),
        .full_n (), .empty_n ()
);

logic [FB_VDW-1:0] tmp_rpkt_dat;
logic [SYS_DW-1:0] rsp_sys_dat;

always @(*) begin
	rsp_sys_dat = {(SYS_DW){1'b0}};
/* verilator lint_off WIDTH */
	rsp_sys_dat [(rsp_dat_idx << MUL_DW) +: DW] = rsp_dat;
/* verilator lint_on WIDTH */
end

assign tmp_rpkt_dat = {ID [2:0], init_id, rsp_sys_dat};

XHndSk #(.D_WIDTH (FB_VDW))
	RspHndSk (.clk (clk), .rstn (rstn),
					  .vldi (rsp_vld),  .rdyi (rsp_gnt),
						.vldo (rpkt_vld), .rdyo (rpkt_gnt),
						.datai (tmp_rpkt_dat),
						.datao (rpkt_dat)
);

endmodule

// Read-Writable Master with bus width as same as system data bus
module XMstRWTrans #(parameter AW = 19, VDW = 74, OUTSTANDING_NUM = 2, ID = 0, SYS_AW = 32, SYS_DW = 32) (
    input logic clk
  , input logic rstn

  , input  logic                  req_vld
  , output logic                  req_gnt
  , input  logic [AW-1:0]         req_adr
  , input  logic [SYS_DW-1:0]     req_dat
	, input  logic                  req_wr
	, input  logic [(SYS_DW/8)-1:0] req_strb

  , output logic           tpkt_vld
  , output logic [VDW-1:0] tpkt_dat // {INITID, TGTID, LOAD = (S_ADR, WE, S_STRB, S_DATA) }
  , input  logic           tpkt_gnt

  , input  logic                               rpkt_vld
  , output logic                               rpkt_gnt
  , input  logic [VDW-SYS_AW-(SYS_DW/8)-1-1:0] rpkt_dat // {TGTID, INITID, LOAD = (S_DATA) }

  , output logic               rsp_vld
  , input  logic               rsp_gnt
  , output logic [SYS_DW-1:0]  rsp_dat
);

logic [2:0] tgtid;

logic T0_hit, T1_hit, T2_hit, T3_hit, T4_hit;

/* verilator lint_off WIDTH */
assign T0_hit = (req_adr & 24'hE0_0000) == 24'h20_0000 ? 1'b1 : 1'b0;
assign T1_hit = (req_adr & 24'hE0_0000) == 24'h40_0000 ? 1'b1 : 1'b0;
assign T2_hit = (req_adr & 24'hE0_0000) == 24'h60_0000 ? 1'b1 : 1'b0;
assign T3_hit = (req_adr & 24'hE0_0000) == 24'h00_0000 ? 1'b1 : 1'b0;
assign T4_hit = (req_adr & 24'hE0_0000) == 24'h80_0000 ? 1'b1 : 1'b0;
/* verilator lint_on WIDTH */

assign tgtid = {3{T0_hit}} & 3'd0 | {3{T1_hit}} & 3'd1 | {3{T2_hit}} & 3'd2 | {3{T3_hit}} & 3'd3 | {3{T4_hit}} & 3'd4;

localparam SYS_STRB  = SYS_DW / 8;
localparam LOC_VDW   = AW + SYS_DW + SYS_STRB + 1 + 3;
localparam FB_VDW = VDW - SYS_AW - SYS_STRB - 1;

logic [LOC_VDW-1:0]  req_pkt, tmp_tpkt_dat;
logic [SYS_DW-1:0]   aligned_req_dat;
logic [SYS_STRB-1:0] aligned_req_strb;

assign aligned_req_strb = req_strb; 
assign aligned_req_dat  = req_dat; 

assign req_pkt = {tgtid, req_adr, req_wr, aligned_req_strb, aligned_req_dat};

logic wait_rsp;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
	if (rstn == 1'b0) begin
		wait_rsp <= 1'b0;
	end else begin
		if (tpkt_vld & tpkt_gnt)
			wait_rsp <= 1'b1;
		else if (rsp_vld & rsp_gnt)
			wait_rsp <= 1'b0;
		else
			wait_rsp <= wait_rsp;
	end
end

logic tmp_tpkt_vld, tmp_tpkt_gnt;

assign tmp_tpkt_gnt = tpkt_gnt & ~wait_rsp;
assign tpkt_vld     = tmp_tpkt_vld & ~wait_rsp;

XFifo #(.DW(LOC_VDW), .DEPTH(OUTSTANDING_NUM))
  ReqBuff (.clk (clk), .rstn (rstn),
        .din    (req_pkt),      .we      (req_vld),
        .dout   (tmp_tpkt_dat), .re      (tmp_tpkt_gnt),
        .full_n (req_gnt),      .empty_n (tmp_tpkt_vld)
);

assign tpkt_dat = {ID[1:0], tmp_tpkt_dat [(LOC_VDW-1) -: 3], {(SYS_AW-AW){1'b0}}, tmp_tpkt_dat [SYS_DW + SYS_STRB + 1 + AW - 1 : 0]};

XHndSk #(.D_WIDTH (SYS_DW))
	RspHndSk (.clk (clk), .rstn (rstn),
					  .vldi  (rpkt_vld), .rdyi (rpkt_gnt),
						.vldo  (rsp_vld),  .rdyo (rsp_gnt),
						.datai (rpkt_dat [SYS_DW-1:0]),
						.datao (rsp_dat)
);

endmodule

// Read-Writable Slave with bus width as same as system data bus
module XSlvRWTrans #(parameter AW = 19, VDW = 74, SYS_AW = 32, SYS_DW = 32, OUTSTANDING_NUM = 2, ID = 0) (
    input logic clk
  , input logic rstn

  , input  logic           tpkt_vld
  , input  logic [VDW-1:0] tpkt_dat // {INITID, TGTID, LOAD = (S_ADR, WE, S_STRB, S_DATA) }
  , output logic           tpkt_gnt

  , output logic                  req_vld
  , input  logic                  req_gnt
	, output logic                  req_wr
  , output logic [AW-1:0]         req_adr
	, output logic [(SYS_DW/8)-1:0] req_strb
  , output logic [SYS_DW-1:0]     req_dat

  , input  logic               rsp_vld
  , output logic               rsp_gnt
  , input  logic [SYS_DW-1:0]  rsp_dat

  , output logic                               rpkt_vld
  , input  logic                               rpkt_gnt
  , output logic [VDW-SYS_AW-(SYS_DW/8)-1-1:0] rpkt_dat // {TGTID, INITID, LOAD = (S_DATA) }
);

localparam SYS_STRB  = SYS_DW / 8;

localparam LOC_VDW = AW + SYS_DW + 2 + 1 + SYS_DW/8;
localparam FB_VDW = VDW - SYS_AW - SYS_STRB - 1;

logic [LOC_VDW-1:0] req_pkt, tmp_req_attr;

logic [SYS_DW-1:0]     tmp_req_dat;
logic [(SYS_DW/8)-1:0] tmp_req_strb;

logic [AW-1:0]     tmp_req_adr;
logic              tmp_req_wr;

assign tmp_req_adr  = tpkt_dat [(SYS_DW + SYS_STRB + 1) +: AW];
assign tmp_req_dat  = tpkt_dat [SYS_DW-1:0];
assign tmp_req_strb = tpkt_dat [SYS_DW + SYS_STRB - 1 : SYS_DW];
assign tmp_req_wr   = tpkt_dat [SYS_DW + SYS_STRB];
assign req_pkt = {tpkt_dat[(VDW-1) -: 2], tmp_req_adr, tmp_req_wr, tmp_req_strb, tmp_req_dat};

XFifo #(.DW(LOC_VDW), .DEPTH(OUTSTANDING_NUM))
  ReqBuff (.clk (clk), .rstn (rstn),
        .din    (req_pkt),     .we      (tpkt_vld),
        .dout   (tmp_req_attr), .re      (req_gnt),
        .full_n (tpkt_gnt),    .empty_n (req_vld)
);

assign {req_adr, req_wr, req_strb, req_dat} = tmp_req_attr [SYS_DW + SYS_STRB + 1 + AW - 1 : 0];

logic [1:0] init_id;

XFifo #(.DW(2), .DEPTH(OUTSTANDING_NUM))
  IdBuff (.clk (clk), .rstn (rstn),
        .din    (tmp_req_attr [(LOC_VDW-1) -: 2]), .we (req_vld & req_gnt),
        .dout   (init_id),                       .re (rsp_vld & rpkt_gnt),
        .full_n (), .empty_n ()
);

logic [FB_VDW-1:0] tmp_rpkt_dat;

assign tmp_rpkt_dat = {ID [2:0], init_id, rsp_dat};

XHndSk #(.D_WIDTH (FB_VDW))
	RspHndSk (.clk (clk), .rstn (rstn),
					  .vldi (rsp_vld),  .rdyi (rsp_gnt),
						.vldo (rpkt_vld), .rdyo (rpkt_gnt),
						.datai (tmp_rpkt_dat),
						.datao (rpkt_dat)
);

endmodule
// EOF
