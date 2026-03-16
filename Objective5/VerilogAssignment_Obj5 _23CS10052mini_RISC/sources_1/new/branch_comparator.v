`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 15:45:55
// Design Name: 
// Module Name: branch_comparator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module branch_comparator(isBranch,bOp,reg_data_in);

output reg isBranch;
input wire [2:0] bOp;
input wire [31:0] reg_data_in;

wire is_neg = reg_data_in[31];
wire is_zero = (reg_data_in == 32'b0);

always @(*) begin
    isBranch = 1'b0; // Default to not branching
    case(bOp)
        3'b100: isBranch = 1'b1;         // BR (Unconditional)
        3'b101: isBranch = is_neg;       // BMI (Branch if Negative)
        3'b110: isBranch = ~is_neg & ~is_zero;      // BPL (Branch if Positive or Zero)
        3'b111: isBranch = is_zero;      // BZ (Branch if Zero)
        default: isBranch = 1'b0;        // Not a branch instruction
    endcase
end


endmodule
