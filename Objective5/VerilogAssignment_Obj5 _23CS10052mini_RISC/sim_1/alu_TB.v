`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2025 14:54:26
// Design Name: 
// Module Name: alu_TB
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


module alu_TB;
    reg [31:0] a_tb;
    reg [31:0] b_tb;
    reg [4:0]  aluOp_tb;
    wire [31:0] out_tb;
    wire        negFlag_tb;
    wire        zeroFlag_tb;

    ALU dut (
        .out(out_tb),
        .negFlag(negFlag_tb),
        .zeroFlag(zeroFlag_tb),
        .a(a_tb),
        .b(b_tb),
        .aluOp(aluOp_tb)
    );

    initial begin
        $display("------------------------------------------------------------------");
        $display("Starting ALU Testbench Simulation");
        $display("Time(ns) | Op |      A     |      B     |     Output   | N | Z");
        $display("------------------------------------------------------------------");
        $monitor("%8d | %2d | %h | %h | %h | %b | %b", $time, aluOp_tb, a_tb, b_tb, out_tb, negFlag_tb, zeroFlag_tb);

        a_tb = 32'd100;      b_tb = 32'd50;       aluOp_tb = 5'd0; #10;
        a_tb = 32'd100;      b_tb = -32'd50;      aluOp_tb = 5'd0; #10;
        a_tb = -32'd100;     b_tb = -32'd50;      aluOp_tb = 5'd0; #10;

        a_tb = 32'd100;      b_tb = 32'd50;       aluOp_tb = 5'd1; #10;
        a_tb = 32'd50;       b_tb = 32'd100;      aluOp_tb = 5'd1; #10; // Negative result
        a_tb = 32'd100;      b_tb = 32'd100;      aluOp_tb = 5'd1; #10; // Zero result

        a_tb = 32'hF0F0F0F0; b_tb = 32'hFFFF0000; aluOp_tb = 5'd2; #10;
        
        a_tb = 32'hF0F0F0F0; b_tb = 32'hFFFF0000; aluOp_tb = 5'd3; #10;
       
        a_tb = 32'hF0F0F0F0; b_tb = 32'hFFFF0000; aluOp_tb = 5'd4; #10;

        a_tb = 32'hF0F00000; b_tb = 32'h0000F0F0; aluOp_tb = 5'd5; #10;
       
        a_tb = 32'hFFFFFFFF; b_tb = 32'hxxxxxxxx; aluOp_tb = 5'd6; #10; // b is ignored
      
        a_tb = 32'h0000000F; b_tb = 32'd4;         aluOp_tb = 5'd7; #10; // Shift by 4
      
        a_tb = 32'hF0000000; b_tb = 32'd4;         aluOp_tb = 5'd8; #10;
       
        a_tb = 32'hF0000000; b_tb = 32'd4;         aluOp_tb = 5'd9; #10; // Note sign extension
      
        a_tb = 32'd99;       b_tb = 32'hxxxxxxxx; aluOp_tb = 5'd10; #10;
       
        a_tb = 32'd101;      b_tb = 32'hxxxxxxxx; aluOp_tb = 5'd11; #10;
      
        a_tb = 32'd10;       b_tb = 32'd20;       aluOp_tb = 5'd12; #10; // 10 < 20 -> should be 1
        a_tb = -32'd10;      b_tb = -32'd20;      aluOp_tb = 5'd12; #10; // -10 > -20 -> should be 0
       
        a_tb = 32'd10;       b_tb = 32'd20;       aluOp_tb = 5'd13; #10; // 10 < 20 -> should be 0
        a_tb = -32'd10;      b_tb = -32'd20;      aluOp_tb = 5'd13; #10; // -10 > -20 -> should be 1
       
        a_tb = 32'h0000ABCD; b_tb = 32'hxxxxxxxx; aluOp_tb = 5'd14; #10; // Expect ABCD0000
   
        a_tb = 32'b10110011; b_tb = 32'hxxxxxxxx; aluOp_tb = 5'd15; #10; // 5 bits are set

        $display("\nSimulation Finished.");
        $finish;
    end

endmodule
