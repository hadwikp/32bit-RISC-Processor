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

initial begin
    regs[0] = 32'd0;
    regs[1] = 32'd1;
    regs[2] = 32'd2;
    regs[3] = 32'd3;
    regs[4] = 32'd4;
    regs[5] = 32'd5;
    regs[6] = 32'd6;
    regs[7] = 32'd7;
    regs[8] = 32'd8;
    regs[9] = 32'd9;
    regs[10] = 32'd10;
    regs[11] = 32'd11;
    regs[12] = 32'd12;
    regs[13] = 32'd13;
    regs[14] = 32'd14;
    regs[15] = 32'd15;
end
endmodule
