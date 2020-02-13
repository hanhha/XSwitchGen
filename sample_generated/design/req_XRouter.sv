// HMTH (c)

module req_XRouter #(parameter VDW = 66, DW = 61) (
    input logic clk
  , input logic rstn

  , input  logic           I0_vld
  , input  logic [VDW-1:0] I0_pkt // {init_tag, tgt_tag, pkt (tgt addr + data)}
  , output logic           I0_gnt
  , input  logic           I1_vld
  , input  logic [VDW-1:0] I1_pkt // {init_tag, tgt_tag, pkt (tgt addr + data)}
  , output logic           I1_gnt
  , input  logic           I2_vld
  , input  logic [VDW-1:0] I2_pkt // {init_tag, tgt_tag, pkt (tgt addr + data)}
  , output logic           I2_gnt

  , input  logic           T0_rdy
  , output logic           T0_vld
  , output logic [VDW-1:0] T0_pkt // {init_tag, tgt_tag, pkt (tgt addr + data}
  , input  logic           T1_rdy
  , output logic           T1_vld
  , output logic [VDW-1:0] T1_pkt // {init_tag, tgt_tag, pkt (tgt addr + data}
  , input  logic           T2_rdy
  , output logic           T2_vld
  , output logic [VDW-1:0] T2_pkt // {init_tag, tgt_tag, pkt (tgt addr + data}
  , input  logic           T3_rdy
  , output logic           T3_vld
  , output logic [VDW-1:0] T3_pkt // {init_tag, tgt_tag, pkt (tgt addr + data}
  , input  logic           T4_rdy
  , output logic           T4_vld
  , output logic [VDW-1:0] T4_pkt // {init_tag, tgt_tag, pkt (tgt addr + data}
);

logic [4:0] I0_req, I0_vreq;
logic [4:0] I1_req, I1_vreq;
logic [4:0] I2_req, I2_vreq;

always @(*) begin
  case (I0_pkt [63:61])
    3'd0    : I0_req = {4'b0, I0_vld};
    3'd1    : I0_req = {3'b0, I0_vld, 1'b0};
    3'd2    : I0_req = {2'b0, I0_vld, 2'b0};
    3'd3    : I0_req = {1'b0, I0_vld, 3'b0};
    3'd4    : I0_req = { I0_vld, 4'b0};
    default : I0_req = 5'b0;
  endcase
end
always @(*) begin
  case (I1_pkt [63:61])
    3'd0    : I1_req = {4'b0, I1_vld};
    3'd1    : I1_req = {3'b0, I1_vld, 1'b0};
    3'd2    : I1_req = {2'b0, I1_vld, 2'b0};
    3'd3    : I1_req = {1'b0, I1_vld, 3'b0};
    3'd4    : I1_req = { I1_vld, 4'b0};
    default : I1_req = 5'b0;
  endcase
end
always @(*) begin
  case (I2_pkt [63:61])
    3'd0    : I2_req = {4'b0, I2_vld};
    3'd1    : I2_req = {3'b0, I2_vld, 1'b0};
    3'd2    : I2_req = {2'b0, I2_vld, 2'b0};
    3'd3    : I2_req = {1'b0, I2_vld, 3'b0};
    3'd4    : I2_req = { I2_vld, 4'b0};
    default : I2_req = 5'b0;
  endcase
end

assign I0_gnt = |I0_vreq;
assign I1_gnt = |I1_vreq;
assign I2_gnt = |I2_vreq;

logic [4:0] T_rdy;
assign T_rdy = {T4_rdy, T3_rdy, T2_rdy, T1_rdy, T0_rdy};

logic [VDW:0] I0_pkt_ex;
assign I0_pkt_ex = {I0_pkt, I0_vld};

logic [VDW:0] I1_pkt_ex;
assign I1_pkt_ex = {I1_pkt, I1_vld};

logic [VDW:0] I2_pkt_ex;
assign I2_pkt_ex = {I2_pkt, I2_vld};


logic [VDW:0] T0_pkt_ex;
assign {T0_pkt, T0_vld} = T0_pkt_ex;

logic [VDW:0] T1_pkt_ex;
assign {T1_pkt, T1_vld} = T1_pkt_ex;

logic [VDW:0] T2_pkt_ex;
assign {T2_pkt, T2_vld} = T2_pkt_ex;

logic [VDW:0] T3_pkt_ex;
assign {T3_pkt, T3_vld} = T3_pkt_ex;

logic [VDW:0] T4_pkt_ex;
assign {T4_pkt, T4_vld} = T4_pkt_ex;


req_XArbiter XArbiter (.clk (clk), .rstn (rstn)
                   , .T_rdy   (T_rdy)
                   , .I0_req  (I0_req)
                   , .I0_vreq (I0_vreq)
                   , .I1_req  (I1_req)
                   , .I1_vreq (I1_vreq)
                   , .I2_req  (I2_req)
                   , .I2_vreq (I2_vreq)
                  );

req_XMatrix #(VDW+1) XMatrix (
                          .T0 (T0_pkt_ex)
                        , .T1 (T1_pkt_ex)
                        , .T2 (T2_pkt_ex)
                        , .T3 (T3_pkt_ex)
                        , .T4 (T4_pkt_ex)
                        , .I0_req (I0_vreq)
                        , .I0     (I0_pkt_ex)
                        , .I1_req (I1_vreq)
                        , .I1     (I1_pkt_ex)
                        , .I2_req (I2_vreq)
                        , .I2     (I2_pkt_ex)
                       );

`ifndef SYNTHESIS
// Validating output
always @(*) begin
  if (T0_vld) assert (T0_pkt [63:61] == 0);
  if (T1_vld) assert (T1_pkt [63:61] == 1);
  if (T2_vld) assert (T2_pkt [63:61] == 2);
  if (T3_vld) assert (T3_pkt [63:61] == 3);
  if (T4_vld) assert (T4_pkt [63:61] == 4);
end
`endif

endmodule
// EOF
