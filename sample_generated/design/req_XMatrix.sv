// HMTH (c)
// Matrix of XPoints

module req_XMatrix #(parameter VDW = 66) (
    input  logic [4:0] I0_req
  , input  logic [4:0] I1_req
  , input  logic [4:0] I2_req

  , input  logic [VDW-1 : 0] I0 
  , input  logic [VDW-1 : 0] I1 
  , input  logic [VDW-1 : 0] I2 

  , output logic [VDW-1 : 0] T0 
  , output logic [VDW-1 : 0] T1 
  , output logic [VDW-1 : 0] T2 
  , output logic [VDW-1 : 0] T3 
  , output logic [VDW-1 : 0] T4 
);

logic  X00_BEN;
logic [VDW-1:0] X00_I0, X00_I1, X00_O0, X00_O1;
logic  X01_BEN;
logic [VDW-1:0] X01_I0, X01_I1, X01_O0, X01_O1;
logic  X02_BEN;
logic [VDW-1:0] X02_I0, X02_I1, X02_O0, X02_O1;
logic  X03_BEN;
logic [VDW-1:0] X03_I0, X03_I1, X03_O0, X03_O1;
logic  X04_BEN;
logic [VDW-1:0] X04_I0, X04_I1, X04_O0, X04_O1;
logic  X10_BEN;
logic [VDW-1:0] X10_I0, X10_I1, X10_O0, X10_O1;
logic  X11_BEN;
logic [VDW-1:0] X11_I0, X11_I1, X11_O0, X11_O1;
logic  X12_BEN;
logic [VDW-1:0] X12_I0, X12_I1, X12_O0, X12_O1;
logic  X13_BEN;
logic [VDW-1:0] X13_I0, X13_I1, X13_O0, X13_O1;
logic  X14_BEN;
logic [VDW-1:0] X14_I0, X14_I1, X14_O0, X14_O1;
logic  X20_BEN;
logic [VDW-1:0] X20_I0, X20_I1, X20_O0, X20_O1;
logic  X21_BEN;
logic [VDW-1:0] X21_I0, X21_I1, X21_O0, X21_O1;
logic  X22_BEN;
logic [VDW-1:0] X22_I0, X22_I1, X22_O0, X22_O1;
logic  X23_BEN;
logic [VDW-1:0] X23_I0, X23_I1, X23_O0, X23_O1;
logic  X24_BEN;
logic [VDW-1:0] X24_I0, X24_I1, X24_O0, X24_O1;

// Connections
assign X00_I0 = {VDW{1'b0}};
assign X00_I1 = X01_O0;
assign X01_I0 = {VDW{1'b0}};
assign X01_I1 = X02_O0;
assign X02_I0 = {VDW{1'b0}};
assign X02_I1 = X03_O0;
assign X03_I0 = {VDW{1'b0}};
assign X03_I1 = X04_O0;
assign X04_I0 = {VDW{1'b0}};
assign X04_I1 = I0;
assign X10_I0 = X00_O1;
assign X10_I1 = X11_O0;
assign X11_I0 = X01_O1;
assign X11_I1 = X12_O0;
assign X12_I0 = X02_O1;
assign X12_I1 = X13_O0;
assign X13_I0 = X03_O1;
assign X13_I1 = X14_O0;
assign X14_I0 = X04_O1;
assign X14_I1 = I1;
assign X20_I0 = X10_O1;
assign X20_I1 = X21_O0;
assign X21_I0 = X11_O1;
assign X21_I1 = X22_O0;
assign X22_I0 = X12_O1;
assign X22_I1 = X23_O0;
assign X23_I0 = X13_O1;
assign X23_I1 = X24_O0;
assign X24_I0 = X14_O1;
assign X24_I1 = I2;

assign T0 = X20_O1;
assign T1 = X21_O1;
assign T2 = X22_O1;
assign T3 = X23_O1;
assign T4 = X24_O1;

assign X00_BEN = 1'b0; // Unconnected
assign X01_BEN = I0_req [1];
assign X02_BEN = I0_req [2];
assign X03_BEN = I0_req [3];
assign X04_BEN = 1'b0; // Unconnected
assign X10_BEN = 1'b0; // Unconnected
assign X11_BEN = 1'b0; // Unconnected
assign X12_BEN = 1'b0; // Unconnected
assign X13_BEN = I1_req [3];
assign X14_BEN = 1'b0; // Unconnected
assign X20_BEN = I2_req [0];
assign X21_BEN = 1'b0; // Unconnected
assign X22_BEN = 1'b0; // Unconnected
assign X23_BEN = I2_req [3];
assign X24_BEN = I2_req [4];

// Matrix instance
// ==========================
//     I_0
// I_1  +  O_0
//     O_1
// assign O0 = BEN ? I0 : I1;
// assign O1 = BEN ? I1 : I0;
// ==========================
assign X00_O0 =  X00_BEN ? X00_I0 : X00_I1;
assign X00_O1 =  X00_BEN ? X00_I1 : X00_I0;
assign X01_O0 =  X01_BEN ? X01_I0 : X01_I1;
assign X01_O1 =  X01_BEN ? X01_I1 : X01_I0;
assign X02_O0 =  X02_BEN ? X02_I0 : X02_I1;
assign X02_O1 =  X02_BEN ? X02_I1 : X02_I0;
assign X03_O0 =  X03_BEN ? X03_I0 : X03_I1;
assign X03_O1 =  X03_BEN ? X03_I1 : X03_I0;
assign X04_O0 =  X04_BEN ? X04_I0 : X04_I1;
assign X04_O1 =  X04_BEN ? X04_I1 : X04_I0;
assign X10_O0 =  X10_BEN ? X10_I0 : X10_I1;
assign X10_O1 =  X10_BEN ? X10_I1 : X10_I0;
assign X11_O0 =  X11_BEN ? X11_I0 : X11_I1;
assign X11_O1 =  X11_BEN ? X11_I1 : X11_I0;
assign X12_O0 =  X12_BEN ? X12_I0 : X12_I1;
assign X12_O1 =  X12_BEN ? X12_I1 : X12_I0;
assign X13_O0 =  X13_BEN ? X13_I0 : X13_I1;
assign X13_O1 =  X13_BEN ? X13_I1 : X13_I0;
assign X14_O0 =  X14_BEN ? X14_I0 : X14_I1;
assign X14_O1 =  X14_BEN ? X14_I1 : X14_I0;
assign X20_O0 =  X20_BEN ? X20_I0 : X20_I1;
assign X20_O1 =  X20_BEN ? X20_I1 : X20_I0;
assign X21_O0 =  X21_BEN ? X21_I0 : X21_I1;
assign X21_O1 =  X21_BEN ? X21_I1 : X21_I0;
assign X22_O0 =  X22_BEN ? X22_I0 : X22_I1;
assign X22_O1 =  X22_BEN ? X22_I1 : X22_I0;
assign X23_O0 =  X23_BEN ? X23_I0 : X23_I1;
assign X23_O1 =  X23_BEN ? X23_I1 : X23_I0;
assign X24_O0 =  X24_BEN ? X24_I0 : X24_I1;
assign X24_O1 =  X24_BEN ? X24_I1 : X24_I0;

`ifndef SYNTHESIS
// Validating inputs
// All I*_req are onehot0
  `ifndef RICHMAN
    integer I0_ones;
    integer I1_ones;
    integer I2_ones;
    integer i;

/* verilator lint_off WIDTH */
    always @(*) begin
      I0_ones = 0;
      I1_ones = 0;
      I2_ones = 0;
      for (i = 0; i < 5; i++) begin 
        I0_ones = I0_ones + I0_req [i];
        I1_ones = I1_ones + I1_req [i];
        I2_ones = I2_ones + I2_req [i];
      end
      assume (I0_ones <= 1);
      assume (I1_ones <= 1);
      assume (I2_ones <= 1);
    end
/* verilator lint_on WIDTH */
  `else
    always @(*) begin
      assume ($onehot0 (I0_req));
      assume ($onehot0 (I1_req));
      assume ($onehot0 (I2_req));
    end
  `endif

// Guarantee no dupplicated request
  always @(*) begin
    assume ((I0_req ^ I1_req) == (I0_req | I1_req));
    assume ((I0_req ^ I2_req) == (I0_req | I2_req));
    assume ((I1_req ^ I2_req) == (I1_req | I2_req));
  end

// Verifying output
/* verilator lint_off CASEINCOMPLETE */
  always @(*) begin
    case (I0_req)
      5'd2: assert (T1 == I0);
      5'd4: assert (T2 == I0);
      5'd8: assert (T3 == I0);
    endcase
    case (I1_req)
      5'd8: assert (T3 == I1);
    endcase
    case (I2_req)
      5'd1: assert (T0 == I2);
      5'd8: assert (T3 == I2);
      5'd16: assert (T4 == I2);
    endcase
  end
/* verilator lint_on CASEINCOMPLETE */

`endif

endmodule
//EOF
