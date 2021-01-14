// HMTH (c)
// Tagged linked-list based fifo with multiple output port.
// DEPTH must be power of 2

module XLFifos # (parameter VCN = 64, parameter D = 11, parameter DEPTH = 16)
(
	input logic clk, 
  input logic rstn,

  input logic                    we,
  input logic  [$clog2(VCN)-1:0] w_vc,
  input logic  [D-1:0]           d, 
  output logic                   full_n,

  input  logic                   re,
  input  logic [$clog2(VCN)-1:0] r_vc,
  output logic [VCN*D-1:0]       q,
  output logic [VCN-1:0]         empty_n
);

  localparam A = $clog2(DEPTH);
  localparam E = D + A + 1;
  localparam VA = $clog2(VCN);
  
  logic [E-1:0] mem     [0:DEPTH-1];
  
  logic [A:0] tails     [0:VCN-1];
  logic [A:0] heads     [0:VCN-1];

`define NXT_PTR A:0
`define PTR     A-1:0
`define DATA    E-1:A+1
`define NULL    {(A+1){1'b0}}

  logic [A:0] dealloc_ptr; // MSB = 0 => invalid = not dealloc this space
  logic [A:0] free_ptr;    // MSB = 0 => invalid = no free space
  logic       alloc;

  logic [1:0]   allocator_phase;
  logic [A-1:0] init_cnt;

  localparam ALLOC_IDLE = 2'b00;
  localparam ALLOC_INIT = 2'b11; // bit 0 is use for determine Init state
  localparam ALLOC_WORK = 2'b10;

// =====  Allocator to alloc/dealloc free mem to store data {{{
  `ifndef SELECT_SRSTn
  always_ff @(posedge clk or negedge rstn) begin
  `else
  always_ff @(posedge clk) begin
  `endif
    if (~rstn) begin
      allocator_phase <= ALLOC_IDLE;
      init_cnt        <= '0;
    end else begin
      case (allocator_phase)
        ALLOC_IDLE: begin
          allocator_phase <= ALLOC_INIT;
          init_cnt        <= init_cnt;
        end
        ALLOC_INIT: begin
          allocator_phase <= init_cnt == DEPTH [A-1:0] ? ALLOC_WORK : allocator_phase;
          init_cnt        <= init_cnt == DEPTH [A-1:0] ? init_cnt : init_cnt + 1'b1;
        end
        ALLOC_WORK: begin
          allocator_phase <= allocator_phase;
          init_cnt        <= init_cnt;
        end
        default: begin
          allocator_phase <= ALLOC_IDLE;
          init_cnt        <= '0;
        end
      endcase
    end
  end

  assign dealloc_ptr [A-1:0] = allocator_phase [0] ? init_cnt : heads [r_vc][A-1:0];
  assign dealloc_ptr [A]     = allocator_phase [0] ? 1'b1     : re & empty_n [r_vc]; 
  assign alloc               = we & free_ptr [A]; 

  logic freemem_full; // Unused but would help to debug

  XFifo #(.DW(A), .DEPTH(DEPTH))
    allocator (.clk (clk), .rstn (rstn),
               .we (dealloc_ptr[A]), .d (dealloc_ptr[A-1:0]),
               .re (alloc), .q (free_ptr[A-1:0]), 
               .full_n (freemem_full), .empty_n (free_ptr[A]));

  assign full_n = free_ptr[A] & allocator_phase [0]; // Full if there is no free space and not in init phase
// ===== }}}

// ===== fifo update after read or write // {{{
  genvar vcid;
  generate
    for (genvar vcid = 0; vcid < VCN; vcid++) begin: vc_id_based_tagged_fifos
      `ifndef SELECT_SRSTn
      always_ff @(posedge clk or negedge rstn) begin
      `else
      always_ff @(posedge clk) begin
      `endif
        if (!rstn) begin
            heads   [vcid]        <= `NULL;
            tails   [vcid]        <= `NULL;
            empty_n [vcid]        <= 1'b0;
            q       [vcid*D +: D] <= '0;
        end else begin
          if (we && (w_vc == vcid[VA-1:0]) && re && (r_vc == vcid[VA-1:0])) begin // reand and write
            heads   [vcid] <= ~empty_n [vcid] ? heads [vcid]                             // If empty
                                              : (heads [vcid] == tails [vcid] ? free_ptr // If only 1 item remaining
                                                                              : mem[ heads[vcid][`PTR] ][`NXT_PTR]); 
            q[vcid*D +: D] <= ~empty_n [vcid] ? d                                 // If empty
                                              : (heads [vcid] == tails [vcid] ? d // If only 1 item remaining
                                                                              : mem[ mem[ heads[vcid][`PTR] ][`NXT_PTR][`PTR] ][`DATA]);
            empty_n [vcid] <= ~empty_n [vcid] ? free_ptr [A]
                                              : (heads [vcid] == tails[vcid] ? free_ptr [A]
                                                                             : empty_n [vcid]);
            tails   [vcid] <= ~empty_n [vcid] ? tails [vcid] : free_ptr;
          end else if (we && (w_vc == vcid [VA-1:0])) begin // write only
            heads   [vcid] <= ~empty_n [vcid] ? free_ptr : heads [vcid];
            q[vcid*D +: D] <= ~empty_n [vcid] ? d            : q [vcid*D +: D];
            empty_n [vcid] <= ~empty_n [vcid] ? free_ptr [A] : empty_n [vcid];
            tails   [vcid] <= free_ptr;
          end else if (re && (r_vc == vcid [VA-1:0])) begin // read only
            heads   [vcid] <= empty_n [vcid] ? mem[ heads[vcid][`PTR] ][`NXT_PTR]             : heads [vcid]; 
            q[vcid*D +: D] <= empty_n [vcid] ? mem[ mem[ heads[vcid][`PTR] ][`NXT_PTR][`PTR] ][`DATA] : q [vcid*D +: D];
            empty_n [vcid] <= empty_n [vcid] ? (heads [vcid] == tails [vcid] ? 1'b0  : empty_n [vcid]) : empty_n [vcid]; 
            tails   [vcid] <=                   heads [vcid] == tails [vcid] ? `NULL : tails [vcid];
          end
        end
      end
    end
  endgenerate
// ===== }}}

// ===== mem_update {{{
genvar mem_idx;
generate
  for (mem_idx = 0; mem_idx < DEPTH; mem_idx++) begin: mem_ele
    `ifndef SELECT_SRSTn
    always_ff @(posedge clk or negedge rstn) begin
    `else
    always_ff @(posedge clk) begin
    `endif
      if (rstn == 1'b0) begin
        mem [mem_idx] <= '0;
      end else begin
        mem [mem_idx] <= we ? (free_ptr == {1'b1, mem_idx [A-1:0]} ? {d, `NULL} 
                                                                   : (mem_idx == tails [w_vc] ? {mem [mem_idx] [`DATA], free_ptr}
                                                                                      : mem [mem_idx] ) ) 
                            : mem [mem_idx];
      end
    end
  end
endgenerate
// ===== }}}

`undef NXT_PTR
`undef PTR
`undef DATA
`undef NULL
endmodule
// EOF
