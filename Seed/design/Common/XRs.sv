// HMTH (c)

module XRs #(parameter D_WIDTH = 16)
(
  input  logic clk,
  input  logic rstn,

  input  logic vld_s,
  output logic rdy_s,
  input  logic [D_WIDTH-1:0] data_s,

  output logic vld_m,
  input  logic rdy_m,
  output logic [D_WIDTH-1:0] data_m
);

  localparam IDLE  = 2'b01;
  localparam BUSY0 = 2'b00;
  localparam BUSY1 = 2'b10;

  logic [1:0] state, nxt_state;
  logic nxt_vld_m;
  logic [D_WIDTH-1:0] nxt_data_m, saved_data;

`ifndef SELECT_SRSTn
always @(posedge clk or negedge rstn) begin
`else
always @(posedge clk) begin
`endif
  if (rstn == 1'b0) begin
    state <= BUSY0;
    vld_m  <= 1'b0;
  end else begin
    case (state)
      IDLE:  begin
               state <= rdy_m ? IDLE
                             : vld_s & vld_m ? BUSY1
                                           : vld_s ? BUSY0 : state;
               vld_m  <= vld_s;
               data_m <= rdy_m ? data_s
                             : ~vld_s & vld_m ? data_s : data_m;
               saved_data <= ~rdy_m & vld_m ? data_s : saved_data;
             end
      BUSY0: begin
               state <= rdy_m ? IDLE : state;
               vld_m  <= rdy_m ? 1'b0 : vld_m;
             end
      BUSY1: begin
							 state <= rdy_m ? BUSY0 : state;
							 data_m <= rdy_m ? saved_data : data_m;
             end
      default: begin
                 state      <= 2'bX;
                 vld_m       <= 1'bX;
                 data_m      <= {(D_WIDTH){1'bx}};
                 saved_data <= {(D_WIDTH){1'bx}};
               end
    endcase
  end
end

assign rdy_s = state [0];

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
        if ($past(vld_s) & $past(rdy_m)) assert (vld_m & (data_m == $past(data_s))); // After 1 cycle, data must arrive output port
      end
    end
  `else
		ast_delay_1cyc: assert property (@(posedge clk) disable iff (!rstn) vld_s & rdy_m |=> vld_m & (data_m = $past(data_s)));
	`endif
`endif
endmodule
// EOF
