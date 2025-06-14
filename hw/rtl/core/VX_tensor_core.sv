//`ifdef EXT_T_ENABLE
`include "VX_fpu_define.vh"

module VX_tensor_core import VX_gpu_pkg::*; #(
    parameter FP16
) (
    input clk,
    input reset,

    VX_dispatch_if.slave dispatch_if [`ISSUE_WIDTH],
//`ifdef EXT_T_HOPPER
//    VX_tc_rf_if.master   regfile_if,
//    VX_tc_bus_if.master  smem_A_if,
//    VX_tc_bus_if.master  smem_B_if,
//`endif
    VX_commit_if.master  commit_if [`ISSUE_WIDTH]
);
    localparam BLOCK_SIZE = 1;
    localparam NUM_LANES  = `NUM_THREADS;
    // @perf: PARTIAL_BW==1 increases power instantiating
    // stream_buffers for ISSUE_WIDTH times
    localparam PARTIAL_BW = (BLOCK_SIZE != `ISSUE_WIDTH) || (NUM_LANES != `NUM_THREADS);

    VX_execute_if #(
        .NUM_LANES (NUM_LANES)
    ) execute_if[BLOCK_SIZE]();

    `RESET_RELAY (dispatch_reset, reset);

    VX_dispatch_unit_sane #(
        .BLOCK_SIZE (BLOCK_SIZE),
        .NUM_LANES  (NUM_LANES),
        .OUT_REG    (PARTIAL_BW ? 1 : 0)
    ) dispatch_unit (
        .clk        (clk),
        .reset      (dispatch_reset),
        .dispatch_if(dispatch_if),
        .execute_if (execute_if)
    );

    VX_commit_if #(
        .NUM_LANES (NUM_LANES)
    ) commit_block_if[BLOCK_SIZE]();

    `RESET_RELAY (commit_reset, reset);

    VX_gather_unit #(
        .BLOCK_SIZE (BLOCK_SIZE),
        .NUM_LANES  (NUM_LANES),
        .OUT_BUF    (PARTIAL_BW ? 3 : 0) // FIXME: why 3?
    ) gather_unit (
        .clk           (clk),
        .reset         (commit_reset),
        .commit_in_if  (commit_block_if),
        .commit_out_if (commit_if)
    );

    for (genvar block_idx = 0; block_idx < BLOCK_SIZE; ++block_idx) begin : genblk1
//`ifdef EXT_T_HOPPER
//        VX_tensor_hopper_core_block #(
//            .ISW(1), // FIXME: not block_idx
//            .FP16(FP16)
//        ) tensor_hopper_core_block (
//            .clk        (clk),
//            .reset      (reset),
//            .execute_if (execute_if[block_idx]),
//            .regfile_if (regfile_if),
//            .smem_A_if  (smem_A_if),
//            .smem_B_if  (smem_B_if),
//            .commit_if  (commit_block_if[block_idx])
//        );
        // ) tensor_hopper_core_block (
        //     .clk        (clk),
        //     .reset      (reset),
        //     .execute_if (execute_if[block_idx]),
        //     .smem_A_if  (smem_A_if),
        //     .smem_B_if  (smem_B_if),
        //     .commit_if_haha  (commit_block_if[block_idx])
        // );
//`else
        VX_tensor_core_block #(
            .ISW(1), // FIXME: use block_idx
            .FP16(FP16)
        ) tensor_core (
            .clk(clk),
            .reset(reset),
            .execute_if(execute_if[block_idx]),
            .commit_if(commit_block_if[block_idx])
        );
//`endif
    end
    
endmodule

module VX_tensor_core_block import VX_gpu_pkg::*; #(
    parameter ISW,
    parameter FP16
) (
    input clk,
    input reset,

    VX_execute_if.slave execute_if,
    VX_commit_if.master commit_if
);
    localparam NUM_OCTETS = (`NUM_THREADS / 8);
    // offet in the lane numbers that get mapped to the two threadgroups in an
    // octet. E.g. two tgs map lane 0-3 and lane 16-19 ->
    // LANE_OFFSET_THREADGROUP = 16
    // FIXME: check logic; only verified for single octet
    localparam LANE_OFFSET_THREADGROUP = (4 * NUM_OCTETS);
    // this is only a rule of thumb
    localparam METADATA_QUEUE_DEPTH = 2 * `LATENCY_HMMA;

    `IGNORE_WARNINGS_BEGIN
    wire [1:0] step = 2'(execute_if.data.op_type);
    // op_mod is reused to indicate if instruction is the last substep inside
    // a step (pair of substeps)
    wire last_in_pair = (execute_if.data.op_mod == `INST_MOD_BITS'(1));
    

    wire  [NUM_OCTETS-1:0] octet_results_valid;
    logic [NUM_OCTETS-1:0] octet_results_ready; 
    wire  [NUM_OCTETS-1:0] octet_operands_ready;
   
    // FIXME: should be NUM_LANES?
    wire [`NUM_THREADS-1:0][`XLEN-1:0] wb_data_0;
    wire [`NUM_THREADS-1:0][`XLEN-1:0] wb_data_1;
    wire [`NW_WIDTH-1:0] wb_wid;
    `IGNORE_WARNINGS_END
    // valid signal synced between the functional units (octet) and the
    // metadata queue
    wire operands_valid_synced;

`ifdef EXT_T_ENABLE
    for (genvar i = 0; i < NUM_OCTETS; ++i) begin
`else
    for (genvar i = 0; i < 0; ++i) begin : genblk2
`endif
        // lane-to-octet mapping; see figure 13 of the paper
        wire [7:0][31:0] octet_A = {
            execute_if.data.rs1_data[LANE_OFFSET_THREADGROUP + 4*i +: 4], execute_if.data.rs1_data[4*i +: 4]
        };
        wire [7:0][31:0] octet_B = {
            execute_if.data.rs2_data[LANE_OFFSET_THREADGROUP + 4*i +: 4], execute_if.data.rs2_data[4*i +: 4]
        };
        wire [7:0][31:0] octet_C = {
            execute_if.data.rs3_data[LANE_OFFSET_THREADGROUP + 4*i +: 4], execute_if.data.rs3_data[4*i +: 4]
        };

        wire [3:0][3:0][31:0] octet_D;
        wire result_valid;
        wire result_ready;

        VX_tensor_octet #(
            .ISW(ISW),
            .OCTET(i),
            .FP16(FP16)
        ) octet (
            .clk(clk),
            .reset(reset),

            .A_in(octet_A),
            .B_in(octet_B),
            .C_in(octet_C),
            .operands_valid(operands_valid_synced),
            .operands_wid(execute_if.data.wid),
            .operands_last_in_pair(last_in_pair),
            .operands_step(step),
            .operands_ready(octet_operands_ready[i]),

            .D_out(octet_D),
            .D_wid(wb_wid),
            .result_valid(result_valid),
            .result_ready(result_ready)
        );

        // these should always be in lockstep
        assign octet_results_valid[i] = result_valid;
        assign result_ready = octet_results_ready[i];

        // each octet produces 4x4 output partial sum, but the 8 lanes mapped
        // to the octet can only do 8 fp32 writeback at a time; so we need to
        // split writeback over two cycles
        //
        // octet_D matches the mathematical layout of the matrix (4x4 output
        // per octet).  The logic below replicates the jagged 1x2 mapping in
        // Figure 7(b) to map values to the lanes.
        assign wb_data_0[4*i+0] = octet_D[0][0];
        assign wb_data_0[4*i+1] = octet_D[1][0];
        assign wb_data_0[4*i+2] = octet_D[0][2];
        assign wb_data_0[4*i+3] = octet_D[1][2];

        assign wb_data_1[4*i+0] = octet_D[0][1];
        assign wb_data_1[4*i+1] = octet_D[1][1];
        assign wb_data_1[4*i+2] = octet_D[0][3];
        assign wb_data_1[4*i+3] = octet_D[1][3];

        assign wb_data_0[4*i+LANE_OFFSET_THREADGROUP+0] = octet_D[2][0];
        assign wb_data_0[4*i+LANE_OFFSET_THREADGROUP+1] = octet_D[3][0];
        assign wb_data_0[4*i+LANE_OFFSET_THREADGROUP+2] = octet_D[2][2];
        assign wb_data_0[4*i+LANE_OFFSET_THREADGROUP+3] = octet_D[3][2];

        assign wb_data_1[4*i+LANE_OFFSET_THREADGROUP+0] = octet_D[2][1];
        assign wb_data_1[4*i+LANE_OFFSET_THREADGROUP+1] = octet_D[3][1];
        assign wb_data_1[4*i+LANE_OFFSET_THREADGROUP+2] = octet_D[2][3];
        assign wb_data_1[4*i+LANE_OFFSET_THREADGROUP+3] = octet_D[3][3];
    end
    
    /* commit_if.data_t parts that we need to keep around:
        - uuid
        - wid
        - tmask
        - PC
        - wb
        - rd
    */

    localparam DATAW = `UUID_WIDTH + `NW_WIDTH + `NUM_THREADS + `XLEN + 1 + `NR_BITS;
    
    wire operand_enq_fire = operands_valid_synced && execute_if.ready;
    wire commit_if_ready_override;
    wire commit_if_fire = commit_if.valid && commit_if_ready_override;
    wire [DATAW-1:0] execute_if_data_enq = {
        execute_if.data.uuid, 
        execute_if.data.wid,
        execute_if.data.tmask, 
        execute_if.data.PC, 
        execute_if.data.wb, 
        execute_if.data.rd,
        1'b0 // --> added to fix the warning
        // pid/sop/eop set later
    };

    wire [`NUM_WARPS-1:0][DATAW-1:0] execute_if_data_deq;

    wire [`NUM_WARPS-1:0] metadata_queue_fulls;
    // OR not AND, we don't want any warp full
    wire metadata_queue_full = |(metadata_queue_fulls);

    // need to make sure both metadata and octet issue queues are in sync
    assign operands_valid_synced = execute_if.valid && !metadata_queue_full;
    assign execute_if.ready = (& octet_operands_ready) && !metadata_queue_full;

    for (genvar i = 0; i < `NUM_WARPS; i++) begin : genblk3
        // Metadata queue for commit_if.  This simply copies execute_if's
        // metadata and pops them in conjunction with commit fire.
        //
        // This has to be separated per-warp, as otherwise requests from
        // multiple warps can be enqueued interleaved, which makes it hard to
        // ensure two consecutive dequeues are associated with the same warp for
        // commit. (FIXME: this is not strictly necessary though.)

        wire enq = operand_enq_fire && (execute_if.data.wid == `NW_WIDTH'(i));
        wire deq =   commit_if_fire && (             wb_wid == `NW_WIDTH'(i));

        VX_fifo_queue #(
            .DATAW(DATAW),
            .DEPTH(METADATA_QUEUE_DEPTH)
        ) pending_uops (
            .clk(clk),
            .reset(reset),
            .push(enq),
            .pop(deq),
            .data_in(execute_if_data_enq),
            .data_out(execute_if_data_deq[i]),
            `UNUSED_PIN(empty),
            `UNUSED_PIN(alm_empty),
            .full(metadata_queue_fulls[i]),
            `UNUSED_PIN(alm_full),
            `UNUSED_PIN(size)
        );
    end

    // this shouldn't really happen unless there's a big contention over
    // the commit stage
    `RUNTIME_ASSERT(!(!reset && metadata_queue_full), ("tensor core uop queue is full!"))

    // unlike execute which can be interleaved between warps, commit is
    // serialized and completed one-warp-by-warp, therefore we only need to
    // keep one subcommit state bit unlike for `substeps`
    logic subcommit, subcommit_n;

    wire all_valid = (& octet_results_valid);

// define this to inject artificial commit backpressure for debugging
// `define TENSOR_INJECT_COMMIT_BACKPRESSURE
`ifndef TENSOR_INJECT_COMMIT_BACKPRESSURE
    assign commit_if.valid = all_valid;
    assign commit_if_ready_override = commit_if.ready;
`else
    logic [1:0] counter;
    always @(posedge clk) begin
        if (reset) begin
            counter <= '0;
        end else begin
            if (all_valid) begin
                counter <= counter + 1'b1;
            end
        end
    end

    assign commit_if.valid = all_valid && (counter == 2'b0);
    assign commit_if_ready_override = commit_if.ready && (counter == 2'b0);
`endif

    localparam COMMIT_DATAW = `UUID_WIDTH + `NW_WIDTH + `NUM_THREADS + `XLEN + 1 + `NR_BITS + (`NUM_THREADS * `XLEN) + 1 + 1 + 1 + 1;
    wire [COMMIT_DATAW-1:0] commit_if_data = {
        execute_if_data_deq[wb_wid], /* uuid ~ rd */
        subcommit == 1'b0 ? wb_data_0 : wb_data_1, /* data */
        1'b0, /* tensor */
        1'b0, /* pid */
        1'b1, /* sop */
        1'b1  /* eop */
    };

    assign commit_if.data = commit_if_data;

    always @(*) begin
        subcommit_n = commit_if_fire ? ~subcommit : subcommit;
        if (commit_if_fire && subcommit == 1'b1) begin
            octet_results_ready = '1;
        end
        else begin
            octet_results_ready = '0;
        end  
    end

    VX_tensor_reg #(
        .DATAW(1)
    ) staging_subcommit (
        .clk(clk),
        .reset(reset),
        .d(subcommit_n),
        .en(1'b1),
        .q(subcommit)
    );
endmodule

module VX_tensor_reg #(
    parameter DATAW
) (
    input  clk,
    input  reset,
    input  [DATAW-1:0] d,
    input          en,
    output [DATAW-1:0] q
);
    logic [DATAW-1:0] data;

    always @(posedge clk) begin
        if (reset) begin
            data <= '0;
        end else begin
            if (en) begin
                data <= d;
            end
        end
    end

    assign q = data;
endmodule

module VX_tensor_octet #(
    parameter ISW,
    parameter OCTET,
    parameter FP16,
    parameter RESULT_BUFFER_DEPTH = 2
) (
    input clk,
    input reset,

    input [7:0][31:0]     A_in,
    input [7:0][31:0]     B_in,
    input [7:0][31:0]     C_in,
    input                 operands_valid,
    input [`NW_WIDTH-1:0] operands_wid,
    input                 operands_last_in_pair,
    input [1:0]           operands_step,
    // we have to backpressure due to there potentially being contention over commit
    output                operands_ready,

    output [3:0][3:0][31:0] D_out,
    output [`NW_WIDTH-1:0]  D_wid,
    output result_valid,
    input result_ready
);
    // 512 bits/octet * 4 octets per warp
    logic [`NUM_WARPS-1:0][3:0][31:0] A_buffer, A_buffer_n;
    logic [`NUM_WARPS-1:0][3:0][31:0] B_buffer, B_buffer_n;
    logic [`NUM_WARPS-1:0][7:0][31:0] C_buffer, C_buffer_n;

    // half the inputs are buffered, half are not (instead coming straight
    // from operand bus) unlike the real tensor core.
    // the banks are only 32 bit rather than 64 bit (a pair of fp32 regs).
    logic [3:0][31:0] A_half;
    logic [3:0][31:0] B_half;
    logic [7:0][31:0] C_half;
    logic [3:0][31:0] A_half_buf;
    logic [3:0][31:0] B_half_buf;
    logic [7:0][31:0] C_half_buf;

    logic [`NUM_WARPS-1:0] substeps;
    logic [`NUM_WARPS-1:0] substeps_n;

    wire [7:0][31:0]     A_in_buf;
    wire [7:0][31:0]     B_in_buf;
    wire [7:0][31:0]     C_in_buf;
    wire                 operands_valid_buf;
    wire                 operands_ready_buf;
    wire [`NW_WIDTH-1:0] operands_wid_buf;
    wire                 operands_last_in_pair_buf;
    wire [1:0]           operands_step_buf;

    assign A_in_buf = A_in;
    assign B_in_buf = B_in;
    assign C_in_buf = C_in;
    // TODO: merge *_buf/*
    assign operands_step_buf         = operands_step;
    assign operands_wid_buf          = operands_wid;
    assign operands_last_in_pair_buf = operands_last_in_pair;
    assign operands_valid_buf = operands_valid;
    assign operands_ready = operands_ready_buf;

    typedef struct {
      // single column of A
      logic [3:0][31:0] A_half;
      // single row of B
      logic [3:0][31:0] B_half;
      // interleaved elements of C
      logic [7:0][31:0] C_half;
    } half_t;

    function half_t get_operand_half(
      input logic [1:0] step,
      input logic [7:0][31:0] A_inside,
      input logic [7:0][31:0] B_inside,
      input logic [7:0][31:0] C_inside
    );
        half_t half;
        // note that not all lanes participate at every step
        case (step)
            2'b00: begin
                // Two A_in segments correspond to two 2x2 subtiles of A read
                // by two threadgroups: [0:2,0:2] and [4:6,0:2] in Step 0 of
                // Figure 10(b).  B_in OTOH is shared by two threadgroups.
                // Note k-dimension is shrunk from 4 to 2.
                half.A_half = { A_inside[5:4], A_inside[1:0] };
                half.B_half = B_inside[3:0];
            end
            2'b01: begin
                half.A_half = { A_inside[7:6], A_inside[3:2] };
                half.B_half = B_inside[3:0];
            end
            2'b10: begin
                half.A_half = { A_inside[5:4], A_inside[1:0] };
                half.B_half = B_inside[7:4];
            end
            2'b11: begin
                half.A_half = { A_inside[7:6], A_inside[3:2] };
                half.B_half = B_inside[7:4];
            end
        endcase
        half.C_half = C_inside;
        return half;
    endfunction

    half_t halves;
    assign halves = get_operand_half(operands_step_buf, A_in_buf, B_in_buf, C_in_buf);

    wire do_hmma = operands_ready_buf && operands_valid_buf && operands_last_in_pair_buf;
    // wire operands_first_in_pair_fire = operands_ready && operands_valid && (!operands_last_in_pair);
    wire operands_first_in_pair_fire = operands_ready_buf && operands_valid_buf && (!operands_last_in_pair_buf);

    // Staging buffer for the A/B/C half-tiles that will later be assembled
    // with the other half tiles coming in on the input ports.
    VX_tensor_reg #(
        .DATAW($bits(A_buffer) + $bits(B_buffer) + $bits(C_buffer))
    ) staging_abc (
        .clk(clk),
        .reset(reset),
        .d({A_buffer_n, B_buffer_n, C_buffer_n}),
        .en(1'b1),
        .q({A_buffer,   B_buffer,   C_buffer})
    );

    always @(*) begin
        A_buffer_n = A_buffer;
        B_buffer_n = B_buffer;
        C_buffer_n = C_buffer;
        substeps_n = substeps;
        
        if (operands_first_in_pair_fire) begin
          // NOTE: substeps is only used for debugging
          substeps_n[operands_wid_buf] = 1'b1; // ready for hmma
          A_buffer_n[operands_wid_buf] = halves.A_half;
          B_buffer_n[operands_wid_buf] = halves.B_half;
          C_buffer_n[operands_wid_buf] = halves.C_half;
        end
        if (do_hmma) begin
          substeps_n[operands_wid_buf] = 1'b0; // finished hmma, ready for next operand
        end
    end

    VX_tensor_reg #(
        .DATAW($bits(substeps))
    ) staging_substeps (
        .clk(clk),
        .reset(reset),
        .d(substeps_n),
        .en(1'b1),
        .q(substeps)
    );

    wire outbuf_ready_in;
    wire hmma_ready;
    assign operands_ready_buf = hmma_ready;

    // all *_tiles below are row-major
    // A is a 4x2 fp32 matrix; row 0-2 for one threadgroup, row 4-6 for the
    // other. The two columns (along k) are shared between the threadgroups.
    // Buffered data are combined with the current data along the K dimension.
    // See figure 10(b).
    wire [3:0][1:0][31:0] A_tile = {
        { halves.A_half[3], A_buffer[operands_wid_buf][3] },
        { halves.A_half[2], A_buffer[operands_wid_buf][2] },
        { halves.A_half[1], A_buffer[operands_wid_buf][1] },
        { halves.A_half[0], A_buffer[operands_wid_buf][0] }
    };
    // B is a 2x4 fp32 matrix, shared between the two threadgroups.
    // The two rows (along k) are combined between buffered and current data.
    wire [1:0][3:0][31:0] B_tile = {
        halves.B_half,
        B_buffer[operands_wid_buf]
    };
    // C is a 4x4 fp32 matrix; row 0-2 for one threadgroup, row 4-6 for the
    // other
    logic [3:0][3:0][31:0] C_tile;
    wire  [3:0][3:0][31:0] D_tile;
    wire  [`NW_WIDTH-1:0]  D_wid_dpu;
    
    // C follows the 1x2 "jagged" mapping in Figure 7(b).
    // Buffered data are combined with the current data along the rows,
    // forming an 1x2 block for each lane.
    always @(*) begin
        C_tile[3] = { halves.C_half[7], C_buffer[operands_wid_buf][7], halves.C_half[5], C_buffer[operands_wid_buf][5] };
        C_tile[2] = { halves.C_half[6], C_buffer[operands_wid_buf][6], halves.C_half[4], C_buffer[operands_wid_buf][4] };
        C_tile[1] = { halves.C_half[3], C_buffer[operands_wid_buf][3], halves.C_half[1], C_buffer[operands_wid_buf][1] };
        C_tile[0] = { halves.C_half[2], C_buffer[operands_wid_buf][2], halves.C_half[0], C_buffer[operands_wid_buf][0] };
    end 

    wire dpu_valid;

    // this does (m,n,k)=(4,4,2) matmul, modeling compute of a single octet
    VX_tensor_threadgroups #(
        .ISW(ISW),
        .OCTET(OCTET),
        .FP16(FP16),
        .OPERAND_BUFFER_DEPTH(4 /*@perf: arbtirary*/)
    ) dpu (
        .clk(clk),
        .reset(reset),

        .valid_in(do_hmma),
        .ready_in(hmma_ready),
        .A_tile(A_tile),
        .B_tile(B_tile),
        .C_tile(C_tile),
        .wid(operands_wid_buf),

        .valid_out(dpu_valid),
        .ready_out(outbuf_ready_in),
        .D_tile(D_tile),
        .D_wid(D_wid_dpu)
    );

    if (RESULT_BUFFER_DEPTH > 0) begin : genblk4
        wire outbuf_empty;
        wire outbuf_full;
        // backpressure from commit
        assign outbuf_ready_in = ~outbuf_full;
        assign result_valid    = ~outbuf_empty;

        wire outbuf_enq = outbuf_ready_in && dpu_valid;
        wire outbuf_deq = result_valid && result_ready;

        // Result buffer that stages the D tile for 2 cycles until
        // commit/writeback is complete.  This decouples the irregular dpu
        // output traffic from the regular, every-2-cycle commit traffic to
        // ensure the commit pipeline is used more efficiently.
        //
        // @perf: RESULT_BUFFER_DEPTH == 2 gives good performance by
        // completely dampening commit backpressure (result_ready).
        // RESULT_BUFFER_DEPTH = 0 removes the fifo queue altogether.
        VX_fifo_queue #(
            .DATAW   ($bits(D_wid) + $bits(D_out)),
            .DEPTH   (RESULT_BUFFER_DEPTH) // 2 works good
        ) output_buffer (
            .clk   (clk),
            .reset (reset),
            .push      (outbuf_enq),
            .pop       (outbuf_deq),
            .data_in   ({D_wid_dpu, D_tile}),
            .data_out  ({D_wid,     D_out}),
            .empty     (outbuf_empty),
            `UNUSED_PIN(alm_empty),
            .full      (outbuf_full), // should be impossible to overflow
            `UNUSED_PIN(alm_full),
            `UNUSED_PIN(size)
        );

        // for perf debug
        // `RUNTIME_ASSERT(reset || !outbuf_full, ("dpu result queue is full!"))
    end else begin : genblk5
        // XXX: this depends on the assumption that commit stage only asserts
        // result_ready when result_valid is true
        assign outbuf_ready_in = !result_valid || result_ready;
        assign result_valid = dpu_valid;

        // make direct connections
        assign D_wid = D_wid_dpu;
        assign D_out = D_tile;
    end

`ifdef PERF_ENABLE
    logic [`PERF_CTR_BITS-1:0] perf_tensor_ops_total;

    always @(posedge clk) begin
        if (reset) begin
            perf_tensor_ops_total <= '0;
        end else begin
            if (do_hmma) begin
                perf_tensor_ops_total <= perf_tensor_ops_total + 2'd2;
            end
        end
    end
`endif
endmodule
//`endif
