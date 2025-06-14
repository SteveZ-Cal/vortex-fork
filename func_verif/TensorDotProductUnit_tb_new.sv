`timescale 1ns/1ps

module TensorDotProductUnit_tb;

    // Inputs
    reg         clock;
    reg         reset;
    reg         io_in_valid;
    reg  [15:0] io_in_bits_a_0;
    reg  [15:0] io_in_bits_a_1;
    reg  [15:0] io_in_bits_a_2;
    reg  [15:0] io_in_bits_a_3;
    reg  [15:0] io_in_bits_b_0;
    reg  [15:0] io_in_bits_b_1;
    reg  [15:0] io_in_bits_b_2;
    reg  [15:0] io_in_bits_b_3;
    reg  [31:0] io_in_bits_c;
    reg         io_stall;

    // Outputs
    wire        io_out_valid;
    wire [31:0] io_out_bits_data;

    // Instantiate the Unit Under Test (UUT)
    TensorDotProductUnit uut (
        .clock(clock),
        .reset(reset),
        .io_in_valid(io_in_valid),
        .io_in_bits_a_0(io_in_bits_a_0),
        .io_in_bits_a_1(io_in_bits_a_1),
        .io_in_bits_a_2(io_in_bits_a_2),
        .io_in_bits_a_3(io_in_bits_a_3),
        .io_in_bits_b_0(io_in_bits_b_0),
        .io_in_bits_b_1(io_in_bits_b_1),
        .io_in_bits_b_2(io_in_bits_b_2),
        .io_in_bits_b_3(io_in_bits_b_3),
        .io_in_bits_c(io_in_bits_c),
        .io_stall(io_stall),
        .io_out_valid(io_out_valid),
        .io_out_bits_data(io_out_bits_data)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Test vectors
    task test_case;
        input [15:0] a0, a1, a2, a3;
        input [15:0] b0, b1, b2, b3;
        input [31:0] c;
        input [31:0] expected;
        begin
            // Apply inputs
            io_in_valid = 1;
            io_in_bits_a_0 = a0;
            io_in_bits_a_1 = a1;
            io_in_bits_a_2 = a2;
            io_in_bits_a_3 = a3;
            io_in_bits_b_0 = b0;
            io_in_bits_b_1 = b1;
            io_in_bits_b_2 = b2;
            io_in_bits_b_3 = b3;
            io_in_bits_c = c;
            
            // Wait for 4 clock cycles (pipeline depth)
            repeat(4) @(posedge clock);
            
            // Check output
            if (io_out_bits_data !== expected) begin
                $display("ERROR: Expected %h, got %h", expected, io_out_bits_data);
                $finish;
            end else begin
                $display("PASS: Input A0 = %h%h, A1 = %h%h * B0 = %h%h , B1 = %h%h + C = %h = %h", 
                         a3, a2, a1, a0, b3, b2, b1, b0, c, io_out_bits_data);
            end
            
            // Deassert valid for a cycle
            io_in_valid = 0;
            @(posedge clock);
        end
    endtask

    initial begin
        // Initialize Inputs
        clock = 0;
        reset = 1;
        io_in_valid = 0;
        io_in_bits_a_0 = 0;
        io_in_bits_a_1 = 0;
        io_in_bits_a_2 = 0;
        io_in_bits_a_3 = 0;
        io_in_bits_b_0 = 0;
        io_in_bits_b_1 = 0;
        io_in_bits_b_2 = 0;
        io_in_bits_b_3 = 0;
        io_in_bits_c = 0;
        io_stall = 0;

        // Wait for global reset
        #20;
        reset = 0;
        
        // Test case 1: Simple multiplication and addition
        // {a3,a2,a1,a0} = 0x0001000000030000
        // {b3,b2,b1,b0} = 0x0001000000010000
        // a0_fp32 = 0x00000000, a1_fp32 = 0x00000000
        // b0_fp32 = 0x00000000, b1_fp32 = 0x00000000
        // c = 0x00000001
        // Expected result: (1*1 + 2*1 + 3*1 + 4*1) + 1 = 11 (0x0000000B)
        test_case(16'h0103, 16'h0000, 16'h0101, 16'h0000,
                  16'h3001, 16'h0000, 16'h0301, 16'h0000,
                  32'h00000001, 32'h00339505);
        
        // Test case 2: Different values
        // {a3,a2,a1,a0} = 0x0002000300040005
        // {b3,b2,b1,b0} = 0x0001000200030004
        // c = 0x00000010
        // Expected result: (2*1 + 3*2 + 4*3 + 5*4) + 16 = 2+6+12+20+16 = 56 (0x00000038)
        test_case(16'h0001, 16'h0001, 16'h0123, 16'h0000,
                  16'h0032, 16'h0000, 16'h0001, 16'h0001,
                  32'h00000010, 32'd22348133);
        
        
        // Test case 3: With stall
        $display("Testing with stall...");
        io_in_valid = 1;
        io_in_bits_a_0 = 16'h0001;
        io_in_bits_a_1 = 16'h0000;
        io_in_bits_a_2 = 16'h0001;
        io_in_bits_a_3 = 16'h0000;
        io_in_bits_b_0 = 16'h0001;
        io_in_bits_b_1 = 16'h0000;
        io_in_bits_b_2 = 16'h0001;
        io_in_bits_b_3 = 16'h0000;
        io_in_bits_c = 32'h00000000;
        
        // Apply stall after first cycle
        @(posedge clock);
        io_stall = 1;
        @(posedge clock);
        @(posedge clock);
        io_stall = 0;
        
        // Wait for pipeline to flush
        repeat(4) @(posedge clock);
        
        // Check output should be 4 (1*1 + 1*1 + 1*1 + 1*1 + 0)
        if (io_out_bits_data !== 32'h00000002) begin
            $display("ERROR: Expected 4 after stall, got %h", io_out_bits_data);
            $finish;
        end else begin
            $display("PASS: Stall test completed successfully");
        end
        
        // Test case 4: Reset during operation
        $display("Testing reset...");
        io_in_valid = 1;
        @(posedge clock);
        reset = 1;
        @(posedge clock);
        reset = 0;
        
        // Output should be invalid after reset
        if (io_out_valid !== 0) begin
            $display("ERROR: Output valid after reset");
            $finish;
        end
        //*/
        
        $display("All tests passed!");
        $finish;
    end

    // Monitor
    //initial begin
    //    $monitor("At time %t: valid=%b, out=%h", $time, io_out_valid, io_out_bits_data);
    //end

endmodule