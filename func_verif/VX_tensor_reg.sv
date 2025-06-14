`timescale 1ns/1ps

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