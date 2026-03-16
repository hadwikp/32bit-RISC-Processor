`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2025 15:16:06
// Design Name: 
// Module Name: incr
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


module incr(out,in);
input [31:0] in;
output [31:0] out;
wire t,of;
adder32 ADD(out,t,of,in,32'b1);

endmodule
