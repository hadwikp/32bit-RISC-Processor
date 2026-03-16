`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2025 16:32:09
// Design Name: 
// Module Name: HAM
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


module HAM(out,in);
output reg [31:0] out;
input [31:0] in;

integer i;

always @(*)begin
    out = 32'd0;
    for (i =0;i<32;i = i+1)begin
        //if (in[i] == 1)out = out + 1;
        out = out +in[i];
    end
end

endmodule
