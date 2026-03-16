`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.10.2025 15:05:31
// Design Name: tb_bigTopModule
// Module Name: tb_bigTopModule
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A comprehensive testbench for the bigTopModule.
//              Tests both R-Type and I-Type instructions.
//
// Dependencies: bigTopModule.v, reg_bank.v, ALU.v
//
//////////////////////////////////////////////////////////////////////////////////

module bigTopModule_tb;

    // Testbench signals
    reg         clk_i;
    reg         rst_i;
    reg         start_btn;
    reg  [31:0] instruction;
    wire [31:0] result;

    // Instantiate the Device Under Test (DUT)
    bigTopModule DUT (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_btn(start_btn),
        .instruction(instruction),
        .result(result)
    );

    // Clock generation (100 MHz)
    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

    // Test sequence
    initial begin
        // 1. Initial Reset
        rst_i = 1;
        start_btn = 0;
        instruction = 0;
        #20;
        rst_i = 0;
        $display("========================================");
        $display("===           TESTING START          ===");
        $display("========================================");
        $display("System reset. Registers initialized.");

        //================================================================
        // R-Type Instruction Tests
        // Format: {opcode, rs, rt, rd, don't_care, func}
        //================================================================
        $display("\n--- Testing R-Type Instructions ---");

        // Test 1: ADD R3 = R1 + R2 (1 + 2 = 3)
        instruction = {6'b000000, 5'd1, 5'd2, 5'd3, 6'b0, 5'b00001};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("ADD R3, R1, R2   => Result = %0d (Expected: 3)", result);

        // Test 2: SUB R5 = R4 - R1 (4 - 1 = 3)
        instruction = {6'b000000, 5'd4, 5'd1, 5'd5, 6'b0, 5'b00010};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("SUB R5, R4, R1   => Result = %0d (Expected: 3)", result);

        // Test 3: AND R7 = R5 & R6 (3 & 6 = 2)
        instruction = {6'b000000, 5'd5, 5'd6, 5'd7, 6'b0, 5'b00011};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("AND R7, R5, R6   => Result = %0d (Expected: 2)", result);

        // Test 4: OR R10 = R8 | R9 (8 | 9 = 9)
        instruction = {6'b000000, 5'd8, 5'd9, 5'd10, 6'b0, 5'b00100};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("OR R10, R8, R9   => Result = %0d (Expected: 9)", result);

        // Test 5: SLT R15 = (R1 < R4) ? 1:0 (1 < 4 is true)
        instruction = {6'b000000, 5'd1, 5'd4, 5'd15, 6'b0, 5'b01010};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("SLT R15, R1, R4  => Result = %0d (Expected: 1)", result);
        
        // Test 6: NOT R2 = ~R3 (~3)
        instruction = {6'b000000, 5'd0, 5'd3, 5'd2, 6'b0, 5'b01100};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("NOT R2, R3       => Result = %h (Expected: fffffffc)", result);

        // Test 7: INC R4 = R4 + 1 (4 + 1 = 5)
        instruction = {6'b000000, 5'd0, 5'd4, 5'd4, 6'b0, 5'b01101};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("INC R4, R4       => Result = %0d (Expected: 5)", result);

        //================================================================
        // I-Type Instruction Tests
        // Format: {opcode, rs, rt, immediate}
        //================================================================
        $display("\n--- Testing I-Type Instructions ---");
        
        // Test 8: ADDI R1 = R2 + 10 (-4 + 10 = 6). R1 is now 6.
        instruction = {6'b000001, 5'd2, 5'd1, 16'd10};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("ADDI R1, R2, 10  => Result = %0d (Expected: 6)", result);

        // Test 9: ADDI R2 = R1 + (-5) (6 - 5 = 1). R2 is now 1.
        instruction = {6'b000001, 5'd1, 5'd2, 16'hFFFB}; // -5 in 16-bit 2's complement
        start_btn = 1; #10; start_btn = 0; #50;
        $display("ADDI R2, R1, -5  => Result = %0d (Expected: 1)", result);
        
        // Test 10: ORI R5 = R4 | 0xF000 (5 | 61440 = 61445)
        instruction = {6'b000100, 5'd4, 5'd5, 16'hF000};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("ORI R5, R4, F000 => Result = %0d (Expected: 61445)", result);
        
        // Test 11: SLTI R11 = (R10 < -1) ? 1 : 0 (9 < -1 is false)
        instruction = {6'b001010, 5'd10, 5'd11, 16'hFFFF}; // -1
        start_btn = 1; #10; start_btn = 0; #50;
        $display("SLTI R11, R10, -1=> Result = %0d (Expected: 0)", result);

        // Test 12: LUI R15 = 0xCAFE0000
        instruction = {6'b010000, 5'd0, 5'd15, 16'hCAFE};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("LUI R15, 0xCAFE  => Result = %h (Expected: cafe0000)", result);
        
        // Test 13: HAMI R4 = popcount(0xB5) -> 10110101 -> 5
        instruction = {6'b001111, 5'd0, 5'd4, 16'h00B5};
        start_btn = 1; #10; start_btn = 0; #50;
        $display("HAMI R4, 0xB5    => Result = %0d (Expected: 5)", result);

        $display("\n========================================");
        $display("===            TESTING END           ===");
        $display("========================================");
        $finish;
    end
endmodule
