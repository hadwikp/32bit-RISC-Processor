`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2025 15:22:48
// Design Name: 
// Module Name: regBank
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

module regBank(reg_out_y,reg_out_z,disp_out,
clk,rst,write_en,
addr_y,addr_z,addr_x,data_x);

output [31:0] reg_out_y,reg_out_z,disp_out;

input clk,rst,write_en;

input [3:0] addr_x,addr_y,addr_z;
input [31:0] data_x;

reg [31:0] regs [15:0];

assign reg_out_y = regs[addr_y];
assign reg_out_z = regs[addr_z];

assign disp_out = regs[addr_x];
integer i;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            regs[i] <= i;
        end
    end else begin
        if (write_en && addr_x != 4'b0000) begin
            regs[addr_x] <= data_x;
        end
    end
end

  
endmodule
