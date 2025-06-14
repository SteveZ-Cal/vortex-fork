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
