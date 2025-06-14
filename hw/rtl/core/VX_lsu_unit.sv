// Copyright © 2019-2023
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`include "VX_define.vh"

module VX_lsu_unit import VX_gpu_pkg::*; #(
    parameter `STRING INSTANCE_ID = ""
) (
    `SCOPE_IO_DECL

    input wire              clk,
    input wire              reset,
    input wire              downstream_mem_busy,

    // Inputs
    VX_dispatch_if.slave    dispatch_if [`ISSUE_WIDTH],

    // Outputs
    VX_commit_if.master     commit_if [`ISSUE_WIDTH],
    VX_lsu_mem_if.master    lsu_mem_if [`NUM_LSU_BLOCKS]
);
    localparam BLOCK_SIZE = `NUM_LSU_BLOCKS;
    localparam NUM_LANES  = `NUM_LSU_LANES;

    //localparam BLOCK_SIZE   = 1;
    //localparam NUM_LANES    = `NUM_LSU_LANES;
    localparam PID_BITS     = `CLOG2(`NUM_THREADS / NUM_LANES);
    localparam PID_WIDTH    = `UP(PID_BITS);
    //localparam RSP_ARB_DATAW= `UUID_WIDTH + `NW_WIDTH + NUM_LANES + `XLEN + `NR_BITS + 1 + NUM_LANES * `XLEN + 1 + PID_WIDTH + 1 + 1;
    localparam LSUQ_SIZEW   = `LOG2UP(`LSUQ_SIZE);
    //localparam MEM_ASHIFT   = `CLOG2(`MEM_BLOCK_SIZE);    
    //localparam MEM_ADDRW    = `XLEN - MEM_ASHIFT;
    localparam REQ_ASHIFT   = `CLOG2(DCACHE_WORD_SIZE);
    //localparam CACHE_TAG_WIDTH = `UUID_WIDTH + NUM_LANES * `CACHE_ADDR_TYPE_BITS  + LSUQ_TAG_BITS;

    `SCOPE_IO_SWITCH (BLOCK_SIZE);

    VX_execute_if #(
        .NUM_LANES (NUM_LANES)
    ) per_block_execute_if[BLOCK_SIZE]();

    VX_dispatch_unit #(
        .BLOCK_SIZE (BLOCK_SIZE),
        .NUM_LANES  (NUM_LANES),
        .OUT_BUF    (3)
    ) dispatch_unit (
        .clk        (clk),
        .reset      (reset),
        .dispatch_if(dispatch_if),
        .execute_if (per_block_execute_if)
    );

    VX_commit_if #(
        .NUM_LANES (NUM_LANES)
    ) per_block_commit_if[BLOCK_SIZE]();

    for (genvar block_idx = 0; block_idx < BLOCK_SIZE; ++block_idx) begin : g_slices
        VX_lsu_slice #(
            .INSTANCE_ID (`SFORMATF(("%s%0d", INSTANCE_ID, block_idx)))
        ) lsu_slice(
            `SCOPE_IO_BIND  (block_idx)
            .clk        (clk),
            .reset      (reset),
            .execute_if (per_block_execute_if[block_idx]),
            .commit_if  (per_block_commit_if[block_idx]),
            .lsu_mem_if (lsu_mem_if[block_idx])
        );
    end

    VX_gather_unit #(
        .BLOCK_SIZE (BLOCK_SIZE),
        .NUM_LANES  (NUM_LANES),
        .OUT_BUF    (3)
    ) gather_unit (
        .clk           (clk),
        .reset         (reset),
        .commit_in_if  (per_block_commit_if),
        .commit_out_if (commit_if)
    );

    VX_commit_if #(
        .NUM_LANES (NUM_LANES)
    ) commit_st_if();
    
    VX_commit_if #(
        .NUM_LANES (NUM_LANES)
    ) commit_ld_if();


    localparam TAG_WIDTH = `UUID_WIDTH + (NUM_LANES * `CACHE_ADDR_TYPE_BITS) + `NW_WIDTH + `XLEN + NUM_LANES + `NR_BITS + `INST_LSU_BITS + (NUM_LANES * (REQ_ASHIFT)) + `LSU_DUP_ENABLED + PID_WIDTH + LSUQ_SIZEW;

    wire                            mem_req_valid;
    //wire [NUM_LANES-1:0]            mem_req_mask;
    wire                            mem_req_rw;  
    //wire [NUM_LANES-1:0][`MEM_ADDR_WIDTH-REQ_ASHIFT-1:0] mem_req_addr;
    //reg  [NUM_LANES-1:0][DCACHE_WORD_SIZE-1:0] mem_req_byteen;
    //reg  [NUM_LANES-1:0][`XLEN-1:0] mem_req_data;
    //wire [TAG_WIDTH-1:0]            mem_req_tag;
    wire                            mem_req_ready;

    `IGNORE_WARNINGS_BEGIN
    wire                            mem_rsp_valid;
    
    wire [NUM_LANES-1:0]            mem_rsp_mask;
    //wire [NUM_LANES-1:0][`XLEN-1:0] mem_rsp_data;
    wire [TAG_WIDTH-1:0]            mem_rsp_tag;
    //wire                            mem_rsp_sop;
    //wire                            mem_rsp_eop;
    wire                            mem_rsp_ready;
    
    wire lsu_valid, lsu_ready;
    wire mem_req_empty;

    wire is_fence = `INST_LSU_IS_FENCE(per_block_execute_if[0].data.op_type);
    wire start_fence = is_fence && ((~mem_req_empty) || downstream_mem_busy);
    wire end_fence = mem_req_empty && (!downstream_mem_busy);
    logic fencing;
    `IGNORE_WARNINGS_END
   

    always @(posedge clk) begin
        if (reset) begin
            fencing <= 1'b0;
        end else if (start_fence) begin
            fencing <= 1'b1;
        end else if (end_fence) begin
            fencing <= 1'b0;
        end
    end

    `IGNORE_WARNINGS_BEGIN
    wire lsu_is_dup;
    `IGNORE_WARNINGS_END

`ifdef LSU_DUP_ENABLE
    if (NUM_LANES > 1) begin    
        wire [NUM_LANES-2:0] addr_matches;
        for (genvar i = 0; i < (NUM_LANES-1); ++i) begin
            assign addr_matches[i] = (execute_if[0].data.rs1_data[i+1] == execute_if[0].data.rs1_data[0]) || ~execute_if[0].data.tmask[i+1];
        end
        assign lsu_is_dup = execute_if[0].data.tmask[0] && (& addr_matches);
    end else begin
        assign lsu_is_dup = 0;
    end
`else
    assign lsu_is_dup = 0;
`endif


    wire [NUM_LANES-1:0][`XLEN-1:0] full_addr;    
    for (genvar i = 0; i < NUM_LANES; ++i) begin : genblk1
        assign full_addr[i] = per_block_execute_if[0].data.rs1_data[i][`XLEN-1:0] + per_block_execute_if[0].data.imm;
    end


    //for (genvar i = 0; i < NUM_LANES; ++i) begin : genblk2
    //    assign mem_req_mask[i] = per_block_execute_if[0].data.tmask[i] && (~lsu_is_dup || (i == 0));
    //end

    `IGNORE_WARNINGS_BEGIN
    wire [NUM_LANES-1:0][REQ_ASHIFT-1:0] req_align;
    `IGNORE_WARNINGS_END
    for (genvar i = 0; i < NUM_LANES; ++i) begin   : genblk4
        assign req_align[i] = full_addr[i][REQ_ASHIFT-1:0];
        //assign mem_req_addr[i] = full_addr[i][`MEM_ADDR_WIDTH-1:REQ_ASHIFT];
    end

    wire fence_wait = start_fence || fencing;
    
    assign lsu_valid = per_block_execute_if[0].valid && ~fence_wait;
    assign per_block_execute_if[0].ready = lsu_ready && ~fence_wait;

    assign mem_req_rw = ~per_block_execute_if[0].data.wb;    

    assign mem_req_valid = lsu_valid && (~mem_req_rw || st_rsp_ready);


    wire [`UUID_WIDTH-1:0] rsp_uuid;
    `IGNORE_WARNINGS_BEGIN
    wire [NUM_LANES-1:0][`CACHE_ADDR_TYPE_BITS-1:0] rsp_addr_type;
    `IGNORE_WARNINGS_END
    wire [`NW_WIDTH-1:0] rsp_wid;
    wire [NUM_LANES-1:0] rsp_tmask_uq;
    wire [`XLEN-1:0] rsp_pc;
    wire [`NR_BITS-1:0] rsp_rd;
    `IGNORE_WARNINGS_BEGIN
    wire [`INST_LSU_BITS-1:0] rsp_op_type;
    wire [NUM_LANES-1:0][REQ_ASHIFT-1:0] rsp_align;
    `IGNORE_WARNINGS_END
    wire [PID_WIDTH-1:0] rsp_pid;
    wire rsp_is_dup;

    assign mem_req_ready = 1'b1;
    assign mem_req_valid = 1'b1;


    //wire mem_req_fire = mem_req_valid && mem_req_ready;
    //wire mem_rsp_fire = mem_rsp_valid && mem_rsp_ready;
    wire mem_req_fire = mem_req_valid && mem_req_ready;
    
    `UNUSED_VAR (mem_req_fire)
    //`UNUSED_VAR (mem_rsp_fire)

    `IGNORE_WARNINGS_BEGIN    
    wire mem_rsp_sop_pkt, mem_rsp_eop_pkt;
    `IGNORE_WARNINGS_END

    `IGNORE_WARNINGS_BEGIN
    wire [LSUQ_SIZEW-1:0] pkt_waddr, pkt_raddr;
    `IGNORE_WARNINGS_END

    `ifndef LSU_DUP_ENABLE
    assign rsp_is_dup = 0;
    `endif

    assign {
        rsp_uuid, rsp_addr_type, rsp_wid, rsp_tmask_uq, rsp_pc, rsp_rd, rsp_op_type, rsp_align, rsp_pid, pkt_raddr
    `ifdef LSU_DUP_ENABLE
        , rsp_is_dup
    `endif
    } = mem_rsp_tag;

    `IGNORE_WARNINGS_BEGIN
    reg [NUM_LANES-1:0][`XLEN-1:0] rsp_data;
    `IGNORE_WARNINGS_END

    //wire [NUM_LANES-1:0] rsp_tmask;

    // load commit

    wire [NUM_LANES-1:0] rsp_tmask;

    assign mem_rsp_mask = 1;

    assign rsp_tmask = rsp_is_dup ? rsp_tmask_uq : mem_rsp_mask;

    VX_elastic_buffer #(
        .DATAW (`UUID_WIDTH + `NW_WIDTH + NUM_LANES + `XLEN + `NR_BITS + (NUM_LANES * `XLEN) + 1 + PID_WIDTH + 1 + 1),
        .SIZE  (2)
    ) ld_rsp_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (mem_rsp_valid),
        .ready_in  (mem_rsp_ready),
        .data_in   ({rsp_uuid, rsp_wid, rsp_tmask, rsp_pc, rsp_rd, rsp_data, 1'b0/*tensor*/, rsp_pid, mem_rsp_sop_pkt, mem_rsp_eop_pkt}),
        .data_out  ({commit_ld_if.data.uuid, commit_ld_if.data.wid, commit_ld_if.data.tmask, commit_ld_if.data.PC, commit_ld_if.data.rd, commit_ld_if.data.data, commit_ld_if.data.tensor, commit_ld_if.data.pid, commit_ld_if.data.sop, commit_ld_if.data.eop}),
        .valid_out (commit_ld_if.valid),
        .ready_out (commit_ld_if.ready)
    );
    

    assign commit_ld_if.data.wb = 1'b1;

    // store commit


    wire st_rsp_ready;

    VX_elastic_buffer #(
        .DATAW (`UUID_WIDTH + `NW_WIDTH + NUM_LANES + `XLEN + 1 + PID_WIDTH + 1 + 1),
        .SIZE  (2)
    ) st_rsp_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (mem_req_fire && mem_req_rw),
        .ready_in  (st_rsp_ready),
        .data_in   ({per_block_execute_if[0].data.uuid, per_block_execute_if[0].data.wid, per_block_execute_if[0].data.tmask, per_block_execute_if[0].data.PC, 2'b0/*tensor*/, per_block_execute_if[0].data.pid, per_block_execute_if[0].data.sop, per_block_execute_if[0].data.eop}),
        .data_out  ({commit_st_if.data.uuid, commit_st_if.data.wid, commit_st_if.data.tmask, commit_st_if.data.PC, commit_st_if.data.tensor, commit_st_if.data.pid, commit_st_if.data.sop, commit_st_if.data.eop}),
        .valid_out (commit_st_if.valid),
        .ready_out (commit_st_if.ready)
    );

    assign commit_st_if.data.rd   = '0;
    assign commit_st_if.data.wb   = 1'b0;
    assign commit_st_if.data.data = commit_ld_if.data.data; // force arbiter passthru


// tensor
//    VX_elastic_buffer #(
//        .DATAW (`UUID_WIDTH + `NW_WIDTH + NUM_LANES + `XLEN + `NR_BITS + (NUM_LANES * `XLEN) + 1 + PID_WIDTH + 1 + 1),
//        .SIZE  (2)
//    ) ld_rsp_buf (
//        .clk       (clk),
//        .reset     (reset),
//        .valid_in  (mem_rsp_valid),
//        .ready_in  (mem_rsp_ready),
//        .data_in   ({rsp_uuid, rsp_wid, rsp_tmask, rsp_pc, rsp_rd, rsp_data, 1'b0/*tensor*/, rsp_pid, mem_rsp_sop_pkt, mem_rsp_eop_pkt}),
//        .data_out  ({commit_ld_if.data.uuid, commit_ld_if.data.wid, commit_ld_if.data.tmask, commit_ld_if.data.PC, commit_ld_if.data.rd, commit_ld_if.data.data, commit_ld_if.data.tensor, commit_ld_if.data.pid, commit_ld_if.data.sop, commit_ld_if.data.eop}),
//        .valid_out (commit_ld_if.valid),
//        .ready_out (commit_ld_if.ready)
//    );

//    assign commit_ld_if.data.wb = 1'b1;

    // store commit

//    VX_elastic_buffer #(
//        .DATAW (`UUID_WIDTH + `NW_WIDTH + NUM_LANES + `XLEN + 1 + PID_WIDTH + 1 + 1),
//        .SIZE  (2)
//    ) st_rsp_buf (
//        .clk       (clk),
//        .reset     (reset),
//        .valid_in  (mem_req_fire && mem_req_rw),
//        .ready_in  (st_rsp_ready),
//        .data_in   ({execute_if[0].data.uuid, execute_if[0].data.wid, execute_if[0].data.tmask, execute_if[0].data.PC, 1'b0/*tensor*/, execute_if[0].data.pid, execute_if[0].data.sop, execute_if[0].data.eop}),
//        .data_out  ({commit_if.data.uuid, commit_if.data.wid, commit_if.data.tmask, commit_if.data.PC, commit_if.data.tensor, commit_if.data.pid, commit_if.data.sop, commit_if.data.eop}),
//        .valid_out (commit_if.valid),
//        .ready_out (commit_if.ready)
//    );

endmodule
