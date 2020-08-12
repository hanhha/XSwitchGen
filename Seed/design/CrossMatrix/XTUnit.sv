// HMTH (c)

// Read/Write Target Unit
module XTUnit #(parameter AW = 19, DW = 32, SAW = 32, SDW = 32, OUTSTANDING_NUM = 2, ID = 0, IDW = 3) (
    input logic clk
  , input logic rstn

  , input  logic                                           tpkt_vld
  , input  logic [(IDW*2 + SAW + 1 + (SDW/8) + SDW)-1:0]   tpkt_dat // {INITID, TGTID, LOAD = (S_ADR, WE, S_STRB, S_DATA) }
  , output logic                                           tpkt_gnt

  , output logic              req_vld
  , input  logic              req_gnt
	, output logic              req_wr
  , output logic [AW-1:0]     req_adr
	, output logic [(DW/8)-1:0] req_strb
  , output logic [DW-1:0]     req_dat

  , input  logic              rsp_vld
  , output logic              rsp_gnt
  , input  logic [DW-1:0]     rsp_dat

  , output logic                     rpkt_vld
  , input  logic                     rpkt_gnt
  , output logic [(IDW*2 + SDW)-1:0] rpkt_dat // {TGTID, INITID, LOAD = (S_DATA) }
);

localparam SSTRB   = SDW / 8;
localparam REQ_VDW = AW + DW + IDW + 1 + DW/8;
localparam WAW     = DW > SDW ? $clog2(DW/8) : $clog2(SDW/8);
localparam RSP_VDW = IDW*2 + SDW;

logic [WAW + IDW - 1 : 0] req_tag, tag;

logic [REQ_VDW-1:0] req_pkt, tmp_req_attr;

logic [DW-1:0]      tmp_req_dat;
logic [(DW/8)-1:0]  tmp_req_strb;

logic [AW-1:0]      tmp_req_adr;
logic               tmp_req_wr;

logic [RSP_VDW-1:0] tmp_rpkt_dat;

assign tmp_req_adr  = tpkt_dat [(SDW + SSTRB + 1) +: AW];
assign tmp_req_wr   = tpkt_dat [SDW + SSTRB];

generate
  if (DW != SDW) begin: sizer
    XSizer #(.AW(AW), .DWI(SDW), .DWO(DW))
      ReqSizer (.req_adr_i (tmp_req_adr), .req_dat_i (tpkt [SDW-1:0]), .req_strb_i (tpkt_dat [SDW + SSTRB - 1 : SDW]),
                .req_adr_o (),            .req_dat_o (tmp_req_dat),    .req_strb_o (tmp_req_strb));

    assign req_tag = {tmp_req_attr [(REQ_VDW-1) -: IDW], tmp_req_attr [(1 + (DW/8) + DW) +: WAW]};

    XSizer #(.AW(WAW), .DWI(DW), .DWO(SDW))
      RspSizer (.req_adr_i (tag [WAW-1:0]), .req_dat_i (rsp_dat),                .req_strb_i ({(DW/8){1'b0}}),
                .req_adr_o (),              .req_dat_o (tmp_rpkt_dat [SDW-1:0]), .req_strb_o ());
    assign tmp_rpkt_dat [RSP_VDW-1:SDW] = {ID [IDW-1:0], tag[WAW +: IDW]};

  end else: same_size
    assign tmp_req_dat  = tpkt_dat [SDW-1:0];
    assign tmp_req_strb = tpkt_dat [SDW + SSTRB - 1 : SDW];

    assign req_tag = tmp_req_attr [(REQ_VDW-1) -: IDW];

    assign tmp_rpkt_dat = {ID [IDW-1:0], init_id, rsp_dat};
  end
endgenerate

assign req_pkt = {tpkt_dat[(VDW-1) -: IDW], tmp_req_adr, tmp_req_wr, tmp_req_strb, tmp_req_dat};

XFifo #(.DW(REQ_VDW), .DEPTH(OUTSTANDING_NUM))
  ReqBuff (.clk (clk), .rstn (rstn),
        .din    (req_pkt),      .we (tpkt_vld),
        .dout   (tmp_req_attr), .re (req_gnt),
        .full_n (tpkt_gnt),     .empty_n (req_vld)
);

assign {req_adr, req_wr, req_strb, req_dat} = tmp_req_attr [DW + (DW/8) + 1 + AW - 1 : 0];

XFifo #(.DW(WAW + IDW), .DEPTH(OUTSTANDING_NUM))
  TagBuff (.clk (clk), .rstn (rstn),
           .din    (req_tag), .we (req_vld & req_gnt),
           .dout   (tag),     .re (rsp_vld & rpkt_gnt),
           .full_n (), .empty_n ()
);

XRegSlice #(.D_WIDTH (FB_VDW))
	RspHndSk (.clk (clk), .rstn (rstn),
					  .vldi (rsp_vld),  .rdyi (rsp_gnt),
						.vldo (rpkt_vld), .rdyo (rpkt_gnt),
						.datai (tmp_rpkt_dat),
						.datao (rpkt_dat)
);

endmodule
