// HMTH (c)
// Priority arbiter

module XAPr #(parameter N = 8) (
    input  logic [N-1:0] req
  , input  logic         en
  , output logic [N-1:0] gnt
);

logic [N-1:0] mask;

XF1b #(N) pri_gnt (.i (req), .o (mask));
assign gnt = en ? mask ^ {mask [N-2:0], 1'b0} : {N{1'b0}};

endmodule
// EOF
