`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2025 17:22:58
// Design Name: 
// Module Name: regTB
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2025 17:22:58
// Design Name: 
// Module Name: regTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the RISC-V datapath top module.
// 
// Dependencies: topModule.v, regBank.v, ALU.v and its submodules.
// 
// Revision:
// Revision 1.00 - Corrected opcodes and test methodology.
// Additional Comments:
// Assumes the register file is initialized such that Rx holds the value 'x'.
// For example, R1 = 1, R2 = 2, etc.
//////////////////////////////////////////////////////////////////////////////////


module regTB();
reg clk;
reg rst;
reg btn;
reg [15:0]instr;
wire [15:0] out;

topModule uut (
    .out(out),
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .instr(instr)
);


initial begin
    clk = 0;
    forever #10 clk = ~clk;
end


initial begin

    rst = 1;
    btn = 0;
    instr = 16'h0000;
    #20;
    rst = 0;
    #10;

    //  ADD Test: R3 = R1 + R2  (Result: 1 + 2 = 3)
    $display("\n--- Testing ADD Operation ---");
    instr = 16'b0_000_0011_0001_0010;
    btn = 1; #20; btn = 0; #10;
    if (out == 16'd3) $display("ADD Test [Lower Half]: SUCCESS"); else $display("ADD Test [Lower Half]: FAILURE, out=%h", out);
    
    instr = 16'b1_000_0011_0001_0010;
    #20;
    if (out == 16'd0) $display("ADD Test [Upper Half]: SUCCESS"); else $display("ADD Test [Upper Half]: FAILURE, out=%h", out);

    //  SUB Test: R4 = R3 - R2  (Result: 3 - 2 = 1)
    $display("\n--- Testing SUB Operation ---");
    instr = 16'b0_001_0100_0011_0010; 
    btn = 1; #20; btn = 0; #10;
    if (out == 16'd1) $display("SUB Test [Lower Half]: SUCCESS"); else $display("SUB Test [Lower Half]: FAILURE, out=%h", out);
    
    instr = 16'b1_001_0100_0011_0010; 
    #20;
    if (out == 16'd0) $display("SUB Test [Upper Half]: SUCCESS"); else $display("SUB Test [Upper Half]: FAILURE, out=%h", out);
    
    
    //  AND Test: R5 = R6 & R3 (Result: 6 & 3 = 2) (110 & 011 = 010)
    $display("\n--- Testing AND Operation ---");
    instr = 16'b0_010_0101_0110_0011; 
    btn = 1; #20; btn = 0; #10;
    if (out === 16'd2) $display("AND Test [Lower Half]: SUCCESS"); else $display("AND Test [Lower Half]: FAILURE, out=%h", out);
    
    
    instr = 16'b1_010_0101_0110_0011;
    #20;
    if (out === 16'd0) $display("AND Test [Upper Half]: SUCCESS"); else $display("AND Test [Upper Half]: FAILURE, out=%h", out);


    //  XOR Test: R6 = R5 ^ R3 (Result: 2 ^ 3 = 1) (010 ^ 011 = 001)
    $display("\n--- Testing XOR Operation ---");
    instr = 16'b0_011_0110_0101_0011; 
    btn = 1; #20; btn = 0; #10;
    if (out === 16'd1) $display("XOR Test [Lower Half]: SUCCESS"); else $display("XOR Test [Lower Half]: FAILURE, out=%h", out);

    instr = 16'b1_011_0110_0101_0011;
    #20;
    if (out === 16'd0) $display("XOR Test [Upper Half]: SUCCESS"); else $display("XOR Test [Upper Half]: FAILURE, out=%h", out);


    // SL Test (Shift Left): R7 = R11 << R2 (Result: 11 << 2 = 44)
    #20;
    $display("\n--- Testing SL Operation ---");
    instr = 16'b0_100_0111_1011_0010;
    btn = 1; #20; btn = 0; #20;
    if (out === 16'd44) $display("SL Test [Lower Half]: SUCCESS"); else $display("SL Test [Lower Half]: FAILURE, out=%h", out);

    instr = 16'b1_100_0111_0100_0010;
    #20;
    if (out === 16'd0) $display("SL Test [Upper Half]: SUCCESS"); else $display("SL Test [Upper Half]: FAILURE, out=%h", out);


    // SRA Test (Shift Right Arithmetic): R8 = R15 >>> R2 (Result: 15 >>> 2 = 3)
    $display("\n--- Testing SRA Operation ---");
    instr = 16'b0_101_1000_1111_0010;
    btn = 1; #20; btn = 0; #10;
    if (out === 16'd3) $display("SRA Test [Lower Half]: SUCCESS"); else $display("SRA Test [Lower Half]: FAILURE, out=%h", out);

    instr = 16'b1_101_1000_1111_0010;
    #20;
    if (out === 16'd0) $display("SRA Test [Upper Half]: SUCCESS"); else $display("SRA Test [Upper Half]: FAILURE, out=%h", out);
    
    
    // SLT Test (Set Less Than): R9 = (R10 < R12) ? 1:0 (Result: 10 < 12 = 1)
    $display("\n--- Testing SLT Operation ---");
    instr = 16'b0_110_1001_1010_1100; 
    btn = 1; #20; btn = 0; #10;
    if (out === 16'd1) $display("SLT Test [Lower Half]: SUCCESS"); else $display("SLT Test [Lower Half]: FAILURE, out=%h", out);
    
    instr = 16'b1_110_1001_1010_1100; 
    #20;
    if (out === 16'd0) $display("SLT Test [Upper Half]: SUCCESS"); else $display("SLT Test [Upper Half]: FAILURE, out=%h", out);


    // SGT Test (Set Greater Than): R10 = (R12 > R11) ? 1:0 (Result: 12 > 11 = 1)
    $display("\n--- Testing SGT Operation ---");
    instr = 16'b0_111_1010_1100_1011;
    btn = 1; #20; btn = 0; #10;
    if (out === 16'd1) $display("SGT Test [Lower Half]: SUCCESS"); else $display("SGT Test [Lower Half]: FAILURE, out=%h", out);
    
    instr = 16'b1_111_1010_1100_1011;
    #20;
    if (out === 16'd0) $display("SGT Test [Upper Half]: SUCCESS"); else $display("SGT Test [Upper Half]: FAILURE, out=%h", out);

    
    #20;
    $finish;
end

endmodule
