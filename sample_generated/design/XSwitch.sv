// HMTH (c)

module XSwitch (
    input logic clk
  , input logic rstn

  , input  logic           CPUm_req_vld
  , input  logic [65:0] CPUm_req_pkt
  , output logic           CPUm_req_gnt
  , output logic           CPUm_rsp_vld
  , output logic [36:0] CPUm_rsp_pkt
  , input  logic           CPUm_rsp_gnt
  , input  logic           SCRm_req_vld
  , input  logic [65:0] SCRm_req_pkt
  , output logic           SCRm_req_gnt
  , output logic           SCRm_rsp_vld
  , output logic [36:0] SCRm_rsp_pkt
  , input  logic           SCRm_rsp_gnt
  , input  logic           BRUm_req_vld
  , input  logic [65:0] BRUm_req_pkt
  , output logic           BRUm_req_gnt
  , output logic           BRUm_rsp_vld
  , output logic [36:0] BRUm_rsp_pkt
  , input  logic           BRUm_rsp_gnt

  , output logic           CPUs_req_vld
  , output logic [65:0] CPUs_req_pkt
  , input  logic           CPUs_req_gnt
  , input  logic           CPUs_rsp_vld
  , input  logic [36:0] CPUs_rsp_pkt
  , output logic           CPUs_rsp_gnt
  , output logic           SCRs_req_vld
  , output logic [65:0] SCRs_req_pkt
  , input  logic           SCRs_req_gnt
  , input  logic           SCRs_rsp_vld
  , input  logic [36:0] SCRs_rsp_pkt
  , output logic           SCRs_rsp_gnt
  , output logic           KBDs_req_vld
  , output logic [65:0] KBDs_req_pkt
  , input  logic           KBDs_req_gnt
  , input  logic           KBDs_rsp_vld
  , input  logic [36:0] KBDs_rsp_pkt
  , output logic           KBDs_rsp_gnt
  , output logic           RAMs_req_vld
  , output logic [65:0] RAMs_req_pkt
  , input  logic           RAMs_req_gnt
  , input  logic           RAMs_rsp_vld
  , input  logic [36:0] RAMs_rsp_pkt
  , output logic           RAMs_rsp_gnt
  , output logic           ROMs_req_vld
  , output logic [65:0] ROMs_req_pkt
  , input  logic           ROMs_req_gnt
  , input  logic           ROMs_rsp_vld
  , input  logic [36:0] ROMs_rsp_pkt
  , output logic           ROMs_rsp_gnt
);

req_XRouter req_route (  .clk (clk), .rstn (rstn)
                 , .I0_vld (CPUm_req_vld)
                 , .I0_pkt (CPUm_req_pkt)
                 , .I0_gnt (CPUm_req_gnt)
                 , .I1_vld (SCRm_req_vld)
                 , .I1_pkt (SCRm_req_pkt)
                 , .I1_gnt (SCRm_req_gnt)
                 , .I2_vld (BRUm_req_vld)
                 , .I2_pkt (BRUm_req_pkt)
                 , .I2_gnt (BRUm_req_gnt)

                 , .T0_vld (CPUs_req_vld)
                 , .T0_pkt (CPUs_req_pkt)
                 , .T0_rdy (CPUs_req_gnt)
                 , .T1_vld (SCRs_req_vld)
                 , .T1_pkt (SCRs_req_pkt)
                 , .T1_rdy (SCRs_req_gnt)
                 , .T2_vld (KBDs_req_vld)
                 , .T2_pkt (KBDs_req_pkt)
                 , .T2_rdy (KBDs_req_gnt)
                 , .T3_vld (RAMs_req_vld)
                 , .T3_pkt (RAMs_req_pkt)
                 , .T3_rdy (RAMs_req_gnt)
                 , .T4_vld (ROMs_req_vld)
                 , .T4_pkt (ROMs_req_pkt)
                 , .T4_rdy (ROMs_req_gnt)
                );

rsp_XRouter rsp_route (  .clk (clk), .rstn (rstn)
                 , .I0_vld (CPUs_rsp_vld)
                 , .I0_pkt (CPUs_rsp_pkt)
                 , .I0_gnt (CPUs_rsp_gnt)
                 , .I1_vld (SCRs_rsp_vld)
                 , .I1_pkt (SCRs_rsp_pkt)
                 , .I1_gnt (SCRs_rsp_gnt)
                 , .I2_vld (KBDs_rsp_vld)
                 , .I2_pkt (KBDs_rsp_pkt)
                 , .I2_gnt (KBDs_rsp_gnt)
                 , .I3_vld (RAMs_rsp_vld)
                 , .I3_pkt (RAMs_rsp_pkt)
                 , .I3_gnt (RAMs_rsp_gnt)
                 , .I4_vld (ROMs_rsp_vld)
                 , .I4_pkt (ROMs_rsp_pkt)
                 , .I4_gnt (ROMs_rsp_gnt)

                 , .T0_vld (CPUm_rsp_vld)
                 , .T0_pkt (CPUm_rsp_pkt)
                 , .T0_rdy (CPUm_rsp_gnt)
                 , .T1_vld (SCRm_rsp_vld)
                 , .T1_pkt (SCRm_rsp_pkt)
                 , .T1_rdy (SCRm_rsp_gnt)
                 , .T2_vld (BRUm_rsp_vld)
                 , .T2_pkt (BRUm_rsp_pkt)
                 , .T2_rdy (BRUm_rsp_gnt)
                );
endmodule
// EOF
