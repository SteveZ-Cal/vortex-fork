`timescale 1ns/1ps

module tb_VX_tensor_threadgroups;

    // Parameters
    parameter FP16 = 0; // Testing FP32 mode
    parameter CLK_PERIOD = 10;

    // Inputs
    reg clk;
    reg reset;
    reg valid_in;
    reg [3:0][1:0][31:0] A_tile;
    reg [1:0][3:0][31:0] B_tile;
    reg [3:0][3:0][31:0] C_tile;
    reg [31:0] wid;
    reg ready_out;

    // Outputs
    wire ready_in;
    wire valid_out;
    wire [3:0][3:0][31:0] D_tile;
    wire [31:0] D_wid;

    // Instantiate DUT
    VX_tensor_threadgroups #(
        .FP16(FP16),
        .ISW(32),
        .OCTET(1)
    ) dut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .A_tile(A_tile),
        .B_tile(B_tile),
        .C_tile(C_tile),
        .wid(wid),
        .valid_out(valid_out),
        .ready_out(ready_out),
        .D_tile(D_tile),
        .D_wid(D_wid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        valid_in = 0;
        ready_out = 1;
        wid = 0;
        A_tile = 0;
        B_tile = 0;
        C_tile = 0;
        
        // Reset
        #100;
        reset = 0;
        #100;

        // Test Case 1: Simple matrix multiplication
        $display("\nTest Case 1: Basic Matrix Operation");
        wid = 32'h1;
        A_tile = {<<32{
            32'h00000001, 32'h00000002,  // Row 0: [1, 2]
            32'h00000003, 32'h00000004,  // Row 1: [3, 4]
            32'h00000005, 32'h00000006,  // Row 2: [5, 6]
            32'h00000007, 32'h00000008   // Row 3: [7, 8]
        }};
        
        B_tile = {<<32{
            32'h00000001, 32'h00000000, 32'h00000000, 32'h00000000,  // Row 0: [1, 0, 0, 0]
            32'h00000000, 32'h00000001, 32'h00000000, 32'h00000000   // Row 1: [0, 1, 0, 0]
        }};
        
        C_tile = 0; // Zero matrix
        
        valid_in = 1;
        wait(valid_out);
        #10;
        valid_in = 0;
        
        // Display results
        $display("D_tile[0] = %h %h %h %h", D_tile[0][0], D_tile[0][1], D_tile[0][2], D_tile[0][3]);
        $display("D_tile[1] = %h %h %h %h", D_tile[1][0], D_tile[1][1], D_tile[1][2], D_tile[1][3]);
        $display("D_tile[2] = %h %h %h %h", D_tile[2][0], D_tile[2][1], D_tile[2][2], D_tile[2][3]);
        $display("D_tile[3] = %h %h %h %h", D_tile[3][0], D_tile[3][1], D_tile[3][2], D_tile[3][3]);
        $display("D_wid = %h", D_wid);

        // Test Case 2: With stall
        $display("\nTest Case 2: With Stall");
        ready_out = 0; // Assert stall
        valid_in = 1;
        A_tile[3][1] = 32'h00000009; // Change one input during stall
        #50;
        ready_out = 1; // Release stall
        wait(valid_out);
        #10;
        valid_in = 0;
        
        // Display results after stall
        $display("D_tile[3][1] after stall = %h", D_tile[3][1]);

        #100;
        $display("\nTestbench completed");
        $finish;
    end

    // Waveform dumping
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_VX_tensor_threadgroups);
    end

endmodule