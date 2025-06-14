`timescale 1ns/1ps

module VX_tensor_reg_tb;

    // Parameters
    parameter DATAW = 8; // Test with 8-bit width (can be changed)
    parameter TEST_CYCLES = 10;

    // Signals
    reg clk = 0;
    reg reset = 1;
    reg [DATAW-1:0] d;
    reg en;
    wire [DATAW-1:0] q;

    // Clock generation
    always #5 clk = ~clk;

    // Instantiate the DUT
    VX_tensor_reg #(
        .DATAW(DATAW)
    ) dut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .en(en),
        .q(q)
    );

    // Test stimulus
    initial begin
        $dumpfile("vx_tensor_reg.vcd");
        $dumpvars(0, VX_tensor_reg_tb);
        
        // Initialize inputs
        d = 0;
        en = 0;
        
        // Release reset after 20ns
        #20 reset = 0;
        
        $display("Starting VX_tensor_reg testbench");
        
        // Test 1: Basic write operation
        $display("[%0t] Test 1: Basic write operation", $time);
        d = 8'hA5;
        en = 1;
        #10; // Wait for clock edge
        
        if (q !== 8'hA5) begin
            $display("ERROR: Expected q = 8'hA5, got %h", q);
            $finish;
        end
        
        // Test 2: Enable control
        $display("[%0t] Test 2: Enable control", $time);
        d = 8'h5A;
        en = 0;
        #10;
        
        if (q !== 8'hA5) begin
            $display("ERROR: Expected q to remain 8'hA5 when en=0, got %h", q);
            $finish;
        end
        
        en = 1;
        #10;
        
        if (q !== 8'h5A) begin
            $display("ERROR: Expected q = 8'h5A, got %h", q);
            $finish;
        end
        
        // Test 3: Reset functionality
        $display("[%0t] Test 3: Reset functionality", $time);
        reset = 1;
        #10;
        
        if (q !== 0) begin
            $display("ERROR: Expected q = 0 after reset, got %h", q);
            $finish;
        end
        
        // Test 4: Multiple writes
        $display("[%0t] Test 4: Multiple writes", $time);
        reset = 0;
        en = 1;
        
        for (int i = 0; i < TEST_CYCLES; i++) begin
            d = $random;
            #10;
            
            if (q !== d) begin
                $display("ERROR: At cycle %0d, expected q = %h, got %h", i, d, q);
                $finish;
            end
        end
        
        // Test 5: Edge cases
        $display("[%0t] Test 5: Edge cases", $time);
        en = 1;
        d = {DATAW{1'b1}}; // All ones
        #10;
        
        if (q !== {DATAW{1'b1}}) begin
            $display("ERROR: Expected all ones, got %h", q);
            $finish;
        end
        
        d = 0; // All zeros
        #10;
        
        if (q !== 0) begin
            $display("ERROR: Expected all zeros, got %h", q);
            $finish;
        end
        
        $display("All tests passed!");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("[%0t] clk=%b reset=%b en=%b d=%h q=%h", 
                $time, clk, reset, en, d, q);
    end

endmodule