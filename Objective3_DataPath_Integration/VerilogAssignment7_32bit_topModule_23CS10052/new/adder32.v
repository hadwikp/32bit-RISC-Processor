`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2025 14:48:36
// Design Name: 
// Module Name: adder32
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


module adder32(sum,cout,overflow,a,b);
output [31:0] sum;
output cout,overflow;
input [31:0] a,b;

wire [32:0]c1;
assign c1[0] = 0;
genvar i;

generate
    for(i=0;i<32;i=i+1) begin
        fullAdder ADD(sum[i],c1[i+1],a[i],b[i],c1[i]);    
    end
endgenerate

assign cout = c1[32];
assign overflow = c1[31]^c1[32];
endmodule
