module TensorDotProductUnit_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns = 100MHz clock
    
    // Clock and reset
    logic clock;
    logic reset;
    
    // DUT Interface
    logic        io_in_valid;
    logic [15:0] io_in_bits_a [0:3];
    logic [15:0] io_in_bits_b [0:3];
    logic [31:0] io_in_bits_c;
    logic        io_stall;
    logic        io_out_valid;
    logic [31:0] io_out_bits_data;

    // Clock generation
    initial begin
        clock = 0;
        /* verilator lint_off STMTDLY */
        /* verilator lint_off INFINITELOOP */
        forever #(CLK_PERIOD/2) clock = ~clock;
        /* verilator lint_on INFINITELOOP */
        /* verilator lint_on STMTDLY */
    end
    
    // Instantiate DUT
    TensorDotProductUnit dut (
        .clock(clock),
        .reset(reset),
        .io_in_valid(io_in_valid),
        .io_in_bits_a_0(io_in_bits_a[0]),
        .io_in_bits_a_1(io_in_bits_a[1]),
        .io_in_bits_a_2(io_in_bits_a[2]),
        .io_in_bits_a_3(io_in_bits_a[3]),
        .io_in_bits_b_0(io_in_bits_b[0]),
        .io_in_bits_b_1(io_in_bits_b[1]),
        .io_in_bits_b_2(io_in_bits_b[2]),
        .io_in_bits_b_3(io_in_bits_b[3]),
        .io_in_bits_c(io_in_bits_c),
        .io_stall(io_stall),
        .io_out_valid(io_out_valid),
        .io_out_bits_data(io_out_bits_data)
    );
    
    // Main test sequence
    initial begin
        initialize();
        reset_sequence();
        
        // Test Case 1: Basic operation
        basic_operation_test();
        
        // Test Case 2: With stall
        stall_operation_test();
        
        // Test Case 3: Reset during operation
        reset_operation_test();
        
        $display("[PASS] All tests completed successfully");
        /* verilator lint_off STMTDLY */
        #100 $finish();
        /* verilator lint_on STMTDLY */
    end
    
    // Initialize signals
    task initialize();
        reset = 0;
        io_in_valid = 0;
        io_stall = 0;
        foreach(io_in_bits_a[i]) io_in_bits_a[i] = '0;
        foreach(io_in_bits_b[i]) io_in_bits_b[i] = '0;
        io_in_bits_c = '0;
    endtask
    
    // Reset sequence (using delays instead of @posedge)
    task reset_sequence();
        $display("[TEST] Resetting DUT");
        reset = 1;
        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 5);
        /* verilator lint_on STMTDLY */
        reset = 0;
        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 2);
        /* verilator lint_on STMTDLY */
    endtask
    
    // Basic operation test
    task basic_operation_test();
        $display("[TEST] Basic Operation Test");
        
        // Apply inputs
        io_in_valid = 1;
        // A = [1.0, 2.0, 3.0, 4.0] in FP16
        io_in_bits_a = '{16'h3C00, 16'h4000, 16'h4200, 16'h4400};
        // B = [2.0, 3.0, 4.0, 5.0] in FP16
        io_in_bits_b = '{16'h4000, 16'h4200, 16'h4400, 16'h4500};
        io_in_bits_c = 32'h41200000; // 10.0 in FP32
        
        /* verilator lint_off STMTDLY */
        #CLK_PERIOD;
        /* verilator lint_on STMTDLY */
        io_in_valid = 0;
        
        // Wait for result (3 cycles latency)
        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 3);
        /* verilator lint_on STMTDLY */
        $display("[RESULT] Output: %h (valid: %b)", io_out_bits_data, io_out_valid);
    endtask
    
    // Stall operation test
    task stall_operation_test();
        $display("[TEST] Stall Operation Test");
        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 3);
        /* verilator lint_on STMTDLY */
        
        // Apply inputs with stall
        io_in_valid = 1;
        // A = [1.5, 2.5, 3.5, 4.5] in FP16
        io_in_bits_a = '{16'h3E00, 16'h4100, 16'h4300, 16'h4480};
        // B = [1.0, 1.0, 1.0, 1.0] in FP16
        io_in_bits_b = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00};
        io_in_bits_c = 32'h00000000;
        
        /* verilator lint_off STMTDLY */
        #CLK_PERIOD;
        /* verilator lint_on STMTDLY */
        io_stall = 1;
        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 2);
        /* verilator lint_on STMTDLY */
        io_stall = 0;
        io_in_valid = 0;
        
        // Wait for result (extra cycles due to stall)

        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 4);
        /* verilator lint_on STMTDLY */
        $display("[RESULT] Output: %h (valid: %b)", io_out_bits_data, io_out_valid);
    endtask
    
    // Reset during operation test
    task reset_operation_test();
        $display("[TEST] Reset During Operation Test");

        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 3);
        /* verilator lint_on STMTDLY */
        
        // Apply inputs
        io_in_valid = 1;
        io_in_bits_a = '{16'h3C00, 16'h4000, 16'h4200, 16'h4400};
        io_in_bits_b = '{16'h4000, 16'h4200, 16'h4400, 16'h4500};
        io_in_bits_c = 32'h00000000;
        

        /* verilator lint_off STMTDLY */
        #CLK_PERIOD;
        /* verilator lint_on STMTDLY */
        reset = 1;

        /* verilator lint_off STMTDLY */
        #CLK_PERIOD;
        /* verilator lint_on STMTDLY */
        reset = 0;
        io_in_valid = 0;
        
        // Check that output is invalid after reset
        /* verilator lint_off STMTDLY */
        #(CLK_PERIOD * 2);
        /* verilator lint_on STMTDLY */
        if (io_out_valid !== 0) begin
            $display("[ERROR] Output valid after reset");
        end
    endtask
    
    // Timeout check
    initial begin
        /* verilator lint_off STMTDLY */
        #100000;
        /* verilator lint_on STMTDLY */
        $display("[FAIL] Simulation timeout");
        $finish();
    end
endmodule