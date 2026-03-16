`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2025 16:21:13
// Design Name: 
// Module Name: SGT
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


module SGT(out,a,b);
input signed [31:0]a,b;
output [31:0]out;

assign out = (a > b) ? 32'd1 : 32'd0; 
endmodule