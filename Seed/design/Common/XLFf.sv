// HMTH (c)
// Linked-list based fifo with multiple output port.
// DEPTH must be power of 2

module XLFf # (parameter VCN = 4, parameter D = 11, parameter DEPTH = 16)
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

  logic [A:0] tails     [0:VCN-1];
  logic [A:0] heads     [0:VCN-1];
  
  logic [A:0] dealloc_ptr; // MSB = 0 => invalid = not dealloc this space
  logic [A:0] free_ptr;    // MSB = 0 => invalid = no free space
  logic       alloc;
  logic [A:0] num_free_spaces;

// =====  Allocator to alloc/dealloc free mem to store data {{{
  assign dealloc_ptr [A-1:0] = heads [r_vc][A-1:0];
  assign dealloc_ptr [A]     = re & empty_n [r_vc]; 
  assign alloc               = we & free_ptr [A]; 

  logic freemem_full_n, freemem_empty_n;
  logic [A-1:0] alloc_buf [0:DEPTH-1];
  logic [A-1:0] alloc_buf_wptr, alloc_buf_rptr;
  logic alloc_buf_we;

  integer alloc_idx;

  XCC #(.LENGTH(DEPTH), .INIT_FULL(1))
  	AllocCtrl (.clk(clk), .rstn(rstn), .we(dealloc_ptr[A]), .re(alloc), .full_n(freemem_full_n), .empty_n(freemem_empty_n),
  				.we_ok(alloc_buf_we), .wptr(alloc_buf_wptr), .rptr(alloc_buf_rptr), .length(num_free_spaces));

  `ifndef SELECT_SRSTn
  always_ff @(posedge clk or negedge rstn) begin
  `else
  always_ff @(posedge clk) begin
  `endif
    if (~rstn)
      for (alloc_idx = 0; alloc_idx < DEPTH; alloc_idx++)
        alloc_buf [alloc_idx] <= alloc_idx [A-1:0];
    else
      if (alloc_buf_we)
        alloc_buf [alloc_buf_wptr] <= dealloc_ptr [A-1:0]; 
  end

  assign free_ptr [A] = freemem_empty_n;
  assign free_ptr [A-1:0] = alloc_buf [alloc_buf_rptr];
  assign full_n = free_ptr[A]; // Full if there is no free space or in init phase
// ===== }}}

// ===== fifo update on read or write // {{{
  logic [E-1:0] mem     [0:DEPTH-1];
  
  genvar vcid;
  logic [VCN-1:0] we_ok, re_ok;
  generate
    for (vcid = 0; vcid < VCN; vcid++) begin: vc_id_based_tagged_fifos
      assign we_ok [vcid] = we & (w_vc == vcid[VA-1:0]) & full_n;
      assign re_ok [vcid] = re & (r_vc == vcid[VA-1:0]) & empty_n [vcid];

      `ifndef SELECT_SRSTn
      always_ff @(posedge clk or negedge rstn) begin
      `else
      always_ff @(posedge clk) begin
      `endif
        if (!rstn) begin
            heads   [vcid]        <= '0;
            tails   [vcid]        <= '0;
            empty_n [vcid]        <= 1'b0;
            q       [vcid*D +: D] <= '0;
        end else begin
          if (we_ok [vcid] && re_ok [vcid]) begin // read and write
            heads   [vcid] <= heads [vcid] == tails [vcid] ? free_ptr // If there is only 1 item
                                                           : mem[ heads[vcid][A-1:0] ][A:0]; 
            q[vcid*D +: D] <= heads [vcid] == tails [vcid] ? d // If there is only 1 item
                                                           : mem[ mem[ heads[vcid][A-1:0] ][A-1:0] ][A+1 +: D];
            empty_n [vcid] <= empty_n [vcid];
            tails   [vcid] <= free_ptr;
          end else if (we_ok [vcid]) begin // write only
            heads   [vcid] <= ~empty_n [vcid] ? free_ptr     : heads [vcid];
            q[vcid*D +: D] <= ~empty_n [vcid] ? d            : q [vcid*D +: D];
            empty_n [vcid] <= ~empty_n [vcid] ? free_ptr [A] : empty_n [vcid];
            tails   [vcid] <= free_ptr;
          end else if (re_ok [vcid]) begin // read only
            heads   [vcid] <= mem[ heads[vcid][A-1:0] ][A:0]; 
            q[vcid*D +: D] <= mem[ mem[ heads[vcid][A-1:0] ][A-1:0] ][A+1 +: D];
            empty_n [vcid] <= heads [vcid] == tails [vcid] ? 1'b0  : empty_n [vcid]; 
            tails   [vcid] <= heads [vcid] == tails [vcid] ? '0 : tails [vcid];
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
        mem [mem_idx] <= we ? (free_ptr == {1'b1, mem_idx [A-1:0]} ? {d, {(A+1){1'b0}} } 
                                                                   : (tails [w_vc] == {1'b1, mem_idx [A-1:0]} ? {mem [mem_idx] [A+1 +: D], free_ptr}
                                                                                                              : mem [mem_idx] ) ) 
                            : mem [mem_idx];
      end
    end
  end
endgenerate
// ===== }}}

`ifndef SYNTHESIS // {{{
`ifdef FORMAL
logic f_last_clk = 1'b0;

initial restrict property (~rstn);

always @($global_clock) begin
  restrict property (clk == !f_last_clk);
  f_last_clk <= clk;
  if ($rose(rstn)) assume ($rose(clk));
  if (!$rose(clk)) begin
    assume ($stable(rstn));
    assume ($stable(we));
    assume ($stable(w_vc));
    assume ($stable(d));
    assume ($stable(re));
    assume ($stable(r_vc));
  end
  cover (rstn);
end
`endif

integer k;
initial begin
  for (k = 0; k < DEPTH; k++)
    assert (alloc_buf [k] == k);
end

// Validating FIFO's behaviors
logic [A:0] vc_cnt [0:VCN-1];
genvar vc_gen_chk;
generate
  for (vc_gen_chk = 0; vc_gen_chk < VCN; vc_gen_chk++) begin: vc_cnt_gen
    always @(posedge clk or negedge rstn) begin
      if (~rstn) vc_cnt [vc_gen_chk] <= '0;
      else vc_cnt [vc_gen_chk] <= vc_cnt[vc_gen_chk] + we_ok[vc_gen_chk] - re_ok[vc_gen_chk];
    end
  end
endgenerate

integer cnt_idx, total_cnt;
always @(*) begin
  total_cnt = 0;
  for (cnt_idx = 0; cnt_idx < VCN; cnt_idx++)
    total_cnt += vc_cnt [cnt_idx];
end

genvar i, j;
generate
  for (i = 0; i < VCN; i++) begin: loop_0
    always @(posedge clk) begin
      if (freemem_full_n == 1'b0)  assert (~(heads[i][A] | tails[i][A]));        // if no buffer allocated, all heads and tails must be NULL
      assert (empty_n[i] ~^ heads[i][A]);                                        // if empty, its head and tail must be NULL and vice versa
      assert (tails[i][A] ~^ heads[i][A]);                                       // tail and head must be available together
      if (tails[i][A]) assert (mem[tails[i][A-1:0]][A] == 1'b0);                 // tail must point nxt_ptr to NULL
      if (heads[i][A]) assert (mem[heads[i][A-1:0]][A:0] != heads[i]);           // must not point nxt_ptr to itself
      assert ((empty_n[i] & (vc_cnt[i] > 0)) | (~empty_n[i] & (vc_cnt[i]==0)));  // check empty condition,
      assert ((vc_cnt[i]==1) ~^ (heads[i][A] & (heads[i]==tails[i])));
    end
    for (j = i + 1; j < VCN; j++) begin: loop_1
      always @(posedge clk) begin
        assert (~heads[i][A] | (heads[i] != free_ptr));                    // heads and free_ptr must be exclusive
        assert (~heads[i][A] | (heads[i] != heads[j]));                    // heads must be exclusive 
        assert (~heads[i][A] | (heads[i] != tails[j]));                    // head and other tails must be exclusive 
        assert (~tails[i][A] | (tails[i] != free_ptr));                    // tails and free_ptr must be exclusive
        assert (~tails[i][A] | (tails[i] != heads[j]));                    // tails must be exclusive 
        assert (~tails[i][A] | (tails[i] != tails[j]));                    // tail and other heads must be exclusive 
      end
    end
  end
endgenerate

// Validate allocator's behaviors 
always @(posedge clk) begin
  assert (total_cnt + num_free_spaces == DEPTH);
  assert ((total_cnt >= 0) && (total_cnt <= DEPTH));
  assert ((~full_n & (total_cnt == DEPTH)) | (full_n & (total_cnt < DEPTH)));
  assert ((~(|empty_n) & (total_cnt == 0)) | ((|empty_n) & (total_cnt > 0)));
end

`endif // }}}

endmodule
// EOF
