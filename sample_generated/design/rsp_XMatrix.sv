// HMTH (c)
// Matrix of XPoints

module rsp_XMatrix #(parameter VDW = 37) (
    input  logic [2:0] I0_req
  , input  logic [2:0] I1_req
  , input  logic [2:0] I2_req
  , input  logic [2:0] I3_req
  , input  logic [2:0] I4_req

  , input  logic [VDW-1 : 0] I0 
  , input  logic [VDW-1 : 0] I1 
  , input  logic [VDW-1 : 0] I2 
  , input  logic [VDW-1 : 0] I3 
  , input  logic [VDW-1 : 0] I4 

  , output logic [VDW-1 : 0] T0 
  , output logic [VDW-1 : 0] T1 
  , output logic [VDW-1 : 0] T2 
);

logic  X00_BEN;
logic [VDW-1:0] X00_I0, X00_I1, X00_O0, X00_O1;
logic  X01_BEN;
logic [VDW-1:0] X01_I0, X01_I1, X01_O0, X01_O1;
logic  X02_BEN;
logic [VDW-1:0] X02_I0, X02_I1, X02_O0, X02_O1;
logic  X10_BEN;
logic [VDW-1:0] X10_I0, X10_I1, X10_O0, X10_O1;
logic  X11_BEN;
logic [VDW-1:0] X11_I0, X11_I1, X11_O0, X11_O1;
logic  X12_BEN;
logic [VDW-1:0] X12_I0, X12_I1, X12_O0, X12_O1;
logic  X20_BEN;
logic [VDW-1:0] X20_I0, X20_I1, X20_O0, X20_O1;
logic  X21_BEN;
logic [VDW-1:0] X21_I0, X21_I1, X21_O0, X21_O1;
logic  X22_BEN;
logic [VDW-1:0] X22_I0, X22_I1, X22_O0, X22_O1;
logic  X30_BEN;
logic [VDW-1:0] X30_I0, X30_I1, X30_O0, X30_O1;
logic  X31_BEN;
logic [VDW-1:0] X31_I0, X31_I1, X31_O0, X31_O1;
logic  X32_BEN;
logic [VDW-1:0] X32_I0, X32_I1, X32_O0, X32_O1;
logic  X40_BEN;
logic [VDW-1:0] X40_I0, X40_I1, X40_O0, X40_O1;
logic  X41_BEN;
logic [VDW-1:0] X41_I0, X41_I1, X41_O0, X41_O1;
logic  X42_BEN;
logic [VDW-1:0] X42_I0, X42_I1, X42_O0, X42_O1;

// Connections
assign X00_I0 = {VDW{1'b0}};
assign X00_I1 = X01_O0;
assign X01_I0 = {VDW{1'b0}};
assign X01_I1 = X02_O0;
assign X02_I0 = {VDW{1'b0}};
assign X02_I1 = I0;
assign X10_I0 = X00_O1;
assign X10_I1 = X11_O0;
assign X11_I0 = X01_O1;
assign X11_I1 = X12_O0;
assign X12_I0 = X02_O1;
assign X12_I1 = I1;
assign X20_I0 = X10_O1;
assign X20_I1 = X21_O0;
assign X21_I0 = X11_O1;
assign X21_I1 = X22_O0;
assign X22_I0 = X12_O1;
assign X22_I1 = I2;
assign X30_I0 = X20_O1;
assign X30_I1 = X31_O0;
assign X31_I0 = X21_O1;
assign X31_I1 = X32_O0;
assign X32_I0 = X22_O1;
assign X32_I1 = I3;
assign X40_I0 = X30_O1;
assign X40_I1 = X41_O0;
assign X41_I0 = X31_O1;
assign X41_I1 = X42_O0;
assign X42_I0 = X32_O1;
assign X42_I1 = I4;

assign T0 = X40_O1;
assign T1 = X41_O1;
assign T2 = X42_O1;

assign X00_BEN = 1'b0; // Unconnected
assign X01_BEN = 1'b0; // Unconnected
assign X02_BEN = I0_req [2];
assign X10_BEN = I1_req [0];
assign X11_BEN = 1'b0; // Unconnected
assign X12_BEN = 1'b0; // Unconnected
assign X20_BEN = I2_req [0];
assign X21_BEN = 1'b0; // Unconnected
assign X22_BEN = 1'b0; // Unconnected
assign X30_BEN = I3_req [0];
assign X31_BEN = I3_req [1];
assign X32_BEN = I3_req [2];
assign X40_BEN = 1'b0; // Unconnected
assign X41_BEN = 1'b0; // Unconnected
assign X42_BEN = I4_req [2];

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
assign X10_O0 =  X10_BEN ? X10_I0 : X10_I1;
assign X10_O1 =  X10_BEN ? X10_I1 : X10_I0;
assign X11_O0 =  X11_BEN ? X11_I0 : X11_I1;
assign X11_O1 =  X11_BEN ? X11_I1 : X11_I0;
assign X12_O0 =  X12_BEN ? X12_I0 : X12_I1;
assign X12_O1 =  X12_BEN ? X12_I1 : X12_I0;
assign X20_O0 =  X20_BEN ? X20_I0 : X20_I1;
assign X20_O1 =  X20_BEN ? X20_I1 : X20_I0;
assign X21_O0 =  X21_BEN ? X21_I0 : X21_I1;
assign X21_O1 =  X21_BEN ? X21_I1 : X21_I0;
assign X22_O0 =  X22_BEN ? X22_I0 : X22_I1;
assign X22_O1 =  X22_BEN ? X22_I1 : X22_I0;
assign X30_O0 =  X30_BEN ? X30_I0 : X30_I1;
assign X30_O1 =  X30_BEN ? X30_I1 : X30_I0;
assign X31_O0 =  X31_BEN ? X31_I0 : X31_I1;
assign X31_O1 =  X31_BEN ? X31_I1 : X31_I0;
assign X32_O0 =  X32_BEN ? X32_I0 : X32_I1;
assign X32_O1 =  X32_BEN ? X32_I1 : X32_I0;
assign X40_O0 =  X40_BEN ? X40_I0 : X40_I1;
assign X40_O1 =  X40_BEN ? X40_I1 : X40_I0;
assign X41_O0 =  X41_BEN ? X41_I0 : X41_I1;
assign X41_O1 =  X41_BEN ? X41_I1 : X41_I0;
assign X42_O0 =  X42_BEN ? X42_I0 : X42_I1;
assign X42_O1 =  X42_BEN ? X42_I1 : X42_I0;

`ifndef SYNTHESIS
// Validating inputs
// All I*_req are onehot0
  `ifndef RICHMAN
    integer I0_ones;
    integer I1_ones;
    integer I2_ones;
    integer I3_ones;
    integer I4_ones;
    integer i;

/* verilator lint_off WIDTH */
    always @(*) begin
      I0_ones = 0;
      I1_ones = 0;
      I2_ones = 0;
      I3_ones = 0;
      I4_ones = 0;
      for (i = 0; i < 3; i++) begin 
        I0_ones = I0_ones + I0_req [i];
        I1_ones = I1_ones + I1_req [i];
        I2_ones = I2_ones + I2_req [i];
        I3_ones = I3_ones + I3_req [i];
        I4_ones = I4_ones + I4_req [i];
      end
      assume (I0_ones <= 1);
      assume (I1_ones <= 1);
      assume (I2_ones <= 1);
      assume (I3_ones <= 1);
      assume (I4_ones <= 1);
    end
/* verilator lint_on WIDTH */
  `else
    always @(*) begin
      assume ($onehot0 (I0_req));
      assume ($onehot0 (I1_req));
      assume ($onehot0 (I2_req));
      assume ($onehot0 (I3_req));
      assume ($onehot0 (I4_req));
    end
  `endif

// Guarantee no dupplicated request
  always @(*) begin
    assume ((I0_req ^ I1_req) == (I0_req | I1_req));
    assume ((I0_req ^ I2_req) == (I0_req | I2_req));
    assume ((I0_req ^ I3_req) == (I0_req | I3_req));
    assume ((I0_req ^ I4_req) == (I0_req | I4_req));
    assume ((I1_req ^ I2_req) == (I1_req | I2_req));
    assume ((I1_req ^ I3_req) == (I1_req | I3_req));
    assume ((I1_req ^ I4_req) == (I1_req | I4_req));
    assume ((I2_req ^ I3_req) == (I2_req | I3_req));
    assume ((I2_req ^ I4_req) == (I2_req | I4_req));
    assume ((I3_req ^ I4_req) == (I3_req | I4_req));
  end

// Verifying output
/* verilator lint_off CASEINCOMPLETE */
  always @(*) begin
    case (I0_req)
      3'd4: assert (T2 == I0);
    endcase
    case (I1_req)
      3'd1: assert (T0 == I1);
    endcase
    case (I2_req)
      3'd1: assert (T0 == I2);
    endcase
    case (I3_req)
      3'd1: assert (T0 == I3);
      3'd2: assert (T1 == I3);
      3'd4: assert (T2 == I3);
    endcase
    case (I4_req)
      3'd4: assert (T2 == I4);
    endcase
  end
/* verilator lint_on CASEINCOMPLETE */

`endif

endmodule
//EOF
