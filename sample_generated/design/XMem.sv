module XMem #(parameter DW = 8, DEPTH = 4) (
    input  logic clk
  , input  logic we
  , input  logic [$clog2(DEPTH)-1:0] waddr
  , input  logic [$clog2(DEPTH)-1:0] raddr
  , input  logic [DW-1:0] d
  , output logic [DW-1:0] q
);

reg [DW-1:0] mem [0:DEPTH-1];

always @(posedge clk)
  if (we)
    mem[waddr] <= d;

assign q = mem[raddr];

endmodule
