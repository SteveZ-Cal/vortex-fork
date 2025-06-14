//`ifdef EXT_T_ENABLE
`include "VX_fpu_define.vh"

module VX_tensor_hopper_core_block import VX_gpu_pkg::*; #(
    parameter ISW,
    parameter FP16
) (
    input clk,
    input reset,

    VX_execute_if.slave execute_if,
    VX_tc_rf_if.master  regfile_if,
    VX_tc_bus_if.master smem_A_if,
    VX_tc_bus_if.master smem_B_if,
    VX_commit_if.master commit_if
);
    localparam NUM_LANES = `NUM_THREADS;
    localparam METADATA_QUEUE_DEPTH = 2; // FIXME: arbitrary

    /* commit_if.data_t parts that we need to keep around:
        - uuid
        - wid
        - tmask
        - PC
        - wb
        - rd
    */
    wire [`UUID_WIDTH-1:0]          execute_if_data_uuid;
    wire [`NW_WIDTH-1:0]            execute_if_data_wid;
    wire [NUM_LANES-1:0]            execute_if_data_tmask;
    wire [`INST_ALU_BITS-1:0]       execute_if_data_op_type;
    wire [`XLEN-1:0]                execute_if_data_PC;
    wire                            execute_if_data_wb;
    wire [`NR_BITS-1:0]             execute_if_data_rd;
    wire [NUM_LANES-1:0][`XLEN-1:0] execute_if_data_rs1;
    wire [NUM_LANES-1:0][`XLEN-1:0] execute_if_data_rs2;

    wire metadata_queue_full;
    wire metadata_queue_empty;
    // OR not AND; we don't want any warp to be full
    assign execute_if.ready = !metadata_queue_full;

    logic metadata_deq;

    // Metadata queue for commit_if.  This simply copies execute_if's
    // metadata and pops them in conjunction with commit fire.
    //
    // Note both HGMMA and HGMMA_WAIT will be enqueued here, interleaved
    // between different warps.  There is a slight chance that an HGMMA_WAIT
    // might be blocked from commit when there are multiple different-warp
    // HGMMAs blocking the dequeue end, so keep an eye on those cases.

    wire operand_enq_fire = execute_if.valid && execute_if.ready;
    wire enq = operand_enq_fire;
    wire deq = metadata_deq;

    localparam DATAW = `UUID_WIDTH + `NW_WIDTH + `NUM_THREADS + `INST_ALU_BITS + `XLEN + 1 +
                       `NR_BITS + (NUM_LANES * `XLEN) + (NUM_LANES * `XLEN);
    VX_fifo_queue #(
        .DATAW(DATAW),
        .DEPTH(METADATA_QUEUE_DEPTH)
    ) pending_uops (
        .clk(clk),
        .reset(reset),
        .push(enq),
        .pop(deq),
        .data_in({execute_if.data.uuid,  execute_if.data.wid,
                  execute_if.data.tmask, execute_if.data.op_type, execute_if.data.PC,
                  execute_if.data.wb,    execute_if.data.rd,
                  execute_if.data.rs1_data,   execute_if.data.rs2_data}),
        .data_out({execute_if_data_uuid,  execute_if_data_wid,
                   execute_if_data_tmask, execute_if_data_op_type, execute_if_data_PC,
                   execute_if_data_wb,    execute_if_data_rd,
                   execute_if_data_rs1,   execute_if_data_rs2}),
        .empty(metadata_queue_empty),
        `UNUSED_PIN(alm_empty),
        .full(metadata_queue_full),
        `UNUSED_PIN(alm_full),
        `UNUSED_PIN(size)
    );

    // NOTE: this is not an error but tells us if backend doesn't keep up with
    // HGMMA calls from the kernel
    // `RUNTIME_ASSERT(!(!reset && metadata_queue_full), ("tensor core uop queue is full!"))

    wire initiate_ready;
    wire writeback_valid;
    wire writeback_last;
    wire [`NW_WIDTH-1:0] writeback_wid;
    wire [4:0] writeback_rd; // tensor writeback IO has 0~31 rd
    logic writeback_ready;
    wire [`NUM_THREADS-1:0][`XLEN-1:0] writeback_data;

    wire metadata_valid = !metadata_queue_empty;
    wire hmma_wait = metadata_valid &&
                     (execute_if_data_op_type == `INST_TENSOR_HGMMA_WAIT);
    // skip HGMMA_WAIT for kickoff
    // make sure to consider commit_if.ready to keep initiate in sync with
    // commit
    wire initiate_valid = metadata_valid && commit_if.ready && !hmma_wait;
    wire [`NW_WIDTH-1:0] initiate_wid = execute_if_data_wid;
    wire [`XLEN-1:0] initiate_addr_a = execute_if_data_rs1[0];
    wire [`XLEN-1:0] initiate_addr_b = execute_if_data_rs2[0];
    `RUNTIME_ASSERT(!metadata_valid || execute_if_data_tmask[0],
        ("tmask for HGMMA instruction is invalid"))

    // we're recycling execute_if.op_type as operands_if.op_type which might
    // have a different width; let's be safe
    `STATIC_ASSERT((`INST_ALU_BITS == `INST_OP_BITS),
        ("static assertion failed: `INST_ALU_BITS != `INST_OP_BITS"))

    `STATIC_ASSERT((`NUM_THREADS == 8),
        ("static assertion failed: tensor_hopper_core only supports NUM_THREADS == 8"))
    `STATIC_ASSERT((`XLEN == 32),
        ("static assertion failed: tensor_hopper_core only supports XLEN == 32"))

    // /*
    // fake fsm driving tc rf port
    // reg [11:0] counter;
    // always @(posedge clk) begin
    //     if (reset) begin
    //         counter <= 12'd1;
    //     end else begin
    //         counter <= counter + 12'd1;
    //     end
    // end
    // assign regfile_if.req_valid = (counter[6:0] == 7'd0);
    // assign regfile_if.req_data.wis = '0;
    // assign regfile_if.req_data.rs = counter[11:7];
    // */

    TensorCoreDecoupled tensor_hopper_core (
        .clock(clk),
        .reset(reset),

        .io_initiate_ready(initiate_ready),
        .io_initiate_valid(initiate_valid),
        .io_initiate_bits_wid(initiate_wid),
        .io_initiate_bits_addressA(initiate_addr_a),
        .io_initiate_bits_addressB(initiate_addr_b),

        .io_writeback_ready(writeback_ready),
        .io_writeback_valid(writeback_valid),
        .io_writeback_bits_last(writeback_last),
        .io_writeback_bits_wid(writeback_wid),
        .io_writeback_bits_rd(writeback_rd),
        .io_writeback_bits_data_0(writeback_data[0]),
        .io_writeback_bits_data_1(writeback_data[1]),
        .io_writeback_bits_data_2(writeback_data[2]),
        .io_writeback_bits_data_3(writeback_data[3]),
        .io_writeback_bits_data_4(writeback_data[4]),
        .io_writeback_bits_data_5(writeback_data[5]),
        .io_writeback_bits_data_6(writeback_data[6]),
        .io_writeback_bits_data_7(writeback_data[7]),

        .io_respA_ready(smem_A_if.rsp_ready),
        .io_respA_valid(smem_A_if.rsp_valid),
        .io_respA_bits_source(smem_A_if.rsp_data.tag),
        .io_respA_bits_data(smem_A_if.rsp_data.data),
        .io_respB_ready(smem_B_if.rsp_ready),
        .io_respB_valid(smem_B_if.rsp_valid),
        .io_respB_bits_source(smem_B_if.rsp_data.tag),
        .io_respB_bits_data(smem_B_if.rsp_data.data),
        .io_respC(regfile_if.rsp_data.data),

        .io_reqA_ready(smem_A_if.req_ready),
        .io_reqA_valid(smem_A_if.req_valid),
        .io_reqA_bits_source(smem_A_if.req_data.tag),
        .io_reqA_bits_address(smem_A_if.req_data.addr),
        .io_reqB_ready(smem_B_if.req_ready),
        .io_reqB_valid(smem_B_if.req_valid),
        .io_reqB_bits_source(smem_B_if.req_data.tag),
        .io_reqB_bits_address(smem_B_if.req_data.addr),
        .io_reqC_valid(regfile_if.req_valid),
        .io_reqC_bits(regfile_if.req_data.rs[4:0])
    );
    // add offset of 32 for fp regs
    assign regfile_if.req_data.rs[5] = 1'b1;
    assign regfile_if.req_data.wis = '0;
    `STATIC_ASSERT((`ISSUE_WIDTH == `NUM_WARPS),
        ("static assertion failed: tensor_hopper_core assumes ISSUE_WIDTH == NUM_WARPS"))

    // VX_tensor_hopper_core #(
    // ) tensor_hopper_core (
    //     .clk(clk),
    //     .reset(reset),

    //     .initiate_valid(initiate_valid),
    //     .initiate_wid(`NW_WIDTH'(0)/*FIXME*/),
    //     .initiate_ready(initiate_ready),

    //     .writeback_valid(writeback_valid),
    //     `UNUSED_PIN(writeback_wid),
    //     .writeback_last(writeback_last),
    //     .writeback_ready(writeback_ready)
    // );

    logic commit_select_tensor;

    always @(*) begin
        metadata_deq = 1'b0;

        // 1'b0: commit from metadata queue
        // 1'b1: commit from tensor core writeback output
        commit_select_tensor = 1'b0;

        writeback_ready = commit_if.ready;

        // if there's something in the meta queue, give it priority for commit
        // to keep asynchrony of HGMMA instructions.  note HGMMA's should be
        // stalled if the tensor core is already busy.
        if (metadata_valid) begin
            if (hmma_wait) begin
                // block tensor core writeback
                writeback_ready = 1'b0;

                // commit HGMMA_WAIT regardless of tensor core busy
                commit_select_tensor = 1'b0;
                metadata_deq = metadata_valid && commit_if.ready;
            end else begin
                // hold commit and meta dequeue until tensor core is ready.
                // This will stall newer HGMMAs when tensor core is already
                // busy with an older one.
                commit_select_tensor = !initiate_ready;
                metadata_deq = metadata_valid && commit_if.ready && initiate_ready;
            end
        end else begin
            commit_select_tensor = 1'b1;
        end

        if (commit_select_tensor) begin
            commit_if.valid       = writeback_valid;
            commit_if.data.uuid   = '0;
            commit_if.data.wid    = writeback_wid;
            commit_if.data.tmask  = {NUM_LANES{1'b1}};
            commit_if.data.PC     = '0;
            commit_if.data.wb     = 1'b1;
            // writeback_rd is 0-based
            commit_if.data.rd     = (`NR_BITS'(`NUM_IREGS) + {1'b0, writeback_rd});
            commit_if.data.data   = writeback_data;
            // mark as "ghost" commit.  This will prevent this commit from
            // decrementing from pending_instr buffer
            commit_if.data.tensor = 1'b1;
            // only the last ghost commit has eop set, which will trigger
            // scoreboard to clear out the busy bit.
            commit_if.data.eop    = writeback_last;
        end else begin
            commit_if.valid       = metadata_valid;
            commit_if.data.uuid   = execute_if_data_uuid;
            commit_if.data.wid    = execute_if_data_wid;
            commit_if.data.tmask  = execute_if_data_tmask;
            commit_if.data.PC     = execute_if_data_PC;
            commit_if.data.wb     = execute_if_data_wb;
            commit_if.data.rd     = execute_if_data_rd;
            commit_if.data.data   = '0; // can be arbitrary as rd is zero
            commit_if.data.tensor = 1'b0;
            commit_if.data.pid    = 1'b0;
            commit_if.data.sop    = 1'b1;
            commit_if.data.eop    = 1'b1;
        end
    end

endmodule


// TODO: replace this with a Chisel module
module VX_tensor_hopper_core #(
) (
    input clk,
    input reset,

    input                 initiate_valid,
    input [`NW_WIDTH-1:0] initiate_wid,
    output                initiate_ready,

    output                 writeback_valid,
    output [`NW_WIDTH-1:0] writeback_wid,
    // indicates if this is the last writeback for the given wid, in which
    // case the original HGMMA instruction should be signalled retired
    output                 writeback_last,
    input                  writeback_ready
);
    // dummy FSM that generates commits
    localparam STATE_IDLE = 4'd0;
    localparam STATE_FINISH = 4'd15;
    logic [3:0] state, state_n;

    assign initiate_ready = (state == STATE_IDLE);

    always @(*) begin
        state_n = state;

        case (state)
            STATE_IDLE: begin
                state_n = state;
            end
            STATE_FINISH: begin
                // hold until writeback_ready
                if (writeback_ready) begin
                    state_n = STATE_IDLE;
                end
            end
            default: begin
                state_n = state + 4'd1;
            end
        endcase

        // kick-off
        if (initiate_valid && initiate_ready) begin
            state_n = 4'd1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= '0;
        end else begin
            state <= state_n;
        end
    end

    assign writeback_valid = (state != STATE_IDLE);
    assign writeback_wid = '0; // TODO
    assign writeback_last = (state == STATE_FINISH);

endmodule

//`endif