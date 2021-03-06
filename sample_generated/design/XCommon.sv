// HMTH (c)

module XHndSk #(parameter D_WIDTH = 16)
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
		datao <= {(D_WIDTH){1'b0}};;
	end else begin
		state <= nxt_state;
		vldo  <= nxt_vldo;
		datao <= nxt_datao;
	end
end

assign rdyi = state;

endmodule

// In below module, N is usually 2 or 3 (make sure to evaluate MTBF)
module XSyncer #(parameter DW = 2, N = 2) (
	input logic clk,
	input logic rstn,

	input  logic [DW-1:0] d,
	output logic [DW-1:0] q
);

logic [DW-1:0] sync_ff [0:N-2];

integer i;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
	if (~rstn) begin
		for (i = 0; i < N-1; i++)
			sync_ff [i] <= {DW{1'b0}};		
		q <= {DW{1'b0}};
	end else begin
		sync_ff [0] <= d;
		for (i = 1; i < N-1; i++)
			sync_ff [i] <= sync_ff [i-1];
		q <= sync_ff [N-2];
	end
end

endmodule

module XArbFirstOneBit #(parameter DW = 8, MASK_OUT = 0) (
  input  logic [DW-1:0] i,
  output logic [DW-1:0] o
);

logic [DW-1:0] mask;

localparam N = $clog2(DW);

logic [DW*(N+1)-1:0] comp_grid;

integer k, l;
always @(*) begin
  comp_grid [DW-1:0] = i;
  for (l = 1; l <=N; l++) begin
    for (k = 0; k < DW; k=k+2)
      if (k < (l == 1 ? 0 : 1 << (l-1))) begin
        comp_grid[DW*l + k]   = comp_grid[(l-1)*DW + k];
        if (k < DW-1)
          comp_grid[DW*l + k+1] = comp_grid[(l-1)*DW + k+1];
      end else begin
        comp_grid[l*DW + k]   = comp_grid[(l-1)*DW + k]   | comp_grid[(l-1)*DW + k -( (1 << (l-1))-1 )];
        if (k < DW-1)
          comp_grid[l*DW + k+1] = comp_grid[(l-1)*DW + k+1] | comp_grid[(l-1)*DW + k -( (1 << (l-1))-1 )];
      end
  end
end

assign mask = comp_grid [(N*DW) +: DW];

assign o = MASK_OUT == 0 ? i & ~(mask << 1) : mask << 1;

endmodule
// EOF
