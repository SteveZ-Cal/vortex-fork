// Copyright © 2019-2023
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`include "VX_platform.vh"

`TRACING_OFF
module VX_lzc #(
    parameter N       = 2,
    parameter REVERSE = 0,  // 0 -> leading zero, 1 -> trailing zero,
    parameter LOGN    = `LOG2UP(N)
) (
    input  wire [N-1:0]    data_in,
    output wire [LOGN-1:0] data_out,
    output logic           valid_out
);
    if (N == 1) begin : genblk1

        `UNUSED_PARAM (REVERSE)

        assign data_out  = '0;
        assign valid_out = data_in;

    end else begin : genblk2

        wire [N-1:0][LOGN-1:0] indices;
    
        for (genvar i = 0; i < N; ++i) begin : genblk3
            assign indices[i] = REVERSE ? LOGN'(i) : LOGN'(N-1-i);
        end
    
        VX_find_first #(
            .N       (N),
            .DATAW   (LOGN),
            .REVERSE (!REVERSE)
        ) find_first (        
            .data_in   (indices),
            .valid_in  (data_in),
            .data_out  (data_out),
            .valid_out (valid_out)
        );

    end
  
endmodule

module VX_lzc_rr #(
    parameter N       = 2
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire [N-1:0]          data_in,
    output logic [$clog2(N)-1:0] data_out,
    //output logic data_out,
    output logic                 valid_out
);

    logic [$clog2(N)-1:0] current_idx;
    //logic current_idx;

/*    always @(*) begin
        integer i;
        data_out = 0;
        for (i = 0; i < N; i += 1) begin
            if (data_in[(current_idx + i) % N] == 1'b1) begin
                data_out = (current_idx + i) % N;
                break;
            end
        end
    end
*/
    always @(*) begin
    data_out = '0; // Default assignment
    for (int i = 0; i < N; i++) begin
        // Cast current_idx to match integer size or use same-width arithmetic
        automatic logic [$clog2(N)-1:0] sum = current_idx + i[$clog2(N)-1:0];
        automatic logic [$clog2(N)-1:0] index = sum % N[$clog2(N)-1:0];
        
        if (data_in[index]) begin
            data_out = index;
            break;
            end
        end
    end

    assign valid_out = |data_in;

/*    always @(posedge clk) begin
        if (reset) begin
            current_idx <= 0;
        end else begin
            if (valid_out) begin
                current_idx <= (current_idx + 1) % N;
            end
        end
    end
*/
    always @(posedge clk) begin
    if (reset) begin
        current_idx <= '0;  // Auto-width zero
    end else if (valid_out) begin
        current_idx <= (current_idx + 1'(1)) % $bits(current_idx)'(N);
    end
    end

endmodule
`TRACING_ON
