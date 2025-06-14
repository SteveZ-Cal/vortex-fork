`include "VX_fpu_define.vh"

module VX_tensor_tb(
    input clk,
    input reset,

    input valid_in,
    input [3:0][1:0][31:0] A_tile,
    input [1:0][3:0][31:0] B_tile,
    input [3:0][3:0][31:0] C_tile,

    output valid_out,
    output [3:0][3:0][31:0] D_tile
);

    VX_tensor_dpu #() tensor_core (
        .clk(clk),
        .reset(reset),

        .stall(1'b0),

        .valid_in(valid_in),
        .A_tile(A_tile),
        .B_tile(B_tile),
        .C_tile(C_tile),

        .valid_out(valid_out),
        .D_tile(D_tile)
    );
endmodule