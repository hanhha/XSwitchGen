// HMTH (c)	
//TODO: add IO and wires for desired initiators and targets 
// to connect them to testbench and control in test.cpp

module XFabricCover (
	input logic clk,
	input logic rstn
  , input  logic           SCRm_req_vld
  , input  logic           SCRm_req_wr
  , input  logic [23:0] SCRm_req_adr
  , input  logic [3:0] SCRm_req_strb
  , input  logic [31:0] SCRm_req_dat
  , output logic           SCRm_req_gnt
  , output logic           SCRm_rsp_vld
  , output logic [31:0] SCRm_rsp_dat
  , input  logic           SCRm_rsp_gnt
);

logic           RAMs_req_vld;
logic           RAMs_req_wr;
logic [20:0] RAMs_req_adr;
logic [3:0] RAMs_req_strb;
logic [31:0] RAMs_req_dat;
logic      RAMs_req_gnt;
logic      RAMs_rsp_vld;
logic [31:0] RAMs_rsp_dat;
logic           RAMs_rsp_gnt;
XFabric Fabric ( .clk(clk), .rstn(rstn)
  , .CPUm_req_vld (1'b0)
  , .CPUm_req_wr  (1'b0)
  , .CPUm_req_adr  (24'd0)
  , .CPUm_req_strb (4'd0)
  , .CPUm_req_dat  (32'd0)
  , .CPUm_req_gnt ()
  , .CPUm_rsp_vld ()
  , .CPUm_rsp_dat ()
  , .CPUm_rsp_gnt (1'b0)
  , .SCRm_req_vld (SCRm_req_vld)
  , .SCRm_req_wr  (SCRm_req_wr)
  , .SCRm_req_adr  (SCRm_req_adr)
  , .SCRm_req_strb (SCRm_req_strb)
  , .SCRm_req_dat  (SCRm_req_dat)
  , .SCRm_req_gnt (SCRm_req_gnt)
  , .SCRm_rsp_vld (SCRm_rsp_vld)
  , .SCRm_rsp_dat (SCRm_rsp_dat)
  , .SCRm_rsp_gnt (SCRm_rsp_gnt)
  , .BRUm_req_vld (1'b0)
  , .BRUm_req_wr  (1'b0)
  , .BRUm_req_adr  (24'd0)
  , .BRUm_req_strb (2'd0)
  , .BRUm_req_dat  (16'd0)
  , .BRUm_req_gnt ()
  , .BRUm_rsp_vld ()
  , .BRUm_rsp_dat ()
  , .BRUm_rsp_gnt (1'b0)

  , .CPUs_req_vld ()
  , .CPUs_req_wr ()
  , .CPUs_req_adr ()
  , .CPUs_req_strb ()
  , .CPUs_req_dat ()
  , .CPUs_req_gnt (1'b0)
  , .CPUs_rsp_vld (1'b0)
  , .CPUs_rsp_dat (16'd0)
  , .CPUs_rsp_gnt ()
  , .SCRs_req_vld ()
  , .SCRs_req_wr ()
  , .SCRs_req_adr ()
  , .SCRs_req_strb ()
  , .SCRs_req_dat ()
  , .SCRs_req_gnt (1'b0)
  , .SCRs_rsp_vld (1'b0)
  , .SCRs_rsp_dat (16'd0)
  , .SCRs_rsp_gnt ()
  , .KBDs_req_vld ()
  , .KBDs_req_wr ()
  , .KBDs_req_adr ()
  , .KBDs_req_strb ()
  , .KBDs_req_dat ()
  , .KBDs_req_gnt (1'b0)
  , .KBDs_rsp_vld (1'b0)
  , .KBDs_rsp_dat (8'd0)
  , .KBDs_rsp_gnt ()
  , .RAMs_req_vld (RAMs_req_vld)
  , .RAMs_req_wr (RAMs_req_wr)
  , .RAMs_req_adr (RAMs_req_adr)
  , .RAMs_req_strb (RAMs_req_strb)
  , .RAMs_req_dat (RAMs_req_dat)
  , .RAMs_req_gnt (RAMs_req_gnt)
  , .RAMs_rsp_vld (RAMs_rsp_vld)
  , .RAMs_rsp_dat (RAMs_rsp_dat)
  , .RAMs_rsp_gnt (RAMs_rsp_gnt)
  , .ROMs_req_vld ()
  , .ROMs_req_wr ()
  , .ROMs_req_adr ()
  , .ROMs_req_strb ()
  , .ROMs_req_dat ()
  , .ROMs_req_gnt (1'b0)
  , .ROMs_rsp_vld (1'b0)
  , .ROMs_rsp_dat (16'd0)
  , .ROMs_rsp_gnt ()
);

DummyTarget #(.AW(21), .DW(32), .DMMY_AW (2)) DmyRAM (.clk(clk), .rstn(rstn),
  .req_vld    (RAMs_req_vld),
  .req_gnt    (RAMs_req_gnt),
  .req_wr     (RAMs_req_wr),
  .req_strb   (RAMs_req_strb),
  .req_adr    (RAMs_req_adr),
  .req_dat    (RAMs_req_dat),
  .rsp_vld    (RAMs_rsp_vld),
  .rsp_gnt    (RAMs_rsp_gnt),
  .rsp_dat     (RAMs_rsp_dat)
);
endmodule

module DummyTarget #(parameter AW = 24, DW = 16, DMMY_AW = 2) (
  input  logic clk,
  input  logic rstn,

  input  logic              req_vld,
  output logic              req_gnt,
  input  logic              req_wr,
  input  logic [(DW/8)-1:0] req_strb,
  input  logic [AW-1:0]     req_adr,
  input  logic [DW-1:0]     req_dat,

  output logic              rsp_vld,
  input  logic              rsp_gnt,
  output logic [DW-1:0]     rsp_dat
);
localparam LW_IDX = $clog2(DW/8);
localparam UW_IDX = (DMMY_AW - 1) < LW_IDX ? LW_IDX : DMMY_AW - 1;

logic [DW-1:0] mem [0 : (1 << (UW_IDX - LW_IDX + 1))-1];
logic state;

logic [UW_IDX:LW_IDX] cur_adr;

assign rsp_dat = mem [cur_adr];

`ifndef SELECT_SRSTn
always @(posedge clk, negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (~rstn) begin
    state   <= 1'b0;

    req_gnt <= 1'b1;
    rsp_vld <= 1'b0;

    cur_adr <= {(UW_IDX-LW_IDX+1){1'b0}};
  end else begin

    case (state)
      1'b0 : begin
              state    <= req_vld & req_gnt ? 1'b1 : state;

              req_gnt  <= req_vld ? 1'b0 : req_gnt;
              rsp_vld  <= req_vld ? 1'b1 : rsp_vld;

              cur_adr <= req_vld ? req_adr [UW_IDX:LW_IDX] : cur_adr;
             end
      1'b1 : begin
              state    <= rsp_gnt ? 1'b0 : state;

              req_gnt  <= rsp_gnt ? 1'b1 : req_gnt;
              rsp_vld  <= rsp_gnt ? 1'b0 : rsp_vld;
             end
    endcase
  end
end

integer i;
always @(posedge clk)
  if (req_vld & req_gnt & req_wr)
    for (i = 0; i < DW/8; i++) begin
      if (req_strb [i])
        mem [req_adr[UW_IDX:LW_IDX]][(i*8)+:8] <= req_dat [(i*8)+:8];
    end

endmodule
//EOF
