/*module VX_tensor_threadgroup #(
    parameter FP16 = 0
) (
    input clk,
    input reset,

    input valid_in,
    output ready_in,
    input stall,
    // all *_frag are row-major
    // (m,n,k) = (2,4,2)
    input [1:0][1:0][31:0] A_frag,
    input [1:0][3:0][31:0] B_frag,
    input [1:0][3:0][31:0] C_frag,

    output valid_out,
    output [1:0][3:0][31:0] D_frag
);
    wire fedp_valid_in;
    wire fedp_ready_in;
    wire fedp_fire_in  = fedp_valid_in && fedp_ready_in;

    wire [3:0] fedp_valids;
    wire fedp_valid_out = &(fedp_valids);
    wire fedp_ready_out = !stall;
    wire fedp_fire_out  = fedp_valid_out && fedp_ready_out;

    assign fedp_valid_in = valid_in;
    // coupled ready; backpressure immediately reaches input from output
    assign fedp_ready_in = fedp_ready_out;

    // The dot product units take 2 cycles to finish computing A_frag * B_frag
    // + C_frag.  substep_in and substep_out keeps track of which cycle they're at
    // & when they have to pop from input queue and push to result queue.
    // Note that substep is different from the "step" defined in the HMMA
    // instruction set; it is similar in meaning to the substeps in
    // VX_tensor_octet.
    //
    // substep_in == 0: FEDP uses first half from operand buffer
    // substep_in == 1: FEDP uses last half and pops from operand buffer
    wire substep_in;
    // substep_out == 0: FEDP produces first half of D_frag
    // substep_out == 1: FEDP produces last half of D_frag and asserts valid_out
    wire substep_out;
    assign ready_in = fedp_fire_in && (substep_in == 1'b1);

    wire  [3:0] D_reg [31:0] ;
    logic [3:0] D_reg_n [31:0] ;

    // staging buffer that latches the D half-tile
    VX_tensor_reg #(.DATAW(32))
        //.DATAW($bits(D_reg))
     staging_d (
        .clk(clk),
        .reset(reset),
        .d(D_reg_n),
        .en(1'b1),
        .q(D_reg)
    );

    // latch the first-half result of D_frag
    wire  [3:0][31:0] D_half;
    always @(*) begin
        D_reg_n = D_reg;
        if (fedp_fire_out) begin
            if (substep_out == 1'b0) begin
                D_reg_n = D_half;
            end
        end
    end

    // flip substep_in/substep_out on FEDP in/out fire, respectively
    VX_tensor_reg #(.DATAW(1))
     staging_substep_in (
        .clk(clk),
        .reset(reset),
        .d(~substep_in),
        .en(fedp_fire_in),
        .q(substep_in)
    );
    VX_tensor_reg #(
        .DATAW(1)
    ) staging_substep_out (
        .clk(clk),
        .reset(reset),
        .d(~substep_out),
        .en(fedp_fire_out),
        .q(substep_out)
    );

    // TODO: Instead of latching half-result and constructing a full D tile,
    // we should be able to send these half fragments down to commit stage
    // immediately, saving flop space
    assign D_frag[0][0] = D_reg[0];
    assign D_frag[0][2] = D_reg[1];
    assign D_frag[1][0] = D_reg[2];
    assign D_frag[1][2] = D_reg[3];
    assign D_frag[0][1] = D_half[0];
    assign D_frag[0][3] = D_half[1];
    assign D_frag[1][1] = D_half[2];
    assign D_frag[1][3] = D_half[3];

    wire [1:0][3:0][15:0] A_frag_fp16 = A_frag;
    wire [3:0][3:0][15:0] B_frag_fp16 = B_frag;

    // 4 FEDPs per threadgroup
    //for (genvar i = 0; i < 4; ++i) begin 
    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1) begin : gen_label
        // Determine which elements in the D matrix the dot-product units get
        // mapped to.
        //
        // At substep == 0, the 0th and 2nd columns of D begins compute;
        // At substep == 1, the 1st and 3rd columns of D begins compute.
        // There are two row elements for each column, rounding out to
        // 4 elements computed by 4 FEDPs at every cycle
        // (see Figure 10(b)).

        //     i    : 0, 1, 2, 3
        // d_row    : 0, 0, 1, 1
        // d_col    : 0, 2, 0, 2
        // d_col_sel: 1, 3, 1, 3
        //
        // substep 0:
        // [ 0 x 2 x ] (0~3 is 'i', the dpu id)
        // [ 1 x 3 x ]
        // substep 1:
        // [ x 0 x 2 ]
        // [ x 1 x 3 ]
//        localparam int d_row = i / 2;
//        localparam int d_col = (i % 2) * 2;

        d_row = i / 2;
        d_col = (i % 2) * 2;
        wire [31:0] d_col_sel = (substep_in == 1'b0) ? d_col : (d_col + 1);

        // Dot product (FEDP) unit generated from Chisel
        if (FP16 != 0) begin
            TensorDotProductUnit fedp (
              .clock (clk),
              .reset (reset),
              .io_in_valid      (fedp_fire_in),
              .io_in_bits_a_0   (A_frag[d_row][0][15: 0]),
              .io_in_bits_a_1   (A_frag[d_row][0][31:16]),
              .io_in_bits_a_2   (A_frag[d_row][1][15: 0]),
              .io_in_bits_a_3   (A_frag[d_row][1][31:16]),
              .io_in_bits_b_0   (B_frag[0][d_col_sel][15: 0]),
              .io_in_bits_b_1   (B_frag[0][d_col_sel][31:16]),
              .io_in_bits_b_2   (B_frag[1][d_col_sel][15: 0]),
              .io_in_bits_b_3   (B_frag[1][d_col_sel][31:16]),
              .io_in_bits_c     (C_frag[d_row][d_col_sel]),
              .io_stall         (stall),
              .io_out_valid     (fedp_valids[i]),
              .io_out_bits_data (D_half[i])
            );
        end else begin
            TensorDotProductUnit fedp (
              .clock (clk),
              .reset (reset),
              .io_in_valid      (fedp_fire_in),
              .io_in_bits_a_0   (A_frag[d_row][0]),
              .io_in_bits_a_2   (A_frag[d_row][1]),
              .io_in_bits_b_0   (B_frag[0][d_col_sel]),
              .io_in_bits_b_2   (B_frag[1][d_col_sel]),
              .io_in_bits_c     (C_frag[d_row][d_col_sel]),
              .io_stall         (stall),
              .io_out_valid     (fedp_valids[i]),
              .io_out_bits_data (D_half[i])
            );
        end
    end

    assign valid_out = fedp_valid_out && (substep_out == 1'b1);
endmodule

module VX_tensor_reg #(
    parameter DATAW = 1
) (
    input wire clk,
    input wire reset,
    input wire [DATAW-1:0] d,
    input wire en,
    output reg [DATAW-1:0] q
);
    always @(posedge clk) begin
        if (reset) begin
            q <= 0;
        end else if (en) begin
            q <= d;
        end
    end
endmodule
*/

/*module VX_tensor_threadgroup #(
    parameter FP16 = 0
) (
    input clk,
    input reset,

    input valid_in,
    output ready_in,
    input stall,
    // all *_frag are row-major
    // (m,n,k) = (2,4,2)
    input [31:0] A_frag [1:0][1:0],
    input [31:0] B_frag [1:0][3:0],
    input [31:0] C_frag [1:0][3:0],

    output valid_out,
    output [31:0] D_frag [1:0][3:0]
);
    wire fedp_valid_in;
    wire fedp_ready_in;
    wire fedp_fire_in  = fedp_valid_in && fedp_ready_in;

    wire [3:0] fedp_valids;
    wire fedp_valid_out = &(fedp_valids);
    wire fedp_ready_out = !stall;
    wire fedp_fire_out  = fedp_valid_out && fedp_ready_out;

    assign fedp_valid_in = valid_in;
    // coupled ready; backpressure immediately reaches input from output
    assign fedp_ready_in = fedp_ready_out;

    // The dot product units take 2 cycles to finish computing A_frag * B_frag
    // + C_frag.  substep_in and substep_out keeps track of which cycle they're at
    // & when they have to pop from input queue and push to result queue.
    // Note that substep is different from the "step" defined in the HMMA
    // instruction set; it is similar in meaning to the substeps in
    // VX_tensor_octet.
    //
    // substep_in == 0: FEDP uses first half from operand buffer
    // substep_in == 1: FEDP uses last half and pops from operand buffer
    wire substep_in;
    // substep_out == 0: FEDP produces first half of D_frag
    // substep_out == 1: FEDP produces last half of D_frag and asserts valid_out
    wire substep_out;
    assign ready_in = fedp_fire_in && (substep_in == 1'b1);

    wire  [31:0] D_reg [3:0];
    reg   [31:0] D_reg_n [3:0];

    // staging buffer that latches the D half-tile
    VX_tensor_reg #(.DATAW(32)) staging_d [3:0] (
        .clk(clk),
        .reset(reset),
        .d(D_reg_n),
        .en(1'b1),
        .q(D_reg)
    );

    // latch the first-half result of D_frag
    wire  [31:0] D_half [3:0];
    integer j;
    always @(*) begin
        for (j = 0; j < 4; j = j + 1) begin
            D_reg_n[j] = D_reg[j];
        end
        if (fedp_fire_out) begin
            if (substep_out == 1'b0) begin
                for (j = 0; j < 4; j = j + 1) begin
                    D_reg_n[j] = D_half[j];
                end
            end
        end
    end

    // flip substep_in/substep_out on FEDP in/out fire, respectively
    VX_tensor_reg #(.DATAW(1)) staging_substep_in (
        .clk(clk),
        .reset(reset),
        .d(~substep_in),
        .en(fedp_fire_in),
        .q(substep_in)
    );
    VX_tensor_reg #(.DATAW(1)) staging_substep_out (
        .clk(clk),
        .reset(reset),
        .d(~substep_out),
        .en(fedp_fire_out),
        .q(substep_out)
    );

    // TODO: Instead of latching half-result and constructing a full D tile,
    // we should be able to send these half fragments down to commit stage
    // immediately, saving flop space
    assign D_frag[0][0] = D_reg[0];
    assign D_frag[0][2] = D_reg[1];
    assign D_frag[1][0] = D_reg[2];
    assign D_frag[1][2] = D_reg[3];
    assign D_frag[0][1] = D_half[0];
    assign D_frag[0][3] = D_half[1];
    assign D_frag[1][1] = D_half[2];
    assign D_frag[1][3] = D_half[3];

    wire [15:0] A_frag_fp16 [1:0][3:0];
    wire [15:0] B_frag_fp16 [3:0][3:0];

    // 4 FEDPs per threadgroup
    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1) begin : gen_label
        // Determine which elements in the D matrix the dot-product units get
        // mapped to.
        //
        // At substep == 0, the 0th and 2nd columns of D begins compute;
        // At substep == 1, the 1st and 3rd columns of D begins compute.
        // There are two row elements for each column, rounding out to
        // 4 elements computed by 4 FEDPs at every cycle
        // (see Figure 10(b)).

        //     i    : 0, 1, 2, 3
        // d_row    : 0, 0, 1, 1
        // d_col    : 0, 2, 0, 2
        // d_col_sel: 1, 3, 1, 3
        //
        // substep 0:
        // [ 0 x 2 x ] (0~3 is 'i', the dpu id)
        // [ 1 x 3 x ]
        // substep 1:
        // [ x 0 x 2 ]
        // [ x 1 x 3 ]
        wire [31:0] d_row = i / 2;
        wire [31:0] d_col = (i % 2) * 2;
        wire [31:0] d_col_sel = (substep_in == 1'b0) ? d_col : (d_col + 1);

        // Dot product (FEDP) unit generated from Chisel
        if (FP16 != 0) begin
            TensorDotProductUnit fedp (
              .clock (clk),
              .reset (reset),
              .io_in_valid      (fedp_fire_in),
              .io_in_bits_a_0   (A_frag[d_row][0][15: 0]),
              .io_in_bits_a_1   (A_frag[d_row][0][31:16]),
              .io_in_bits_a_2   (A_frag[d_row][1][15: 0]),
              .io_in_bits_a_3   (A_frag[d_row][1][31:16]),
              .io_in_bits_b_0   (B_frag[0][d_col_sel][15: 0]),
              .io_in_bits_b_1   (B_frag[0][d_col_sel][31:16]),
              .io_in_bits_b_2   (B_frag[1][d_col_sel][15: 0]),
              .io_in_bits_b_3   (B_frag[1][d_col_sel][31:16]),
              .io_in_bits_c     (C_frag[d_row][d_col_sel]),
              .io_stall         (stall),
              .io_out_valid     (fedp_valids[i]),
              .io_out_bits_data (D_half[i])
            );
        end else begin
            TensorDotProductUnit fedp (
              .clock (clk),
              .reset (reset),
              .io_in_valid      (fedp_fire_in),
              .io_in_bits_a_0   (A_frag[d_row][0]),
              .io_in_bits_a_2   (A_frag[d_row][1]),
              .io_in_bits_b_0   (B_frag[0][d_col_sel]),
              .io_in_bits_b_2   (B_frag[1][d_col_sel]),
              .io_in_bits_c     (C_frag[d_row][d_col_sel]),
              .io_stall         (stall),
              .io_out_valid     (fedp_valids[i]),
              .io_out_bits_data (D_half[i])
            );
        end
    end


endgenerate

    assign valid_out = fedp_valid_out && (substep_out == 1'b1);
endmodule

module VX_tensor_reg #(
    parameter DATAW = 1
) (
    input wire clk,
    input wire reset,
    input wire [DATAW-1:0] d,
    input wire en,
    output reg [DATAW-1:0] q
);
    always @(posedge clk) begin
        if (reset) begin
            q <= 0;
        end else if (en) begin
            q <= d;
        end
    end
endmodule

module TensorDotProductUnit (
    input  wire         clock,           // Clock signal
    input  wire         reset,           // Active-high reset
    input  wire         io_in_valid,     // Input valid signal
    input  wire [15:0]  io_in_bits_a_0,  // FP16 A operand (part 0)
    input  wire [15:0]  io_in_bits_a_1,  // FP16 A operand (part 1)
    input  wire [15:0]  io_in_bits_a_2,  // FP16 A operand (part 2)
    input  wire [15:0]  io_in_bits_a_3,  // FP16 A operand (part 3)
    input  wire [15:0]  io_in_bits_b_0,  // FP16 B operand (part 0)
    input  wire [15:0]  io_in_bits_b_1,  // FP16 B operand (part 1)
    input  wire [15:0]  io_in_bits_b_2,  // FP16 B operand (part 2)
    input  wire [15:0]  io_in_bits_b_3,  // FP16 B operand (part 3)
    input  wire [31:0]  io_in_bits_c,    // FP32 C operand (accumulator)
    input  wire         io_stall,        // Stall signal (backpressure)
    output wire         io_out_valid,    // Output valid signal
    output wire [31:0]  io_out_bits_data // FP32 result (A * B + C)
);

    // Internal signals for pipelined computation
    reg  [31:0] partial_result_0, partial_result_1;
    //reg  [31:0] partial_result_2, partial_result_3;
    reg  [31:0] sum_ab;
    reg  [31:0] result;

    // Pipeline registers for valid signals
    reg  valid_stage1, valid_stage2;

    // FP16 to FP32 conversion (if needed)
    wire [31:0] a0_fp32, a1_fp32 ; // a2_fp32, a3_fp32;
    wire [31:0] b0_fp32, b1_fp32 ; // b2_fp32, b3_fp32;

    assign a0_fp32 = {io_in_bits_a_1,io_in_bits_a_0};
    assign a1_fp32 = {io_in_bits_a_3,io_in_bits_a_2};

    assign b0_fp32 = {io_in_bits_b_1,io_in_bits_b_0};
    assign b1_fp32 = {io_in_bits_b_3,io_in_bits_b_2};

    
    // Pipeline Stage 1: Multiply A and B elements
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            partial_result_0 <= 32'b0;
            partial_result_1 <= 32'b0;
            //partial_result_2 <= 32'b0;
            //partial_result_3 <= 32'b0;
            valid_stage1     <= 1'b0;
        end else if (!io_stall) begin
            partial_result_0 <= a0_fp32 * b0_fp32;
            partial_result_1 <= a1_fp32 * b1_fp32;
    //        partial_result_2 <= a2_fp32 * b2_fp32;
    //        partial_result_3 <= a3_fp32 * b3_fp32;
    
            valid_stage1     <= io_in_valid;
        end
    end

    // Pipeline Stage 2: Sum partial products
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            sum_ab       <= 32'b0;
            valid_stage2 <= 1'b0;
        end else if (!io_stall) begin
            sum_ab       <= partial_result_0 + partial_result_1;
        //                   partial_result_2 + partial_result_3;
            valid_stage2 <= valid_stage1;
        end
    end

    // Pipeline Stage 3: Accumulate with C
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            result <= 32'b0;
        end else if (!io_stall) begin
            result <= sum_ab + io_in_bits_c;
            //$display("a0_fp32 %d, a1_fp32 %d, b0_fp32 %d, b1_fp32 %d, partial_result_0 %h, partial_result_1 %h ,  sum_ab %d,  result %d", a0_fp32, a1_fp32,b0_fp32, b1_fp32, partial_result_0,partial_result_1, sum_ab, result);
        end
    end

    // Output assignment
    assign io_out_valid    = valid_stage2 && !io_stall;
    assign io_out_bits_data = result;

endmodule
*/

module VX_tensor_threadgroup #(
    parameter FP16 = 0
) (
    input clk,
    input reset,

    input valid_in,
    output ready_in,
    input stall,
    // Using packed arrays for iverilog compatibility
    input [63:0] A_frag [0:1],  // 2x2x32 = 128 bits per row
    input [127:0] B_frag [0:1],   // 2x4x32 = 512 bits per row
    input [127:0] C_frag [0:1],   // 2x4x32 = 512 bits per row

    output valid_out,
    output [127:0] D_frag [0:1]  // 2x4x32 = 512 bits per row
);
    wire fedp_valid_in;
    wire fedp_ready_in;
    wire fedp_fire_in  = fedp_valid_in && fedp_ready_in;

    wire [3:0] fedp_valids;
    wire fedp_valid_out = fedp_valids[0] & fedp_valids[1] & fedp_valids[2] & fedp_valids[3];
    wire fedp_ready_out = !stall;
    wire fedp_fire_out  = fedp_valid_out && fedp_ready_out;

    reg fedp_valid_out_reg ;

    always@(posedge clk) begin
        fedp_valid_out_reg <= fedp_valid_out ;
    end

    assign fedp_valid_in = valid_in;
    assign fedp_ready_in = fedp_ready_out;

    wire substep_in;
    wire substep_out;
    assign ready_in = fedp_fire_in && (substep_in == 1'b1);

    wire  [31:0] D_reg [0:3];
    reg   [31:0] D_reg_n [0:3];

    reg fedp_fire_out_reg ; 

    always@(*) begin 
        fedp_fire_out_reg = fedp_fire_out ;
    end


    // Instantiate 4 registers for D staging
    genvar k;
    generate
    for (k = 0; k < 4; k = k + 1) begin : d_regs
        VX_tensor_reg #(.DATAW(32)) staging_d (
            .clk(clk),
            .reset(reset),
            .d(D_reg_n[k]),
            .en(1'b1),
            .q(D_reg[k])
        );
    end
    endgenerate

    always@(*)begin
        //$display("[%0t] IN: A_frag[0][0] = %h , A_frag[0][1] = %h , A_frag[1][0] = %h, A_frag[1][1] = %h", $time, A_frag[0][31:0] , A_frag[0][63:32] , A_frag[1][31:0] , A_frag[1][63:32]);
        //$display("[%0t] IN: D_half[0] = %h , D_half[1] = %h , D_half[2] = %h , D_half[3] = %h", $time, D_half[0], D_half[1], D_half[2], D_half[3]);
        //$display("[%0t] IN: a0 = %h , a1 = %h , a2 = %h , a3 = %h", $time, A_frag[d_row][15:0], A_frag[d_row][31:16], A_frag[d_row][79:64], A_frag[d_row][95:80]);
        //$display("[%0t] IN: B[0][0] = %h , B[0][1] = %h , B[1][0] = %h , B[1][1]= %h", $time, B_frag[0][31:0], B_frag[0][63:32], B_frag[1][31:0], B_frag[1][63:32]);
        //$display("[%0t] IN: d_row =%h , d_col =%h, d_col_sel=%h", $time, d_row_wire, d_col_wire , d_col_sel_wire);

    end

    //wire d_row_wire ;
    //wire [1:0] d_col_wire ;
    //wire [1:0] d_col_sel_wire ;

    //assign d_row_wire = d_row ;
    //assign d_col_wire = d_col ;
    //assign d_col_sel_wire = d_col_sel ;

    wire [31:0] D_half [0:3];
    integer j;
    always @(*) begin
        // $display("[%0t] fedp_fire_out = %h , fedp_valid=%h ,  substep_out = %h , D_half[0] = %h , D_half[1] = %h , D_half[2] = %h , D_half[3] = %h", $time, fedp_fire_out , fedp_valids, substep_out , D_half[0], D_half[1], D_half[2], D_half[3] , );            
        for (j = 0; j < 4; j = j + 1) begin
            D_reg_n[j] = D_reg[j];
        end
        if (fedp_fire_out) begin
            if (substep_out == 1'b0) begin
                for (j = 0; j < 4; j = j + 1) begin
                    D_reg_n[j] = D_half[j];
                end
            end
        end
    end

    VX_tensor_reg #(.DATAW(1)) staging_substep_in (
        .clk(clk),
        .reset(reset),
        .d(~substep_in),
        .en(fedp_fire_in),
        .q(substep_in)
    );

    VX_tensor_reg #(.DATAW(1)) staging_substep_out (
        .clk(clk),
        .reset(reset),
        .d(~substep_out),
        .en(fedp_fire_out),
        .q(substep_out)
    );

    // Assign outputs using packed array indexing
    /*assign D_frag[0][31:0]   = D_reg[0];
    assign D_frag[0][95:64] = D_reg[1];
    assign D_frag[1][31:0]   = D_reg[2];
    assign D_frag[1][95:64] = D_reg[3];
    assign D_frag[0][63:32]  = D_half[0];
    assign D_frag[0][127:96] = D_half[1];
    assign D_frag[1][63:32]  = D_half[2];
    assign D_frag[1][127:96] = D_half[3];
    */

    assign D_frag[0][63:32] = D_reg[0];
    assign D_frag[1][63:32] = D_reg[1];
    assign D_frag[0][127:96] = D_reg[2];
    assign D_frag[1][127:96] = D_reg[3];
    
    assign D_frag[0][31:0]  = D_half[0];
    assign D_frag[1][31:0] = D_half[1];
    assign D_frag[0][95:64]  = D_half[2];
    assign D_frag[1][95:64] = D_half[3];


    // 4 FEDPs per threadgroup
    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1) begin : gen_label
        wire [0:0] d_row = i[0];  // 0 or 1
        wire [1:0] d_col = (i[1]) ? 2 : 0;  // 0 or 2
        wire [1:0] d_col_sel = (substep_in == 1'b0) ? d_col : (d_col + 1);

        
        if (FP16 != 0) begin
            // Extract 16-bit elements from packed arrays
            wire [15:0] a0 = A_frag[d_row][15:0];
            wire [15:0] a1 = A_frag[d_row][31:16];
            wire [15:0] a2 = A_frag[d_row][79:64];
            wire [15:0] a3 = A_frag[d_row][95:80];
            
            wire [15:0] b0 = B_frag[0][d_col_sel*32 +: 16];
            wire [15:0] b1 = B_frag[0][d_col_sel*32 + 16 +: 16];
            wire [15:0] b2 = B_frag[1][d_col_sel*32 +: 16];
            wire [15:0] b3 = B_frag[1][d_col_sel*32 + 16 +: 16];
            
            wire [31:0] c = C_frag[d_row][d_col_sel*32 +: 32];

            TensorDotProductUnit fedp (
                .clock(clk),
                .reset(reset),
                .i_value(i),
                .io_in_valid(fedp_fire_in),
                .io_in_bits_a_0(a0),
                .io_in_bits_a_1(a1),
                .io_in_bits_a_2(a2),
                .io_in_bits_a_3(a3),
                .io_in_bits_b_0(b0),
                .io_in_bits_b_1(b1),
                .io_in_bits_b_2(b2),
                .io_in_bits_b_3(b3),
                .io_in_bits_c(c),
                .io_stall(stall),
                .io_out_valid(fedp_valids[i]),
                .io_out_bits_data(D_half[i])
            );
        end else begin
            // Full 32-bit mode
            wire [31:0] a0 = A_frag[d_row][31:0];
            wire [31:0] a2 = A_frag[d_row][63:32];
            
            wire [31:0] b0 = B_frag[0][d_col_sel*32 +: 31];
            wire [31:0] b2 = B_frag[1][d_col_sel*32 +: 31];
            
            wire [31:0] c = C_frag[d_row][d_col_sel*32 +: 31];

            TensorDotProductUnit fedp (
                .clock(clk),
                .reset(reset),
                .i_value(i),
                .d_row(d_row),
                .d_col_sel(d_col_sel),
                .io_in_valid(fedp_fire_in),
                .io_in_bits_a_0(a0[15:0]),
                .io_in_bits_a_1(a0[31:16]),
                .io_in_bits_a_2(a2[15:0]),
                .io_in_bits_a_3(a2[31:16]),
                .io_in_bits_b_0(b0[15:0]),
                .io_in_bits_b_1(b0[31:16]),
                .io_in_bits_b_2(b2[15:0]),
                .io_in_bits_b_3(b2[31:16]),
                .io_in_bits_c(c),
                .io_stall(stall),
                .io_out_valid(fedp_valids[i]),
                .io_out_bits_data(D_half[i]),
                .valid_out(valid_out)
            );
        end
    end
    endgenerate

    assign valid_out = fedp_valid_out_reg && (substep_out == 1'b1);
endmodule

module VX_tensor_reg #(
    parameter DATAW = 1
) (
    input clk,
    input reset,
    input [DATAW-1:0] d,
    input en,
    output reg [DATAW-1:0] q
);
    always @(posedge clk) begin
        if (reset) begin
            q <= 0;
        end else if (en) begin
            q <= d;
        end
        //$display("[%0t] Inside tensor_reg,  d= %h , q = %h " , $time, d , q);
    end
endmodule

module TensorDotProductUnit (
    input  wire         clock,
    input  wire         reset,
    input wire  [1:0]   i_value,
    input  wire         d_row,
    input wire [1:0]    d_col_sel, 
    input  wire         io_in_valid,
    input  wire [15:0]  io_in_bits_a_0,
    input  wire [15:0]  io_in_bits_a_1,
    input  wire [15:0]  io_in_bits_a_2,
    input  wire [15:0]  io_in_bits_a_3,
    input  wire [15:0]  io_in_bits_b_0,
    input  wire [15:0]  io_in_bits_b_1,
    input  wire [15:0]  io_in_bits_b_2,
    input  wire [15:0]  io_in_bits_b_3,
    input  wire [31:0]  io_in_bits_c,
    input  wire         io_stall,
    output wire         io_out_valid,
    output wire [31:0]  io_out_bits_data,
    output wire  valid_out
);
    reg  [31:0] partial_result_0, partial_result_1;
    reg  [31:0] sum_ab;
    reg  [31:0] result;
    reg  valid_stage1, valid_stage2;

    // FP16 to FP32 conversion (packing)
    wire [31:0] a0_fp32 = {io_in_bits_a_1, io_in_bits_a_0}; // a0
    wire [31:0] a1_fp32 = {io_in_bits_a_3, io_in_bits_a_2}; // a2
    wire [31:0] b0_fp32 = {io_in_bits_b_1, io_in_bits_b_0};
    wire [31:0] b1_fp32 = {io_in_bits_b_3, io_in_bits_b_2};

    // Pipeline Stage 1: Multiply
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            partial_result_0 <= 0;
            partial_result_1 <= 0;
            valid_stage1 <= 0;
        end else if (!io_stall) begin
            partial_result_0 <= a0_fp32 * b0_fp32;
            partial_result_1 <= a1_fp32 * b1_fp32;
            valid_stage1 <= io_in_valid;
        end
    end

    // Pipeline Stage 2: Sum
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            sum_ab <= 0;
            valid_stage2 <= 0;
        end else if (!io_stall) begin
            sum_ab <= partial_result_0 + partial_result_1;
            valid_stage2 <= valid_stage1;
        end
    end

    // Pipeline Stage 3: Accumulate
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            result <= 0;
        end else if (!io_stall) begin
            result <= sum_ab + io_in_bits_c;
            //$display("[%0t] i_value = %h , d_row = %h , d_col_sel = %h, a0_fp32 =%h a1_fp32 =%h, b0_fp32 =%h b1_fp32 =%h , io_out_valid=%h, valid_out = %h ", $time , i_value,  d_row, d_col_sel, a0_fp32 , a1_fp32, b0_fp32 , b1_fp32, io_out_valid, valid_out );
            //$display("[%0t] io_in_bits_a_3 =%h, io_in_bits_a_2= %h, a1_fp32 =%h", $time , io_in_bits_a_3, io_in_bits_a_2, a1_fp32 );
            //$display("[%0t] a0_fp32 =%h, b1_fp32 =%h, partial_result_1 =%h ,sum_ab =%h,  result =%h", $time , a0_fp32, b1_fp32, partial_result_1, sum_ab, result);
        end
    end

    assign io_out_valid = valid_stage2 && !io_stall;
    assign io_out_bits_data = result;
endmodule

