`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2025 15:04:37
// Design Name: 
// Module Name: sub32
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


module sub32(diff,cout,overflow,a,b);
output [31:0]diff;
output cout;
input [31:0] a,b;
output overflow;

wire [32:0] c1;
wire [31:0] new_b;
assign new_b = ~b;
assign c1[0] = 1;
genvar i ;
generate
    for(i=0;i<32;i=i+1) begin
        fullAdder SUB(diff[i],c1[i+1],a[i],new_b[i],c1[i]);
    end
endgenerate

assign cout= c1[32];
assign overflow = c1[32]^c1[31];
  
endmodule
