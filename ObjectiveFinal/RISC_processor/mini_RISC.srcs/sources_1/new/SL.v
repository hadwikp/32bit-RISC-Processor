`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2025 15:25:31
// Design Name: 
// Module Name: SL
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


module SL(out,in,shamt);
input [31:0] in;
input [4:0] shamt;
output [31:0] out;

assign out = in <<shamt;
endmodule
