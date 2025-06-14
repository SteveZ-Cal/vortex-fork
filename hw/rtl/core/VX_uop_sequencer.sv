`include "VX_define.vh"

`define FREG(x) {1'b1, `NRI_BITS'(x)}

module VX_uop_sequencer import VX_gpu_pkg::*; (
    input clk,
    input reset,

    VX_ibuffer_if.slave  uop_sequencer_if,
    VX_ibuffer_if.master ibuffer_if
);

`ifdef EXT_T_ENABLE
    localparam UOP_TABLE_SIZE = 64;
    localparam UPC_BITS = `CLOG2(UOP_TABLE_SIZE);

    localparam UBR_BITS = 2;
    localparam NEXT   = UBR_BITS'(2'b00);
    localparam FINISH = UBR_BITS'(2'b01);

    // uop metadata (sequencing, next state), execution metadata (EX_TYPE, OP_TYPE, OP_MOD), wb, use pc, use imm, pc, imm, rd, rs1, rs2, rs3
    localparam UOP_TABLE_WIDTH = UBR_BITS + UPC_BITS + `EX_BITS + `INST_OP_BITS + `INST_MOD_BITS + 1 + 1 + 1 + `XLEN + `XLEN + (`NR_BITS * 4);
    localparam IBUFFER_IF_DATAW = `UUID_WIDTH + ISSUE_WIS_W + `NUM_THREADS + `XLEN + 1 + `EX_BITS + `INST_OP_BITS + `INST_MOD_BITS + 1 + 1 + `XLEN + (`NR_BITS * 4);

    logic [UOP_TABLE_WIDTH-1:0] uop;

    // reserve space at start of table for more uop sequences
    localparam HMMA_SET0_STEP0_0 = UPC_BITS'(0);
    localparam HMMA_SET0_STEP0_1 = UPC_BITS'(8);
    localparam HMMA_SET0_STEP1_0 = UPC_BITS'(9);
    localparam HMMA_SET0_STEP1_1 = UPC_BITS'(10);
    localparam HMMA_SET0_STEP2_0 = UPC_BITS'(11);
    localparam HMMA_SET0_STEP2_1 = UPC_BITS'(12);
    localparam HMMA_SET0_STEP3_0 = UPC_BITS'(13);
    localparam HMMA_SET0_STEP3_1 = UPC_BITS'(14);

    localparam HMMA_SET1_STEP0_0 = UPC_BITS'(15);
    localparam HMMA_SET1_STEP0_1 = UPC_BITS'(16);
    localparam HMMA_SET1_STEP1_0 = UPC_BITS'(17);
    localparam HMMA_SET1_STEP1_1 = UPC_BITS'(18);
    localparam HMMA_SET1_STEP2_0 = UPC_BITS'(19);
    localparam HMMA_SET1_STEP2_1 = UPC_BITS'(20);
    localparam HMMA_SET1_STEP3_0 = UPC_BITS'(21);
    localparam HMMA_SET1_STEP3_1 = UPC_BITS'(22);

    localparam HMMA_SET2_STEP0_0 = UPC_BITS'(23);
    localparam HMMA_SET2_STEP0_1 = UPC_BITS'(24);
    localparam HMMA_SET2_STEP1_0 = UPC_BITS'(25);
    localparam HMMA_SET2_STEP1_1 = UPC_BITS'(26);
    localparam HMMA_SET2_STEP2_0 = UPC_BITS'(27);
    localparam HMMA_SET2_STEP2_1 = UPC_BITS'(28);
    localparam HMMA_SET2_STEP3_0 = UPC_BITS'(29);
    localparam HMMA_SET2_STEP3_1 = UPC_BITS'(30);

    localparam HMMA_SET3_STEP0_0 = UPC_BITS'(31);
    localparam HMMA_SET3_STEP0_1 = UPC_BITS'(32);
    localparam HMMA_SET3_STEP1_0 = UPC_BITS'(33);
    localparam HMMA_SET3_STEP1_1 = UPC_BITS'(34);
    localparam HMMA_SET3_STEP2_0 = UPC_BITS'(35);
    localparam HMMA_SET3_STEP2_1 = UPC_BITS'(36);
    localparam HMMA_SET3_STEP3_0 = UPC_BITS'(37);
    localparam HMMA_SET3_STEP3_1 = UPC_BITS'(38);
    // register layout: f0-f7 used for A, f8-f15 used for B, f16-f23 used for C

    logic [UPC_BITS-1:0] upc, upc_r, upc_n;

    always @(*) begin
        case (upc)
`ifdef EXT_T_ENABLE
// uop metadata (sequencing, next state), execution metadata (EX_TYPE, OP_TYPE, OP_MOD), wb, use pc, use imm, pc, imm, rd, rs1, rs2, rs3
HMMA_SET0_STEP0_0: begin
	uop = {NEXT, HMMA_SET0_STEP0_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(16), `FREG(0), `FREG(8), `FREG(16)};
end
HMMA_SET0_STEP0_1: begin
	uop = {NEXT, HMMA_SET0_STEP1_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(17), `FREG(1), `FREG(9), `FREG(17)};
end
HMMA_SET0_STEP1_0: begin
	uop = {NEXT, HMMA_SET0_STEP1_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(18), `FREG(0), `FREG(8), `FREG(18)};
end
HMMA_SET0_STEP1_1: begin
	uop = {NEXT, HMMA_SET0_STEP2_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(19), `FREG(1), `FREG(9), `FREG(19)};
end
HMMA_SET0_STEP2_0: begin
	uop = {NEXT, HMMA_SET0_STEP2_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(20), `FREG(0), `FREG(8), `FREG(20)};
end
HMMA_SET0_STEP2_1: begin
	uop = {NEXT, HMMA_SET0_STEP3_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(21), `FREG(1), `FREG(9), `FREG(21)};
end
HMMA_SET0_STEP3_0: begin
	uop = {NEXT, HMMA_SET0_STEP3_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(22), `FREG(0), `FREG(8), `FREG(22)};
end
HMMA_SET0_STEP3_1: begin
	uop = {NEXT, HMMA_SET1_STEP0_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(23), `FREG(1), `FREG(9), `FREG(23)};
end
HMMA_SET1_STEP0_0: begin
	uop = {NEXT, HMMA_SET1_STEP0_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(16), `FREG(2), `FREG(10), `FREG(16)};
end
HMMA_SET1_STEP0_1: begin
	uop = {NEXT, HMMA_SET1_STEP1_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(17), `FREG(3), `FREG(11), `FREG(17)};
end
HMMA_SET1_STEP1_0: begin
	uop = {NEXT, HMMA_SET1_STEP1_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(18), `FREG(2), `FREG(10), `FREG(18)};
end
HMMA_SET1_STEP1_1: begin
	uop = {NEXT, HMMA_SET1_STEP2_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(19), `FREG(3), `FREG(11), `FREG(19)};
end
HMMA_SET1_STEP2_0: begin
	uop = {NEXT, HMMA_SET1_STEP2_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(20), `FREG(2), `FREG(10), `FREG(20)};
end
HMMA_SET1_STEP2_1: begin
	uop = {NEXT, HMMA_SET1_STEP3_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(21), `FREG(3), `FREG(11), `FREG(21)};
end
HMMA_SET1_STEP3_0: begin
	uop = {NEXT, HMMA_SET1_STEP3_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(22), `FREG(2), `FREG(10), `FREG(22)};
end
HMMA_SET1_STEP3_1: begin
	uop = {NEXT, HMMA_SET2_STEP0_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(23), `FREG(3), `FREG(11), `FREG(23)};
end
HMMA_SET2_STEP0_0: begin
	uop = {NEXT, HMMA_SET2_STEP0_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(16), `FREG(4), `FREG(12), `FREG(16)};
end
HMMA_SET2_STEP0_1: begin
	uop = {NEXT, HMMA_SET2_STEP1_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(17), `FREG(5), `FREG(13), `FREG(17)};
end
HMMA_SET2_STEP1_0: begin
	uop = {NEXT, HMMA_SET2_STEP1_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(18), `FREG(4), `FREG(12), `FREG(18)};
end
HMMA_SET2_STEP1_1: begin
	uop = {NEXT, HMMA_SET2_STEP2_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(19), `FREG(5), `FREG(13), `FREG(19)};
end
HMMA_SET2_STEP2_0: begin
	uop = {NEXT, HMMA_SET2_STEP2_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(20), `FREG(4), `FREG(12), `FREG(20)};
end
HMMA_SET2_STEP2_1: begin
	uop = {NEXT, HMMA_SET2_STEP3_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(21), `FREG(5), `FREG(13), `FREG(21)};
end
HMMA_SET2_STEP3_0: begin
	uop = {NEXT, HMMA_SET2_STEP3_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(22), `FREG(4), `FREG(12), `FREG(22)};
end
HMMA_SET2_STEP3_1: begin
	uop = {NEXT, HMMA_SET3_STEP0_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(23), `FREG(5), `FREG(13), `FREG(23)};
end
HMMA_SET3_STEP0_0: begin
	uop = {NEXT, HMMA_SET3_STEP0_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(16), `FREG(6), `FREG(14), `FREG(16)};
end
HMMA_SET3_STEP0_1: begin
	uop = {NEXT, HMMA_SET3_STEP1_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(0), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(17), `FREG(7), `FREG(15), `FREG(17)};
end
HMMA_SET3_STEP1_0: begin
	uop = {NEXT, HMMA_SET3_STEP1_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(18), `FREG(6), `FREG(14), `FREG(18)};
end
HMMA_SET3_STEP1_1: begin
	uop = {NEXT, HMMA_SET3_STEP2_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(1), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(19), `FREG(7), `FREG(15), `FREG(19)};
end
HMMA_SET3_STEP2_0: begin
	uop = {NEXT, HMMA_SET3_STEP2_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(20), `FREG(6), `FREG(14), `FREG(20)};
end
HMMA_SET3_STEP2_1: begin
	uop = {NEXT, HMMA_SET3_STEP3_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(2), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(21), `FREG(7), `FREG(15), `FREG(21)};
end
HMMA_SET3_STEP3_0: begin
	uop = {NEXT, HMMA_SET3_STEP3_1, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(0), 1'b1, 1'b0, 1'b0, 32'b0, 32'b0, `FREG(22), `FREG(6), `FREG(14), `FREG(22)};
end
HMMA_SET3_STEP3_1: begin
	uop = {FINISH, HMMA_SET0_STEP0_0, `EX_BITS'(`EX_TENSOR), `INST_OP_BITS'(3), `INST_MOD_BITS'(1), 1'b1, 1'b0, 1'b0, 32'b1, 32'b1, `FREG(23), `FREG(7), `FREG(15), `FREG(23)};
end
`endif
            default: begin
                uop = '0;
            end
        endcase
    end

    wire [UBR_BITS-1:0] ubr = uop[UOP_TABLE_WIDTH-1:UOP_TABLE_WIDTH-UBR_BITS];
    wire [UPC_BITS-1:0] next_upc = uop[UOP_TABLE_WIDTH-UBR_BITS-1:UOP_TABLE_WIDTH-UBR_BITS-UPC_BITS];

    logic use_uop, use_uop_1d;
    wire uop_fire = use_uop && ibuffer_if.valid && ibuffer_if.ready;
    
    wire uop_start = ~use_uop_1d && use_uop;
    wire uop_finish = use_uop && uop_sequencer_if.valid && uop_sequencer_if.ready;

    // merging the 2 always blocks leads to spurious UNOPTFLAT verilator lint,
    // but conceptually they should be linked
    always @(*) begin
`ifdef EXT_T_HOPPER
        // for Hopper, disable micro-op blitzing.  Set/step is managed
        // microarchitecturally in an FSM inside the tensor core.
        use_uop = 1'b0;
`else
        use_uop = uop_sequencer_if.valid && uop_sequencer_if.data.ex_type == `EX_BITS'(`EX_TENSOR);
`endif

        if (uop_start) begin
            // 1st cycle of microcoded operation, use op_type to determine entry point into microcode table
            upc_n = UPC_BITS'(uop_sequencer_if.data.op_type);
        end
        else begin
            upc_n = upc;
        end
        
        if (uop_fire) begin
            upc_n = next_upc;
        end
    end

    always @(*) begin
        if (uop_start) begin
            // 1st cycle of microcoded operation, use op_type to determine entry point into microcode table
            upc = UPC_BITS'(uop_sequencer_if.data.op_type);
        end
        else begin
            upc = upc_r;
        end
    end

    // copy UUID, wis, tmask from microcoded instruction
    wire [IBUFFER_IF_DATAW-1:0] ibuffer_output = {
        uop_sequencer_if.data.uuid,
        uop_sequencer_if.data.wis,
        uop_sequencer_if.data.tmask,
        uop[UOP_TABLE_WIDTH-UBR_BITS-UPC_BITS-1:0]
    };

    // passthrough when !use_uop
    assign ibuffer_if.valid = use_uop ? 1'b1 : uop_sequencer_if.valid;
    assign uop_sequencer_if.ready = use_uop ? (uop_fire && ubr == FINISH) : ibuffer_if.ready;

    always @(*) begin
        ibuffer_if.data = use_uop ? ibuffer_output : uop_sequencer_if.data;

        if (uop_sequencer_if.valid && use_uop &&
            uop_sequencer_if.data.rd  == `NR_BITS'(1)) begin
            // if rd is '1', use a separate set of 8 fp registers as the
            // destination accumulator data.
            ibuffer_if.data.rd  = ibuffer_if.data.rd  + `NR_BITS'(8); // note 8 is hardcoded
            ibuffer_if.data.rs3 = ibuffer_if.data.rs3 + `NR_BITS'(8);
        end
    end

    always @(posedge clk) begin
        if (uop_start) begin
            // $display("UOP start @ %t", $time);
            // $display("use_uop=%0d, use_uop_1d=%0d, uop_start=%0d, ibuffer_if.valid=%0d, ibuffer_if.ready=%0d", use_uop, use_uop_1d, uop_start, ibuffer_if.valid, ibuffer_if.ready);
        end

        if (uop_fire) begin
            // $display("UOP fire @ %t", $time);
        end

        if (uop_finish) begin
            // $display("UOP finish @ %t", $time);
        end

        if (reset) begin
            upc_r <= '0;
            use_uop_1d <= '0;
        end
        else begin
            upc_r <= upc_n;
            if (uop_finish) begin
                use_uop_1d <= 1'b0; // allow microcoded instructions to start immediately after eachother
            end
            else begin
                use_uop_1d <= use_uop;
            end
        end
    end
`else
    `UNUSED_VAR(clk);
    `UNUSED_VAR(reset);
    assign ibuffer_if.valid = uop_sequencer_if.valid;
    assign uop_sequencer_if.ready = ibuffer_if.ready;
    assign ibuffer_if.data = uop_sequencer_if.data;
`endif
    

endmodule