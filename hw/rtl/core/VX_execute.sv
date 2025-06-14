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

module VX_execute import VX_gpu_pkg::*; #(
    parameter `STRING INSTANCE_ID = "",
    parameter CORE_ID = 0,
    parameter TENSOR_FP16 = 0
) (
    `SCOPE_IO_DECL

    input wire              clk,
    input wire              reset,

`ifdef PERF_ENABLE
    input sysmem_perf_t     sysmem_perf,
    input pipeline_perf_t   pipeline_perf,
`endif

    input base_dcrs_t       base_dcrs,

    // Dcache interface
    VX_lsu_mem_if.master    lsu_mem_if [`NUM_LSU_BLOCKS],

    // dispatch interface
    VX_dispatch_if.slave    dispatch_if [`NUM_EX_UNITS * `ISSUE_WIDTH],

    // commit interface
    VX_commit_if.master     commit_if [`NUM_EX_UNITS * `ISSUE_WIDTH],

    // scheduler interfaces
    VX_sched_csr_if.slave   sched_csr_if,
    VX_branch_ctl_if.master branch_ctl_if [`NUM_ALU_BLOCKS],
    VX_warp_ctl_if.master   warp_ctl_if,

    // tensor interfaces

//`ifdef EXT_T_ENABLE
//    VX_dispatch_if.slave    tensor_dispatch_if [`ISSUE_WIDTH],
//    VX_commit_if.master     tensor_commit_if [`ISSUE_WIDTH],

//`ifdef EXT_T_HOPPER
//    VX_tc_rf_if.master      tensor_regfile_if,
//    VX_tc_bus_if.master     tensor_smem_A_if,
//    VX_tc_bus_if.master     tensor_smem_B_if,
//`endif
//`endif

    // commit interface
    VX_commit_csr_if.slave  commit_csr_if
);

`ifdef EXT_F_ENABLE
    VX_fpu_csr_if fpu_csr_if[`NUM_FPU_BLOCKS]();
`endif

    VX_alu_unit #(
        .INSTANCE_ID (`SFORMATF(("%s-alu", INSTANCE_ID)))
    ) alu_unit (
        .clk            (clk),
        .reset          (reset),
        .dispatch_if    (dispatch_if[`EX_ALU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .commit_if      (commit_if[`EX_ALU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .branch_ctl_if  (branch_ctl_if)
    );

    `SCOPE_IO_SWITCH (1);

    `IGNORE_WARNINGS_BEGIN
    VX_lsu_unit #(
        .INSTANCE_ID (`SFORMATF(("%s-lsu", INSTANCE_ID)))
    ) lsu_unit (
        `SCOPE_IO_BIND  (0)
        .clk            (clk),
        .reset          (reset),
        .dispatch_if    (dispatch_if[`EX_LSU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .commit_if      (commit_if[`EX_LSU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .lsu_mem_if     (lsu_mem_if)
    );
    `IGNORE_WARNINGS_END

`ifdef EXT_F_ENABLE
    VX_fpu_unit #(
        .INSTANCE_ID (`SFORMATF(("%s-fpu", INSTANCE_ID)))
    ) fpu_unit (
        .clk            (clk),
        .reset          (reset),
        .dispatch_if    (dispatch_if[`EX_FPU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .commit_if      (commit_if[`EX_FPU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .fpu_csr_if     (fpu_csr_if)
    );
`endif

//`ifdef EXT_T_ENABLE
    VX_tensor_core #(
        .FP16 (TENSOR_FP16)
    ) tensor_core (
        .clk(clk),
        .reset(reset),

        .dispatch_if(dispatch_if[`EX_TENSOR * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
//`ifdef EXT_T_HOPPER
//        .regfile_if(tensor_regfile_if),
//        .smem_A_if(tensor_smem_A_if),
//        .smem_B_if(tensor_smem_B_if),
//`endif
        .commit_if(commit_if[`EX_TENSOR * `ISSUE_WIDTH +: `ISSUE_WIDTH])
    );
//`endif


    VX_sfu_unit #(
        .INSTANCE_ID (`SFORMATF(("%s-sfu", INSTANCE_ID))),
        .CORE_ID (CORE_ID)
    ) sfu_unit (
        .clk            (clk),
        .reset          (reset),
    `ifdef PERF_ENABLE
        .sysmem_perf    (sysmem_perf),
        .pipeline_perf  (pipeline_perf),
    `endif
        .base_dcrs      (base_dcrs),
        .dispatch_if    (dispatch_if[`EX_SFU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
        .commit_if      (commit_if[`EX_SFU * `ISSUE_WIDTH +: `ISSUE_WIDTH]),
    `ifdef EXT_F_ENABLE
        .fpu_csr_if     (fpu_csr_if),
    `endif
        .commit_csr_if  (commit_csr_if),
        .sched_csr_if   (sched_csr_if),
        .warp_ctl_if    (warp_ctl_if)
    );

endmodule
