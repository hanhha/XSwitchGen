// HMTH (c)
// Synchronizer with reset to all 0. 

// In below module, N is usually 2 or 3 (make sure to evaluate MTBF)
module XSyncer #(parameter N = 2) (
  input logic clk,
  input logic rstn,

  input  logic d,
  output logic q
);

logic [N-2:0] sync_ff;

integer i;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (~rstn) begin
    for (i = 0; i < N-1; i++)
      sync_ff [i] <= 1'b0;
    q <= 1'b0;
  end else begin
    sync_ff [0] <= d;
    for (i = 1; i < N-1; i++)
      sync_ff [i] <= sync_ff [i-1];
    q <= sync_ff [N-2];
  end
end

endmodule
// EOF
