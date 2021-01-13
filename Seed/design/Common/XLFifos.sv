// HMTH (c)
// Tagged linked-list based fifo with multiple output port.

module XLFifos # (parameter VCN = 64, parameter D = 11, parameter DEPTH = 16, parameter A = 4)
(
	input logic           clk, 
  input logic           rstn,

  input logic [VCN-1:0] we, 
  input logic [D-1:0]   din, 
  input logic [VCN-1:0] re, 

  output logic [VCN*D-1:0] dout,
  output logic [VCN-1:0]   empty_n,
  output logic             full_n_out
);

localparam TWIDTH     = $clog2(VCN);
localparam EWIDTH     = D + A;
localparam MDEPTH     = DEPTH - 1;

localparam PTR_NULL = {A{1'b1}}; // All 1's means NULL, that means only DEPTH - 1 entries are meaningful

logic [EWIDTH - 1 : 0] mem     [0:DEPTH-1];
logic [EWIDTH - 1 : 0] nxt_mem [0:DEPTH-1];

logic [D - 1 : 0] taggedFifo     [0:VCN-1];
logic [D - 1 : 0] nxt_taggedFifo [0:VCN-1];
logic                  taggedFifo_vld     [0:VCN-1];
logic                  nxt_taggedFifo_vld [0:VCN-1];

logic [A - 1 : 0] tails     [0:VCN-1];
logic [A - 1 : 0] nxt_tails [0:VCN-1];
logic [A - 1 : 0] heads     [0:VCN-1];
logic [A - 1 : 0] nxt_heads [0:VCN-1];

`define NXT_PTR A - 1 : 0
`define DATA EWIDTH - 1 : A

  logic                  dealloc;
  logic [A - 1 : 0] dealloc_ptr;
  logic allocate_en;

  logic free_vld;
  logic [A - 1 : 0] free_ptr;

// mem_allocator // Allocating memory pointer for new data {{{
  logic free_mem_full, really_free_mem_full;
  logic [A : 0] avail_entries;

  assign dealloc_ptr = heads [tagr_in];
  assign dealloc     = ren_in && data_vld_out [tagr_in] ? 1'b1 : 1'b0;

`ifdef SYNTHESIS
  `ifdef SVA_ON
  // synopsys translate_off
  NOT_DEALLOC_WHEN_FREE_MEM_FULL: assert (@(posedge clk) disable iff (sRESET) (ren_in |-> ~free_mem_full)); 
  // synopsys translate_on
  `endif
`endif

  logic [1:0]        allocator_phase, nxt_allocator_phase;
  logic              init_we, nxt_init_we, init_alloc, nxt_init_alloc;
  logic [A-1:0] init_cnt, nxt_init_cnt;

  localparam ALLOC_INIT_IDLE = 2'b00;
  localparam ALLOC_INIT_WORK = 2'b01;
  localparam ALLOC_INIT_DONE = 2'b10;

  localparam MAX_INIT_VAL    = MDEPTH - 1;
  always_comb begin
    case (allocator_phase)
      ALLOC_INIT_IDLE: begin
        nxt_allocator_phase = ALLOC_INIT_WORK;
        nxt_init_cnt        = 'd0;
        nxt_init_we         = 1'b1;
        nxt_init_alloc      = 1'b1;
      end
      ALLOC_INIT_WORK: begin
        nxt_allocator_phase = init_cnt == MAX_INIT_VAL [A-1:0] ? ALLOC_INIT_DONE : allocator_phase;
        nxt_init_cnt        = init_cnt == MAX_INIT_VAL [A-1:0] ? init_cnt : init_cnt + 1'b1;
        nxt_init_we         = init_cnt == MAX_INIT_VAL [A-1:0] ? 1'b0 : init_we;
        nxt_init_alloc      = init_cnt == MAX_INIT_VAL [A-1:0] ? 1'b0 : init_alloc;
      end
      ALLOC_INIT_DONE: begin
        nxt_allocator_phase = allocator_phase;
        nxt_init_cnt        = init_cnt;
        nxt_init_we         = init_we;
        nxt_init_alloc      = init_alloc;
      end
      default: begin
        nxt_allocator_phase = ALLOC_INIT_IDLE;
        nxt_init_cnt        = 'd0;
        nxt_init_we         = 1'b0;
        nxt_init_alloc      = 1'b1;
      end
    endcase
  end
  prim_ff_reset #(.SIZE(2),      .RESET_VALUE(ALLOC_INIT_IDLE)) allocator_state_ff (.q (allocator_phase), .d (nxt_allocator_phase), .CLK (CLK), .RESET(sRESET));
  prim_ff_reset #(.SIZE(A), .RESET_VALUE({A{1'b0}}))  init_cnt_ff        (.q (init_cnt),        .d (nxt_init_cnt),        .CLK (CLK), .RESET(sRESET));
  prim_ff_reset #(.SIZE(1),      .RESET_VALUE(1'b0))            init_we_ff         (.q (init_we),         .d (nxt_init_we),         .CLK (CLK), .RESET(sRESET));
  prim_ff_reset #(.SIZE(1),      .RESET_VALUE(1'b1))            init_alloc_ff      (.q (init_alloc),      .d (nxt_init_alloc),      .CLK (CLK), .RESET(sRESET));

  logic [A-1 : 0] allocator_din;
  logic                allocator_we;

  assign allocator_din = init_alloc == 1'b1 ? init_cnt : dealloc_ptr; 
  assign allocator_we      = init_alloc == 1'b1 ? init_we : dealloc;

  mb_fifo_regs #(.fifo_width(A), .fifo_depth(DEPTH), .fifo_awidth(A))
  allocator (.clk (CLK), .reset_b (~sRESET), .wr (allocator_we), .din (allocator_din),
             .rd  (allocate_en), .full_level (MDEPTH[A:0]),
             .level (avail_entries), .full (free_mem_full), .really_full (really_free_mem_full),
             .valid (free_vld), .dout_s (free_ptr));

  LintSink #($bits({avail_entries, free_mem_full, really_free_mem_full})) sink_allocator (.d({avail_entries, free_mem_full, really_free_mem_full}));
  assign full_n_out = free_vld & ~init_alloc;
// }}}

// fifo_update_after_read_or_write // {{{
  generate
    for (genvar tag = 0; tag < VCN; tag++) begin: tagged_fifos
      always_comb begin
        if (wen_in && (tagw_in == tag) && ren_in && (tagr_in == tag)) begin // spyglass disable STARC02-2.7.3.1c 
          nxt_heads          [tag] = taggedFifo_vld [tag] == 1'b0       ? heads [tag]                                              : (heads[tag] == tails[tag] ? (free_vld == 1'b1 ? free_ptr : PTR_NULL) : mem [heads[tag]][`NXT_PTR]); 
          nxt_tails          [tag] = taggedFifo_vld [tag] == 1'b0       ? tails [tag]                                              : (free_vld == 1'b1         ? free_ptr                                 : PTR_NULL);
          nxt_taggedFifo_vld [tag] = taggedFifo_vld [tag] == 1'b0       ? free_vld                                                 : (heads[tag] == tails[tag] ? free_vld                                 : taggedFifo_vld [tag]);
          nxt_taggedFifo     [tag] = taggedFifo_vld [tag] == 1'b0       ? din                                                  : (heads[tag] == tails[tag] ? din                                  : mem [nxt_heads[tag]][`DATA]);
        end else if (wen_in && (tagw_in == tag)) begin
          nxt_heads          [tag] = taggedFifo_vld [tag] == 1'b0       ? (free_vld == 1'b1 ? free_ptr : PTR_NULL)                 : heads [tag];
          nxt_tails          [tag] = free_vld                           ? free_ptr                                                 : PTR_NULL;
          nxt_taggedFifo_vld [tag] = taggedFifo_vld [tag] == 1'b0       ? free_vld                                                 : taggedFifo_vld [tag];
          nxt_taggedFifo     [tag] = taggedFifo_vld [tag] == 1'b0       ? din                                                  : taggedFifo [tag];
        end else if (ren_in && (tagr_in == tag)) begin
          nxt_heads          [tag] = taggedFifo_vld [tag] == 1'b1       ? mem [heads[tag]][`NXT_PTR]                               : heads [tag]; 
          nxt_tails          [tag] = heads          [tag] == tails[tag] ? PTR_NULL                                                 : tails [tag];
          nxt_taggedFifo_vld [tag] = taggedFifo_vld [tag] == 1'b1       ? (heads[tag] == tails[tag] ? 1'b0 : taggedFifo_vld [tag]) : taggedFifo_vld [tag]; 
          nxt_taggedFifo     [tag] = taggedFifo_vld [tag] == 1'b1       ? mem [nxt_heads[tag]][`DATA]                              : taggedFifo [tag];
        end else begin
          nxt_heads          [tag] = heads          [tag];
          nxt_tails          [tag] = tails          [tag];
          nxt_taggedFifo_vld [tag] = taggedFifo_vld [tag];
          nxt_taggedFifo     [tag] = taggedFifo     [tag];
        end
      end
      

      prim_ff_reset #(.SIZE(D), .RESET_VALUE({D{1'b0}})) taggedFifo_ff_i     (.q (taggedFifo    [tag]), .d (nxt_taggedFifo    [tag]), .CLK (CLK), .RESET (sRESET));
      prim_ff_reset #(.SIZE(1),      .RESET_VALUE(1'b0))           taggedFifo_vld_ff_i (.q (taggedFifo_vld[tag]), .d (nxt_taggedFifo_vld[tag]), .CLK (CLK), .RESET (sRESET));
      prim_ff_reset #(.SIZE(A), .RESET_VALUE(PTR_NULL))       heads_ff_i          (.q (heads         [tag]), .d (nxt_heads         [tag]), .CLK (CLK), .RESET (sRESET));
      prim_ff_reset #(.SIZE(A), .RESET_VALUE(PTR_NULL))       tails_ff_i          (.q (tails         [tag]), .d (nxt_tails         [tag]), .CLK (CLK), .RESET (sRESET));
    end
  endgenerate
  assign allocate_en = wen_in && free_vld;
// }}}

// mem_update // {{{
  for (genvar mem_idx = 0; mem_idx < DEPTH; mem_idx++) begin: mem_ele
    assign nxt_mem [mem_idx] = wen_in ? (mem_idx == free_ptr ? {din, PTR_NULL} 
                                                             : (mem_idx == tails [tagw_in] ? {mem [mem_idx] [`DATA], free_ptr}
                                                                                           : mem [mem_idx] ) ) 
                                      : mem [mem_idx];
    prim_ff_reset #(.SIZE(EWIDTH), .RESET_VALUE({EWIDTH{1'b0}})) mem_ff_i (.q(mem[mem_idx]), .d(nxt_mem[mem_idx]), .CLK (CLK), .RESET (sRESET));                              
  end
// }}}


// Read out an entry which tagged <tagr_in>
generate
for (genvar tag = 0; tag < VCN; tag++) begin: tag_list
  assign dout     [tag] = taggedFifo [tag];
  assign data_vld_out [tag] = taggedFifo_vld [tag];
end
endgenerate

`undef NXT_PTR
`undef DATA
endmodule
// EOF
