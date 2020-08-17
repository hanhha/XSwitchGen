// HMTH (c)

module XHs #(parameter D_WIDTH = 16)
(
  input  logic clk,
  input  logic rstn,

  input  logic vldi,
  input  logic rdyo,
  input  logic [D_WIDTH-1:0] datai,

  output logic vldo,
  output logic rdyi,
  output logic [D_WIDTH-1:0] datao
);

  localparam IDLE = 1'b1;
  localparam BUSY = 1'b0;

  logic state, nxt_state;
  logic nxt_vldo;
  logic [D_WIDTH-1:0] nxt_datao;

  assign nxt_state = rdyo ? IDLE : 
                            vldi ? BUSY : state;
  assign nxt_vldo  = state == IDLE ? vldi :
                                     rdyo ? vldi : vldo;
  assign nxt_datao = state == IDLE ? datai :
                                     rdyo ? datai : datao;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (rstn == 1'b0) begin
    state <= IDLE;
    vldo  <= 1'b0;
    datao <= {(D_WIDTH){1'b0}};
  end else begin
    state <= nxt_state;
    vldo  <= nxt_vldo;
    datao <= nxt_datao;
  end
end

assign rdyi = rdyo;

endmodule
// EOF
