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

`ifdef GPR_DUPLICATED

module VX_operands_dup import VX_gpu_pkg::*; #(
    parameter CORE_ID = 0,
    parameter CACHE_ENABLE = 0
) (
    input wire              clk,
    input wire              reset,

    VX_writeback_if.slave   writeback_if [`ISSUE_WIDTH],
    VX_ibuffer_if.slave     scoreboard_if [`ISSUE_WIDTH],
`ifdef EXT_T_HOPPER
    VX_tc_rf_if.slave       tensor_regfile_if,
`endif
    VX_operands_if.master   operands_if [`ISSUE_WIDTH]
);
    `UNUSED_PARAM (CORE_ID)
    localparam DATAW = `UUID_WIDTH + ISSUE_WIS_W + `NUM_THREADS + `XLEN + 1 + `EX_BITS + `INST_OP_BITS + `INST_MOD_BITS + 1 + 1 + `XLEN + `NR_BITS;
    localparam RAM_ADDRW = `LOG2UP(`NUM_REGS * ISSUE_RATIO);

`ifdef PERF_ENABLE
    logic [`ISSUE_WIDTH-1:0][`PERF_CTR_BITS-1:0] perf_rf_read_per_warp;
    logic [`ISSUE_WIDTH-1:0][`PERF_CTR_BITS-1:0] perf_rf_write_per_warp;
`endif

    logic [`ISSUE_WIDTH-1:0][DATAW-1:0] scoreboard_if_stored;
    logic [`ISSUE_WIDTH-1:0] scoreboard_if_stored_valid;
    logic [`ISSUE_WIDTH-1:0] full1;
    logic [`ISSUE_WIDTH-1:0][`NUM_THREADS-1:0] full2;
    logic [`ISSUE_WIDTH-1:0] empty1;
    logic [`ISSUE_WIDTH-1:0][`NUM_THREADS-1:0] empty2;
    logic [`ISSUE_WIDTH-1:0][2:0] size1;

    wire                                        tc_rf_valid [`ISSUE_WIDTH];
    wire [`LOG2UP(`NUM_REGS * ISSUE_RATIO)-1:0] tc_rf_addr  [`ISSUE_WIDTH];
    // FIXME: don't need full ISSUE_WIDTH; only one warp is read at a time
    // because NUM_BLOCKS == 1
    wire         [`NUM_THREADS-1:0][`XLEN-1:0]  tc_rf_data  [`ISSUE_WIDTH];

`ifdef EXT_T_HOPPER
    `STATIC_ASSERT((ISSUE_RATIO == 1),
        ("static assertion failed: tensor core only supports ISSUE_RATIO == 1"))
    assign tc_rf_valid = '{`ISSUE_WIDTH{tensor_regfile_if.req_valid}};
    assign tc_rf_addr  = '{`ISSUE_WIDTH{tensor_regfile_if.req_data.rs}};
    assign tensor_regfile_if.rsp_data.data = tc_rf_data[0];
`endif

    for (genvar i = 0; i < `ISSUE_WIDTH; ++i) begin

        always @(posedge clk) begin
            if (reset) begin
              scoreboard_if_stored[i] <= '0;
              scoreboard_if_stored_valid[i] <= '0;
            end else begin
              scoreboard_if_stored[i] <= {
                scoreboard_if[i].data.uuid,
                scoreboard_if[i].data.wis,
                scoreboard_if[i].data.tmask,
                scoreboard_if[i].data.PC,
                scoreboard_if[i].data.wb,
                scoreboard_if[i].data.ex_type,
                scoreboard_if[i].data.op_type,
                scoreboard_if[i].data.op_mod,
                scoreboard_if[i].data.use_PC,
                scoreboard_if[i].data.use_imm,
                scoreboard_if[i].data.imm,
                scoreboard_if[i].data.rd
              };
              scoreboard_if_stored_valid[i] <= scoreboard_if[i].valid && scoreboard_if[i].ready;
            end
        end

        VX_fifo_queue #(
            .DATAW   (DATAW),
            .DEPTH   (4), // could be 3 but limited by power of 2
            .OUT_REG (0),
            .LUTRAM  (0)
        ) fifo_queue (
            .clk      (clk),
            .reset    (reset),
            .push     (scoreboard_if_stored_valid[i]),
            .pop      (operands_if[i].ready && ~empty1[i]),
            .data_in  (scoreboard_if_stored[i]),
            .data_out ({
                operands_if[i].data.uuid,
                operands_if[i].data.wis,
                operands_if[i].data.tmask,
                operands_if[i].data.PC,
                operands_if[i].data.wb,
                operands_if[i].data.ex_type,
                operands_if[i].data.op_type,
                operands_if[i].data.op_mod,
                operands_if[i].data.use_PC,
                operands_if[i].data.use_imm,
                operands_if[i].data.imm,
                operands_if[i].data.rd
            }),
            .empty    (empty1[i]),
            .full     (full1[i]),
            `UNUSED_PIN (alm_empty),
            `UNUSED_PIN (alm_full),
            .size     (size1[i])
        );
        assign operands_if[i].valid = ~empty1[i];
`ifdef EXT_T_HOPPER
        assign scoreboard_if[i].ready = (size1[i] < 3'd2) && ~tc_rf_valid[i];
`else
        assign scoreboard_if[i].ready = (size1[i] < 3'd2);
`endif

        // assert (full1[i] == full2[i]);
        // assert (empty1[i] == empty2[i]);

        wire [`NUM_THREADS-1:0][`XLEN-1:0] rs1_data;
        wire [`NUM_THREADS-1:0][`XLEN-1:0] rs2_data;
        wire [`NUM_THREADS-1:0][`XLEN-1:0] rs3_data;

        reg [RAM_ADDRW-1:0] gpr_rd_addr_rs1_stored;
        reg [RAM_ADDRW-1:0] gpr_rd_addr_rs2_stored;
        reg [RAM_ADDRW-1:0] gpr_rd_addr_rs3_stored;

        for (genvar j = 0; j < `NUM_THREADS; ++j) begin
            VX_fifo_queue #(
                .DATAW   (`XLEN + `XLEN + `XLEN),
                .DEPTH   (4),
                .OUT_REG (0),
                .LUTRAM  (0)
            ) fifo_queue (
                .clk      (clk),
                .reset    (reset),
                .push     (scoreboard_if_stored_valid[i]),
                .pop      (operands_if[i].ready && ~empty2[i][0]),
                .data_in  ({
                    (gpr_rd_addr_rs1_stored == '0) ? 32'd0 : rs1_data[j],
                    (gpr_rd_addr_rs2_stored == '0) ? 32'd0 : rs2_data[j],
                    (gpr_rd_addr_rs3_stored == '0) ? 32'd0 : rs3_data[j]
                }),
                .data_out ({
                    operands_if[i].data.rs1_data[j],
                    operands_if[i].data.rs2_data[j],
                    operands_if[i].data.rs3_data[j]
                }),
                .empty    (empty2[i][j]),
                .full     (full2[i][j]),
                `UNUSED_PIN (alm_empty),
                `UNUSED_PIN (alm_full),
                `UNUSED_PIN (size)
            );
`ifdef EXT_T_HOPPER
            assign tc_rf_data[i][j] = rs3_data[j];
`endif
        end

        // GPR banks

        wire [RAM_ADDRW-1:0] gpr_rd_addr_rs1;
        wire [RAM_ADDRW-1:0] gpr_rd_addr_rs2;
        wire [RAM_ADDRW-1:0] gpr_rd_addr_rs3;
        wire [RAM_ADDRW-1:0] gpr_wr_addr;

        always @(posedge clk) begin
            if (reset) begin
                gpr_rd_addr_rs1_stored <= '0;
                gpr_rd_addr_rs2_stored <= '0;
                gpr_rd_addr_rs3_stored <= '0;
            end else begin
                gpr_rd_addr_rs1_stored <= gpr_rd_addr_rs1;
                gpr_rd_addr_rs2_stored <= gpr_rd_addr_rs2;
                gpr_rd_addr_rs3_stored <= gpr_rd_addr_rs3;
            end
        end

        if (ISSUE_WIS != 0) begin
            assign gpr_wr_addr = {writeback_if[i].data.wis, writeback_if[i].data.rd};
            assign gpr_rd_addr_rs1 = {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs1};
            assign gpr_rd_addr_rs2 = {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs2};
`ifdef EXT_T_HOPPER
            assign gpr_rd_addr_rs3 = tc_rf_valid[i] ? tc_rf_addr[i] : {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs3};
`else
            assign gpr_rd_addr_rs3 = {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs3};
`endif
            // always @(posedge clk) begin
            //     if (reset) begin
            //         gpr_rd_addr_rs1 <= '0;
            //         gpr_rd_addr_rs2 <= '0;
            //         gpr_rd_addr_rs3 <= '0;
            //     end else begin
            //         // if (!(operands_if[i].valid && !operands_if[i].ready)) begin
            //         if (scoreboard_if[i].valid && scoreboard_if[i].ready) begin
            //             gpr_rd_addr_rs1 <= {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs1};
            //             gpr_rd_addr_rs2 <= {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs2};
            //             gpr_rd_addr_rs3 <= {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs3};
            //         end
            //     end
            // end
        end else begin
            assign gpr_wr_addr = writeback_if[i].data.rd;
            assign gpr_rd_addr_rs1 = scoreboard_if[i].data.rs1;
            assign gpr_rd_addr_rs2 = scoreboard_if[i].data.rs2;
`ifdef EXT_T_HOPPER
            assign gpr_rd_addr_rs3 = tc_rf_valid[i] ? tc_rf_addr[i] : scoreboard_if[i].data.rs3;
`else
            assign gpr_rd_addr_rs3 = {scoreboard_if[i].data.wis, scoreboard_if[i].data.rs3};
`endif
            // always @(posedge clk) begin
            //     if (reset) begin
            //         gpr_rd_addr_rs1 <= '0;
            //         gpr_rd_addr_rs2 <= '0;
            //         gpr_rd_addr_rs3 <= '0;
            //     end else begin
            //         // if (!(operands_if[i].valid && !operands_if[i].ready)) begin
            //         if (scoreboard_if[i].valid && scoreboard_if[i].ready) begin
            //             gpr_rd_addr_rs1 <= scoreboard_if[i].data.rs1;
            //             gpr_rd_addr_rs2 <= scoreboard_if[i].data.rs2;
            //             gpr_rd_addr_rs3 <= scoreboard_if[i].data.rs3;
            //         end
            //     end
            // end
        end
        
    `ifdef GPR_RESET
        reg wr_enabled = 1'b0;
        always @(posedge clk) begin
            if (reset) begin
                wr_enabled <= 1'b1;
            end
        end
    `endif

`ifdef PERF_ENABLE
        logic [`NUM_THREADS-1:0][`PERF_CTR_BITS-1:0] perf_write_rs1_per_thread;
        logic [`NUM_THREADS-1:0][`PERF_CTR_BITS-1:0] perf_write_rs2_per_thread;
        logic [`NUM_THREADS-1:0][`PERF_CTR_BITS-1:0] perf_write_rs3_per_thread;
`endif

        for (genvar j = 0; j < `NUM_THREADS; ++j) begin
            VX_dp_ram #(
                .DATAW (`XLEN),
                .SIZE (`NUM_REGS * ISSUE_RATIO),
                .OUT_REG (1),
            `ifdef GPR_RESET
                .INIT_ENABLE (1),
                .INIT_VALUE (0),
            `endif
                .NO_RWCHECK (1)
            ) gpr_ram_rs1 (
                .clk   (clk),
                .read  (scoreboard_if[i].valid && scoreboard_if[i].ready), // tc read valid check incl. in ready
                `UNUSED_PIN (wren),
            `ifdef GPR_RESET
                .write (wr_enabled && writeback_if[i].valid && writeback_if[i].data.tmask[j]),
            `else
                .write (writeback_if[i].valid && writeback_if[i].data.tmask[j]),
            `endif              
                .waddr (gpr_wr_addr),
                .wdata (writeback_if[i].data.data[j]),
                .raddr (gpr_rd_addr_rs1),
                .rdata (rs1_data[j])
            );

            VX_dp_ram #(
                .DATAW (`XLEN),
                .SIZE (`NUM_REGS * ISSUE_RATIO),
                .OUT_REG (1),
            `ifdef GPR_RESET
                .INIT_ENABLE (1),
                .INIT_VALUE (0),
            `endif
                .NO_RWCHECK (1)
            ) gpr_ram_rs2(
                .clk   (clk),
                .read  (scoreboard_if[i].valid && scoreboard_if[i].ready), // tc read valid check incl. in ready
                `UNUSED_PIN (wren),
            `ifdef GPR_RESET
                .write (wr_enabled && writeback_if[i].valid && writeback_if[i].data.tmask[j]),
            `else
                .write (writeback_if[i].valid && writeback_if[i].data.tmask[j]),
            `endif              
                .waddr (gpr_wr_addr),
                .wdata (writeback_if[i].data.data[j]),
                .raddr (gpr_rd_addr_rs2),
                .rdata (rs2_data[j])
            );

            VX_dp_ram #(
                .DATAW (`XLEN),
                .SIZE (`NUM_REGS * ISSUE_RATIO),
                .OUT_REG (1),
            `ifdef GPR_RESET
                .INIT_ENABLE (1),
                .INIT_VALUE (0),
            `endif
                .NO_RWCHECK (1)
            ) gpr_ram_rs3 (
                .clk   (clk),
`ifdef EXT_T_HOPPER
                .read  ((scoreboard_if[i].valid && scoreboard_if[i].ready) || tc_rf_valid[i]),
`else
                .read  (scoreboard_if[i].valid && scoreboard_if[i].ready),
`endif
                `UNUSED_PIN (wren),
            `ifdef GPR_RESET
                .write (wr_enabled && writeback_if[i].valid && writeback_if[i].data.tmask[j]),
            `else
                .write (writeback_if[i].valid && writeback_if[i].data.tmask[j]),
            `endif              
                .waddr (gpr_wr_addr),
                .wdata (writeback_if[i].data.data[j]),
                .raddr (gpr_rd_addr_rs3),
                .rdata (rs3_data[j])
            );

`ifdef PERF_ENABLE
            assign perf_write_rs1_per_thread[j] = (wr_enabled && writeback_if[i].valid && writeback_if[i].data.tmask[j]);
            assign perf_write_rs2_per_thread[j] = (wr_enabled && writeback_if[i].valid && writeback_if[i].data.tmask[j]);
            assign perf_write_rs3_per_thread[j] = (wr_enabled && writeback_if[i].valid && writeback_if[i].data.tmask[j]);
`endif
        end

`ifdef PERF_ENABLE
        // read is done for all threads; write is masked
        wire scoreboard_fire = scoreboard_if[i].valid && scoreboard_if[i].ready;
        wire [`PERF_CTR_BITS-1:0] perf_read_rs1_per_warp = (scoreboard_fire ? `NUM_THREADS : `PERF_CTR_BITS'b0);
        wire [`PERF_CTR_BITS-1:0] perf_read_rs2_per_warp = (scoreboard_fire ? `NUM_THREADS : `PERF_CTR_BITS'b0);
        wire [`PERF_CTR_BITS-1:0] perf_read_rs3_per_warp = (scoreboard_fire ? `NUM_THREADS : `PERF_CTR_BITS'b0);
        assign perf_rf_read_per_warp[i] = perf_read_rs1_per_warp + perf_read_rs2_per_warp + perf_read_rs3_per_warp;

        always @(*) begin
            perf_rf_write_per_warp[i] = '0;
            for (integer t = 0; t < `NUM_THREADS; ++t) begin
                perf_rf_write_per_warp[i] = perf_rf_write_per_warp[i] + 
                                            perf_write_rs1_per_thread[t] +
                                            perf_write_rs2_per_thread[t] +
                                            perf_write_rs3_per_thread[t];
            end
        end
`endif
    end

`ifdef PERF_ENABLE
    logic [`PERF_CTR_BITS-1:0] perf_rf_read_per_cycle;
    logic [`PERF_CTR_BITS-1:0] perf_rf_write_per_cycle;

    always @(*) begin
        perf_rf_read_per_cycle = '0;
        perf_rf_write_per_cycle = '0;
        for (integer i = 0; i < `ISSUE_WIDTH; ++i) begin
            perf_rf_read_per_cycle = perf_rf_read_per_cycle + perf_rf_read_per_warp[i];
            perf_rf_write_per_cycle = perf_rf_write_per_cycle + perf_rf_write_per_warp[i];
        end
    end

    logic [`PERF_CTR_BITS-1:0] perf_rf_reads;
    logic [`PERF_CTR_BITS-1:0] perf_rf_writes;

    always @(posedge clk) begin
        if (reset) begin
            perf_rf_reads <= '0;
            perf_rf_writes <= '0;
        end else begin
            perf_rf_reads  <= perf_rf_reads  + perf_rf_read_per_cycle;
            perf_rf_writes <= perf_rf_writes + perf_rf_write_per_cycle;
        end
    end
`endif

endmodule

`endif