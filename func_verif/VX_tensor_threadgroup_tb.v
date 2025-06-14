`timescale 1ns/1ps

module tb_VX_tensor_threadgroup;

    // Clock and Reset
    reg clk = 0;
    reg reset = 1;
    
    // Control Signals
    reg valid_in = 0;
    wire ready_in;
    reg stall = 0;
    
    // Input Arrays (packed exactly as in module)
    reg [63:0] A_frag [0:1];  // 2x128b
    reg [127:0] B_frag [0:1];   // 2x512b
    reg [127:0] C_frag [0:1];   // 2x512b
    
    // Output
    wire [127:0] D_frag [0:1];
    wire valid_out;
    
    // Clock Generation
    always #5 clk = ~clk;
    
    // Device Under Test
    VX_tensor_threadgroup dut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .stall(stall),
        .A_frag(A_frag),
        .B_frag(B_frag),
        .C_frag(C_frag),
        .valid_out(valid_out),
        .D_frag(D_frag)
    );
    
    // Test Stimulus
    initial begin
        // Initialize VCD dump
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_VX_tensor_threadgroup);
        
        // Initialize arrays
        A_frag[0] = 0;
        A_frag[1] = 0;
        B_frag[0] = 0;
        B_frag[1] = 0;
        C_frag[0] = 0;
        C_frag[1] = 0;
        
        // Release reset
        #20 reset = 0;
        #10;
        
        // Test Case 1: Simple Matrix Operation
        $display("\nTest Case 1: Basic Operation");
        
        // A = [ [1,2], [3,4] ] (2x2)
        A_frag[0][31:0]   = 32'h00000001;  // A[0][0]
        A_frag[0][63:32]  = 32'h00000002;  // A[0][1]
        A_frag[1][31:0]   = 32'h00000003;  // A[1][0]
        A_frag[1][63:32]  = 32'h00000004;  // A[1][1]
        
        // B = [ [1,0,0,0], [0,1,0,0] ] (2x4)
        B_frag[0][31:0]    = 32'h00000001;  // B[0][0]        
        B_frag[1][63:32]   = 32'h00000001;  // B[1][1]
        
        valid_in = 1;
        
        // Wait for completion
        @(posedge valid_out);
        #10;
        valid_in = 0;

        $display("valid_out_value = %h", valid_out);
        
        // Display Results
        $display("D[0][0] = %h", D_frag[0][31:0]);
        $display("D[0][1] = %h", D_frag[0][63:32]);
        $display("D[0][2] = %h", D_frag[0][95:64]);
        $display("D[0][3] = %h", D_frag[0][127:96]);
        $display("D[1][0] = %h", D_frag[1][31:0]);
        $display("D[1][1] = %h", D_frag[1][63:32]);
        $display("D[1][2] = %h", D_frag[1][95:64]);
        $display("D[1][3] = %h", D_frag[1][127:96]);
        
        
        // Test Case 2: With Stall
        $display("\nTest Case 2: With Stall");
        stall = 1;
        valid_in = 1;
        
        // Change A[1][1] to 5
        A_frag[1][63:32] = 32'h00000005;
        
        #50;
        stall = 0;
        
        @(posedge valid_out);
        #10;
        valid_in = 0;
        
        
        $display("D[1][1] with stall = %h", D_frag[1][63:32]);
        
        
        // Finish
        #100;
        $display("\nTestbench completed");
        $finish;
    end
    
    // Monitor
    always @(posedge clk) begin
        if (valid_out) begin
            $display("[%0t] OUT: Valid=%b D[0][0]=%h", $time, valid_out, D_frag[0][31:0]);
        end
        if (valid_in && ready_in) begin
            $display("[%0t] IN: Valid=%b Ready=%b", $time, valid_in, ready_in);
            //$display("[%0t] IN: A[0][0] = %h , A[0][1] = %h , A[1][0] = %h , A[1][1]= %h", $time, A_frag[0][31:0], A_frag[0][63:32], A_frag[1][31:0], A_frag[1][63:32]);
            //$display("[%0t] IN: B[0][0] = %h , B[0][1] = %h , B[1][0] = %h , B[1][1]= %h", $time, B_frag[0][31:0], B_frag[0][63:32], B_frag[1][31:0], B_frag[1][63:32]);
        end
    end

endmodule