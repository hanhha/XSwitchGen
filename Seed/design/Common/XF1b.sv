// HMTH (c)

// ============================================================================
// Quick explanation: 4'b0110 => 4'b1110
// ============================================================================
module XF1b #(parameter DW = 8) (
  input  logic [DW-1:0] i,
  output logic [DW-1:0] o
);

logic [DW-1:0] mask;

localparam N = $clog2(DW);
logic [DW*(N+1)-1:0] comp_grid;

integer k, l;
always_comb begin
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

assign o = mask;

endmodule
// EOF