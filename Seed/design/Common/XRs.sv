// HMTH (c)

module XRs #(parameter D_WIDTH = 16)
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

  localparam IDLE  = 2'b01;
  localparam BUSY0 = 2'b00;
  localparam BUSY1 = 2'b10;

  logic [1:0] state, nxt_state;
  logic nxt_vldo;
  logic [D_WIDTH-1:0] nxt_datao, saved_data;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (rstn == 1'b0) begin
    state <= BUSY0;
    vldo  <= 1'b0;
  end else begin
    case (state):
      IDLE:  begin
               state <= rdyo ? IDLE
                             : vldi & vldo ? BUSY1
                                           : vldi ? BUSY0 : state;
               vldo  <= vldi;
               datao <= rdyo ? datai
                             : ~vldi & vldo ? datai : datao;
               saved_data <= ~rdyo & vldo ? datai : saved_data;
             end
      BUSY0: begin
               state <= rdyo ? IDLE : state;
               vldo  <= rdyo ? 1'b0 : vldo;
             end
      BUSY1: begin
							 state <= rdyo ? BUSY0 : state;
							 datao <= rdyo ? saved_data : datao;
             end
      default: begin
                 state      <= 2'bX;
                 vldo       <= 1'bX;
                 datao      <= {(D_WIDTH){1'bx}};
                 saved_data <= {(D_WIDTH){1'bx}};
               end
    endcase
  end
end

assign rdyi = state [0];

`ifndef SYNTHESIS
  `ifndef RICHMAN
    logic init = 1'b1;
    always @(posedge clk) begin
      if (init) assume (~rstn);
      init <= 1'b0;
    end
    
    // Validating register slice behavior 
    always @(posedge clk) begin
      if (rstn) begin
        if ($past(vldi) & $past(rdyo)) assert (vldo & (datao == $past(datai))); // After 1 cycle, data must arrive output port
      end
    end
  `else
		ast_delay_1cyc: assert property (@(posedge clk) disable iff (!rstn) vldi & rdyo |=> vldo & (datao = $past(datai)));
	`endif
`endif
endmodule
// EOF
