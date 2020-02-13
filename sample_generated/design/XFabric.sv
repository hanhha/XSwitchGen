// HMTH (c)

module XFabric (
    input logic clk
  , input logic rstn
  , input  logic           CPUm_req_vld
  , input  logic           CPUm_req_wr
  , input  logic [23:0] CPUm_req_adr
  , input  logic [3:0] CPUm_req_strb
  , input  logic [31:0] CPUm_req_dat
  , output logic           CPUm_req_gnt
  , output logic           CPUm_rsp_vld
  , output logic [31:0] CPUm_rsp_dat
  , input  logic           CPUm_rsp_gnt
  , input  logic           SCRm_req_vld
  , input  logic           SCRm_req_wr
  , input  logic [23:0] SCRm_req_adr
  , input  logic [3:0] SCRm_req_strb
  , input  logic [31:0] SCRm_req_dat
  , output logic           SCRm_req_gnt
  , output logic           SCRm_rsp_vld
  , output logic [31:0] SCRm_rsp_dat
  , input  logic           SCRm_rsp_gnt
  , input  logic           BRUm_req_vld
  , input  logic           BRUm_req_wr
  , input  logic [23:0] BRUm_req_adr
  , input  logic [1:0] BRUm_req_strb
  , input  logic [15:0] BRUm_req_dat
  , output logic           BRUm_req_gnt
  , output logic           BRUm_rsp_vld
  , output logic [15:0] BRUm_rsp_dat
  , input  logic           BRUm_rsp_gnt

  , output logic           CPUs_req_vld
  , output logic           CPUs_req_wr
  , output logic [15:0] CPUs_req_adr
  , output logic [1:0] CPUs_req_strb
  , output logic [15:0] CPUs_req_dat
  , input  logic      CPUs_req_gnt
  , input  logic      CPUs_rsp_vld
  , input  logic [15:0] CPUs_rsp_dat
  , output logic           CPUs_rsp_gnt
  , output logic           SCRs_req_vld
  , output logic           SCRs_req_wr
  , output logic [15:0] SCRs_req_adr
  , output logic [1:0] SCRs_req_strb
  , output logic [15:0] SCRs_req_dat
  , input  logic      SCRs_req_gnt
  , input  logic      SCRs_rsp_vld
  , input  logic [15:0] SCRs_rsp_dat
  , output logic           SCRs_rsp_gnt
  , output logic           KBDs_req_vld
  , output logic           KBDs_req_wr
  , output logic [15:0] KBDs_req_adr
  , output logic [0:0] KBDs_req_strb
  , output logic [7:0] KBDs_req_dat
  , input  logic      KBDs_req_gnt
  , input  logic      KBDs_rsp_vld
  , input  logic [7:0] KBDs_rsp_dat
  , output logic           KBDs_rsp_gnt
  , output logic           RAMs_req_vld
  , output logic           RAMs_req_wr
  , output logic [20:0] RAMs_req_adr
  , output logic [3:0] RAMs_req_strb
  , output logic [31:0] RAMs_req_dat
  , input  logic      RAMs_req_gnt
  , input  logic      RAMs_rsp_vld
  , input  logic [31:0] RAMs_rsp_dat
  , output logic           RAMs_rsp_gnt
  , output logic           ROMs_req_vld
  , output logic           ROMs_req_wr
  , output logic [14:0] ROMs_req_adr
  , output logic [1:0] ROMs_req_strb
  , output logic [15:0] ROMs_req_dat
  , input  logic      ROMs_req_gnt
  , input  logic      ROMs_rsp_vld
  , input  logic [15:0] ROMs_rsp_dat
  , output logic           ROMs_rsp_gnt
);

logic           CPUm_tpkt_vld;
logic [65:0] CPUm_tpkt_pld;
logic           CPUm_tpkt_gnt;
logic           CPUm_rpkt_vld;
logic [36:0] CPUm_rpkt_pld;
logic           CPUm_rpkt_gnt;
logic           SCRm_tpkt_vld;
logic [65:0] SCRm_tpkt_pld;
logic           SCRm_tpkt_gnt;
logic           SCRm_rpkt_vld;
logic [36:0] SCRm_rpkt_pld;
logic           SCRm_rpkt_gnt;
logic           BRUm_tpkt_vld;
logic [65:0] BRUm_tpkt_pld;
logic           BRUm_tpkt_gnt;
logic           BRUm_rpkt_vld;
logic [36:0] BRUm_rpkt_pld;
logic           BRUm_rpkt_gnt;

logic           CPUs_tpkt_vld;
logic [65:0] CPUs_tpkt_pld;
logic           CPUs_tpkt_gnt;
logic           CPUs_rpkt_vld;
logic [36:0] CPUs_rpkt_pld;
logic           CPUs_rpkt_gnt;
logic           SCRs_tpkt_vld;
logic [65:0] SCRs_tpkt_pld;
logic           SCRs_tpkt_gnt;
logic           SCRs_rpkt_vld;
logic [36:0] SCRs_rpkt_pld;
logic           SCRs_rpkt_gnt;
logic           KBDs_tpkt_vld;
logic [65:0] KBDs_tpkt_pld;
logic           KBDs_tpkt_gnt;
logic           KBDs_rpkt_vld;
logic [36:0] KBDs_rpkt_pld;
logic           KBDs_rpkt_gnt;
logic           RAMs_tpkt_vld;
logic [65:0] RAMs_tpkt_pld;
logic           RAMs_tpkt_gnt;
logic           RAMs_rpkt_vld;
logic [36:0] RAMs_rpkt_pld;
logic           RAMs_rpkt_gnt;
logic           ROMs_tpkt_vld;
logic [65:0] ROMs_tpkt_pld;
logic           ROMs_tpkt_gnt;
logic           ROMs_rpkt_vld;
logic [36:0] ROMs_rpkt_pld;
logic           ROMs_rpkt_gnt;

XSwitch Switch ( .clk (clk), .rstn (rstn)
		  , .CPUm_req_vld (CPUm_tpkt_vld)
 		  , .CPUm_req_pkt (CPUm_tpkt_pld)
 		  , .CPUm_req_gnt (CPUm_tpkt_gnt)
 		  , .CPUm_rsp_vld (CPUm_rpkt_vld)
 		  , .CPUm_rsp_pkt (CPUm_rpkt_pld)
 		  , .CPUm_rsp_gnt (CPUm_rpkt_gnt)
		  , .SCRm_req_vld (SCRm_tpkt_vld)
 		  , .SCRm_req_pkt (SCRm_tpkt_pld)
 		  , .SCRm_req_gnt (SCRm_tpkt_gnt)
 		  , .SCRm_rsp_vld (SCRm_rpkt_vld)
 		  , .SCRm_rsp_pkt (SCRm_rpkt_pld)
 		  , .SCRm_rsp_gnt (SCRm_rpkt_gnt)
		  , .BRUm_req_vld (BRUm_tpkt_vld)
 		  , .BRUm_req_pkt (BRUm_tpkt_pld)
 		  , .BRUm_req_gnt (BRUm_tpkt_gnt)
 		  , .BRUm_rsp_vld (BRUm_rpkt_vld)
 		  , .BRUm_rsp_pkt (BRUm_rpkt_pld)
 		  , .BRUm_rsp_gnt (BRUm_rpkt_gnt)

		  , .CPUs_req_vld (CPUs_tpkt_vld)
 		  , .CPUs_req_pkt (CPUs_tpkt_pld)
 		  , .CPUs_req_gnt (CPUs_tpkt_gnt)
 		  , .CPUs_rsp_vld (CPUs_rpkt_vld)
 		  , .CPUs_rsp_pkt (CPUs_rpkt_pld)
 		  , .CPUs_rsp_gnt (CPUs_rpkt_gnt)
		  , .SCRs_req_vld (SCRs_tpkt_vld)
 		  , .SCRs_req_pkt (SCRs_tpkt_pld)
 		  , .SCRs_req_gnt (SCRs_tpkt_gnt)
 		  , .SCRs_rsp_vld (SCRs_rpkt_vld)
 		  , .SCRs_rsp_pkt (SCRs_rpkt_pld)
 		  , .SCRs_rsp_gnt (SCRs_rpkt_gnt)
		  , .KBDs_req_vld (KBDs_tpkt_vld)
 		  , .KBDs_req_pkt (KBDs_tpkt_pld)
 		  , .KBDs_req_gnt (KBDs_tpkt_gnt)
 		  , .KBDs_rsp_vld (KBDs_rpkt_vld)
 		  , .KBDs_rsp_pkt (KBDs_rpkt_pld)
 		  , .KBDs_rsp_gnt (KBDs_rpkt_gnt)
		  , .RAMs_req_vld (RAMs_tpkt_vld)
 		  , .RAMs_req_pkt (RAMs_tpkt_pld)
 		  , .RAMs_req_gnt (RAMs_tpkt_gnt)
 		  , .RAMs_rsp_vld (RAMs_rpkt_vld)
 		  , .RAMs_rsp_pkt (RAMs_rpkt_pld)
 		  , .RAMs_rsp_gnt (RAMs_rpkt_gnt)
		  , .ROMs_req_vld (ROMs_tpkt_vld)
 		  , .ROMs_req_pkt (ROMs_tpkt_pld)
 		  , .ROMs_req_gnt (ROMs_tpkt_gnt)
 		  , .ROMs_rsp_vld (ROMs_rpkt_vld)
 		  , .ROMs_rsp_pkt (ROMs_rpkt_pld)
 		  , .ROMs_rsp_gnt (ROMs_rpkt_gnt)
);

XMstRWTrans #(.AW(24), .VDW(66), .OUTSTANDING_NUM(4),
													 .ID(0), .SYS_AW (24), .SYS_DW(32))
		CPUm_trans ( .clk (clk), .rstn (rstn)
					, .req_vld  (CPUm_req_vld)
					, .req_gnt  (CPUm_req_gnt)
					, .req_wr   (CPUm_req_wr)
					, .req_strb (CPUm_req_strb)
					, .req_adr  (CPUm_req_adr)
					, .req_dat  (CPUm_req_dat)

					, .tpkt_vld (CPUm_tpkt_vld)
					, .tpkt_dat (CPUm_tpkt_pld)
					, .tpkt_gnt (CPUm_tpkt_gnt)

					, .rpkt_vld (CPUm_rpkt_vld)
					, .rpkt_gnt (CPUm_rpkt_gnt)
					, .rpkt_dat (CPUm_rpkt_pld)

					, .rsp_vld (CPUm_rsp_vld)
					, .rsp_gnt (CPUm_rsp_gnt)
					, .rsp_dat (CPUm_rsp_dat)
				);
XMstRWTrans #(.AW(24), .VDW(66), .OUTSTANDING_NUM(4),
													 .ID(1), .SYS_AW (24), .SYS_DW(32))
		SCRm_trans ( .clk (clk), .rstn (rstn)
					, .req_vld  (SCRm_req_vld)
					, .req_gnt  (SCRm_req_gnt)
					, .req_wr   (SCRm_req_wr)
					, .req_strb (SCRm_req_strb)
					, .req_adr  (SCRm_req_adr)
					, .req_dat  (SCRm_req_dat)

					, .tpkt_vld (SCRm_tpkt_vld)
					, .tpkt_dat (SCRm_tpkt_pld)
					, .tpkt_gnt (SCRm_tpkt_gnt)

					, .rpkt_vld (SCRm_rpkt_vld)
					, .rpkt_gnt (SCRm_rpkt_gnt)
					, .rpkt_dat (SCRm_rpkt_pld)

					, .rsp_vld (SCRm_rsp_vld)
					, .rsp_gnt (SCRm_rsp_gnt)
					, .rsp_dat (SCRm_rsp_dat)
				);
XMstRWSTrans #(.AW(24), .DW(16), .VDW(66), .OUTSTANDING_NUM(4),
													 .ID(2), .SYS_AW (24), .SYS_DW(32))
		BRUm_trans ( .clk (clk), .rstn (rstn)
					, .req_vld  (BRUm_req_vld)
					, .req_gnt  (BRUm_req_gnt)
					, .req_wr   (BRUm_req_wr)
					, .req_strb (BRUm_req_strb)
					, .req_adr  (BRUm_req_adr)
					, .req_dat  (BRUm_req_dat)

					, .tpkt_vld (BRUm_tpkt_vld)
					, .tpkt_dat (BRUm_tpkt_pld)
					, .tpkt_gnt (BRUm_tpkt_gnt)

					, .rpkt_vld (BRUm_rpkt_vld)
					, .rpkt_gnt (BRUm_rpkt_gnt)
					, .rpkt_dat (BRUm_rpkt_pld)

					, .rsp_vld (BRUm_rsp_vld)
					, .rsp_gnt (BRUm_rsp_gnt)
					, .rsp_dat (BRUm_rsp_dat)
				);

XSlvRWSTrans #(.AW(16), .DW(16), .VDW(66), .OUTSTANDING_NUM(2),
													 .ID(0), .SYS_AW (24), .SYS_DW(32))
		CPUs_trans ( .clk (clk), .rstn (rstn)
					, .tpkt_vld (CPUs_tpkt_vld)
					, .tpkt_dat (CPUs_tpkt_pld)
					, .tpkt_gnt (CPUs_tpkt_gnt)

					, .req_vld  (CPUs_req_vld)
					, .req_gnt  (CPUs_req_gnt)
					, .req_adr  (CPUs_req_adr)
					, .req_wr   (CPUs_req_wr)
					, .req_strb (CPUs_req_strb)
					, .req_dat  (CPUs_req_dat)

					, .rsp_vld (CPUs_rsp_vld)
					, .rsp_gnt (CPUs_rsp_gnt)
					, .rsp_dat (CPUs_rsp_dat)

					, .rpkt_vld (CPUs_rpkt_vld)
					, .rpkt_gnt (CPUs_rpkt_gnt)
					, .rpkt_dat (CPUs_rpkt_pld)
				);
XSlvRWSTrans #(.AW(16), .DW(16), .VDW(66), .OUTSTANDING_NUM(2),
													 .ID(1), .SYS_AW (24), .SYS_DW(32))
		SCRs_trans ( .clk (clk), .rstn (rstn)
					, .tpkt_vld (SCRs_tpkt_vld)
					, .tpkt_dat (SCRs_tpkt_pld)
					, .tpkt_gnt (SCRs_tpkt_gnt)

					, .req_vld  (SCRs_req_vld)
					, .req_gnt  (SCRs_req_gnt)
					, .req_adr  (SCRs_req_adr)
					, .req_wr   (SCRs_req_wr)
					, .req_strb (SCRs_req_strb)
					, .req_dat  (SCRs_req_dat)

					, .rsp_vld (SCRs_rsp_vld)
					, .rsp_gnt (SCRs_rsp_gnt)
					, .rsp_dat (SCRs_rsp_dat)

					, .rpkt_vld (SCRs_rpkt_vld)
					, .rpkt_gnt (SCRs_rpkt_gnt)
					, .rpkt_dat (SCRs_rpkt_pld)
				);
XSlvRWSTrans #(.AW(16), .DW(8), .VDW(66), .OUTSTANDING_NUM(2),
													 .ID(2), .SYS_AW (24), .SYS_DW(32))
		KBDs_trans ( .clk (clk), .rstn (rstn)
					, .tpkt_vld (KBDs_tpkt_vld)
					, .tpkt_dat (KBDs_tpkt_pld)
					, .tpkt_gnt (KBDs_tpkt_gnt)

					, .req_vld  (KBDs_req_vld)
					, .req_gnt  (KBDs_req_gnt)
					, .req_adr  (KBDs_req_adr)
					, .req_wr   (KBDs_req_wr)
					, .req_strb (KBDs_req_strb)
					, .req_dat  (KBDs_req_dat)

					, .rsp_vld (KBDs_rsp_vld)
					, .rsp_gnt (KBDs_rsp_gnt)
					, .rsp_dat (KBDs_rsp_dat)

					, .rpkt_vld (KBDs_rpkt_vld)
					, .rpkt_gnt (KBDs_rpkt_gnt)
					, .rpkt_dat (KBDs_rpkt_pld)
				);
XSlvRWTrans #(.AW(21), .VDW(66), .OUTSTANDING_NUM(2),
													 .ID(3), .SYS_AW (24), .SYS_DW(32))
		RAMs_trans ( .clk (clk), .rstn (rstn)
					, .tpkt_vld (RAMs_tpkt_vld)
					, .tpkt_dat (RAMs_tpkt_pld)
					, .tpkt_gnt (RAMs_tpkt_gnt)

					, .req_vld  (RAMs_req_vld)
					, .req_gnt  (RAMs_req_gnt)
					, .req_adr  (RAMs_req_adr)
					, .req_wr   (RAMs_req_wr)
					, .req_strb (RAMs_req_strb)
					, .req_dat  (RAMs_req_dat)

					, .rsp_vld (RAMs_rsp_vld)
					, .rsp_gnt (RAMs_rsp_gnt)
					, .rsp_dat (RAMs_rsp_dat)

					, .rpkt_vld (RAMs_rpkt_vld)
					, .rpkt_gnt (RAMs_rpkt_gnt)
					, .rpkt_dat (RAMs_rpkt_pld)
				);
XSlvRWSTrans #(.AW(15), .DW(16), .VDW(66), .OUTSTANDING_NUM(2),
													 .ID(4), .SYS_AW (24), .SYS_DW(32))
		ROMs_trans ( .clk (clk), .rstn (rstn)
					, .tpkt_vld (ROMs_tpkt_vld)
					, .tpkt_dat (ROMs_tpkt_pld)
					, .tpkt_gnt (ROMs_tpkt_gnt)

					, .req_vld  (ROMs_req_vld)
					, .req_gnt  (ROMs_req_gnt)
					, .req_adr  (ROMs_req_adr)
					, .req_wr   (ROMs_req_wr)
					, .req_strb (ROMs_req_strb)
					, .req_dat  (ROMs_req_dat)

					, .rsp_vld (ROMs_rsp_vld)
					, .rsp_gnt (ROMs_rsp_gnt)
					, .rsp_dat (ROMs_rsp_dat)

					, .rpkt_vld (ROMs_rpkt_vld)
					, .rpkt_gnt (ROMs_rpkt_gnt)
					, .rpkt_dat (ROMs_rpkt_pld)
				);

endmodule
// EOF
