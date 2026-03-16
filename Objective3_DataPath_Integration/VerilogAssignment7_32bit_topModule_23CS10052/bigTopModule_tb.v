`timescale 1ns / 1ps

module bigTopModule_tb;

    // Inputs to the DUT
    reg clk;
    reg rst;
    reg [31:0] instr;

    // Output from the DUT
    wire [31:0] disp_out;

    // Instantiate the Design Under Test (DUT)
    bigTopModule dut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .disp_out(disp_out)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period, 100MHz clock
    end

    // Instruction Opcodes and Function Codes (mirrored from DUT for readability)
    // Opcodes
    localparam OPC_RTYPE = 6'b000000;
    localparam OPC_ADDI  = 6'b000001;
    localparam OPC_SUBI  = 6'b000010;
    localparam OPC_ANDI  = 6'b000011;
    localparam OPC_ORI   = 6'b000100;
    localparam OPC_XORI  = 6'b000101;
    localparam OPC_SLI   = 6'b000111;
    localparam OPC_SRLI  = 6'b001000;
    localparam OPC_SRAI  = 6'b001001;
    localparam OPC_SLTI  = 6'b001010;
    localparam OPC_SGTI  = 6'b001011;
    localparam OPC_LUI   = 6'b010000;

    // R-Type Function Codes
    localparam FUNC_ADD  = 5'b00001;
    localparam FUNC_SUB  = 5'b00010;
    localparam FUNC_AND  = 5'b00011;
    localparam FUNC_OR   = 5'b00100;
    localparam FUNC_XOR  = 5'b00101;
    localparam FUNC_SL   = 5'b00111;
    localparam FUNC_SRL  = 5'b01000;
    localparam FUNC_SRA  = 5'b01001;
    localparam FUNC_SLT  = 5'b01010;
    localparam FUNC_SGT  = 5'b01011;
    localparam FUNC_NOT  = 5'b01100;
    localparam FUNC_INC  = 5'b01101;


    // Test Sequence
    initial begin
        $display("--- Starting Testbench for alu_reg_unit ---");

        // 1. Apply Reset
        rst = 1;
        instr = 0;
        #15;
        rst = 0;
        #5;
        $display("Reset complete. RegBank initialized (reg[i] = i).");

        // --- R-TYPE INSTRUCTION TESTS ---
        // Format: {opcode, rs, rt, rd, shamt, func}
        $display("\n--- Testing R-Type Instructions ---");

        // ADD R3, R1, R2 => R3 = 1 + 2 = 3
        instr = {OPC_RTYPE, 5'd1, 5'd2, 5'd3, 5'd0, FUNC_ADD}; #10;
        check(3, 3, "ADD");

        // SUB R4, R3, R1 => R4 = 3 - 1 = 2
        instr = {OPC_RTYPE, 5'd3, 5'd1, 5'd4, 5'd0, FUNC_SUB}; #10;
        check(4, 2, "SUB");

        // AND R5, R3, R4 => R5 = 3 & 2 = 2
        instr = {OPC_RTYPE, 5'd3, 5'd4, 5'd5, 5'd0, FUNC_AND}; #10;
        check(5, 2, "AND");

        // OR R6, R4, R1 => R6 = 2 | 1 = 3
        instr = {OPC_RTYPE, 5'd4, 5'd1, 5'd6, 5'd0, FUNC_OR}; #10;
        check(6, 3, "OR");

        // XOR R7, R6, R4 => R7 = 3 ^ 2 = 1
        instr = {OPC_RTYPE, 5'd6, 5'd4, 5'd7, 5'd0, FUNC_XOR}; #10;
        check(7, 1, "XOR");
        
        // NOT R8, R1 => R8 = ~1
        instr = {OPC_RTYPE, 5'd1, 5'd0, 5'd8, 5'd0, FUNC_NOT}; #10;
        check(8, 32'hFFFFFFFE, "NOT");

        // SL R9, R4, R2 => R9 = R4 << R2[4:0] => 2 << 2 = 8
        instr = {OPC_RTYPE, 5'd4, 5'd2, 5'd9, 5'd0, FUNC_SL}; #10;
        check(9, 8, "SL");
        
        // SRL R10, R9, R4 => R10 = R9 >> R4[4:0] => 8 >> 2 = 2
        instr = {OPC_RTYPE, 5'd9, 5'd4, 5'd10, 5'd0, FUNC_SRL}; #10;
        check(10, 2, "SRL");
        
        // SLT R11, R1, R2 => R11 = (1 < 2) ? 1 : 0 => 1
        instr = {OPC_RTYPE, 5'd1, 5'd2, 5'd11, 5'd0, FUNC_SLT}; #10;
        check(11, 1, "SLT (true)");
        
        // SGT R12, R1, R2 => R12 = (1 > 2) ? 1 : 0 => 0
        instr = {OPC_RTYPE, 5'd1, 5'd2, 5'd12, 5'd0, FUNC_SGT}; #10;
        check(12, 0, "SGT (false)");

        // INC R1, R1 => R1 = 1 + 1 = 2
        instr = {OPC_RTYPE, 5'd1, 5'd1, 5'd1, 5'd0, FUNC_INC}; #10;
        check(1, 2, "INC");

        // --- I-TYPE INSTRUCTION TESTS ---
        // Format: {opcode, rs, rt, immediate}
        $display("\n--- Testing I-Type Instructions ---");
        
        // ADDI R2, R0, 100 => R2 = 0 + 100 = 100
        instr = {OPC_ADDI, 5'd0, 5'd2, 16'd100}; #10;
        check(2, 100, "ADDI");
        
        // ADDI R3, R2, -20 => R3 = 100 - 20 = 80
        instr = {OPC_ADDI, 5'd2, 5'd3, -16'd20}; #10;
        check(3, 80, "ADDI (negative imm)");
        
        // SUBI R4, R3, 30 => R4 = 80 - 30 = 50
        instr = {OPC_SUBI, 5'd3, 5'd4, 16'd30}; #10;
        check(4, 50, "SUBI");

        // ANDI R5, R2, 0x0F => R5 = 100 & 15 = 4  (100=0x64)
        instr = {OPC_ANDI, 5'd2, 5'd5, 16'h000F}; #10;
        check(5, 4, "ANDI");
        
        // ORI R6, R5, 0xF0 => R6 = 4 | 240 = 244
        instr = {OPC_ORI, 5'd5, 5'd6, 16'h00F0}; #10;
        check(6, 244, "ORI");
        
        // XORI R7, R6, 0xFF => R7 = 244 ^ 255 = 11
        instr = {OPC_XORI, 5'd6, 5'd7, 16'h00FF}; #10;
        check(7, 11, "XORI");

        // LUI R8, 0xABCD => R8 = 0xABCD0000
        instr = {OPC_LUI, 5'd0, 5'd8, 16'hABCD}; #10;
        check(8, 32'hABCD0000, "LUI");
        
        // SLI R9, R2, 4 => R9 = 100 << 4 = 1600
        instr = {OPC_SLI, 5'd2, 5'd9, 16'd4}; #10;
        check(9, 1600, "SLI");
        
        // SRLI R10, R9, 2 => R10 = 1600 >> 2 = 400
        instr = {OPC_SRLI, 5'd9, 5'd10, 16'd2}; #10;
        check(10, 400, "SRLI");
        
        // SRAI on a negative number set by LUI+ADDI
        // R8 is 0xABCD0000. ADDI R8, R8, 0x1234 -> R8 = 0xABCD1234 (negative)
        instr = {OPC_ADDI, 5'd8, 5'd8, 16'h1234}; #10;
        // SRAI R11, R8, 4 => R11 = 0xABCD1234 >>> 4 = 0xFABCD123
        instr = {OPC_SRAI, 5'd8, 5'd11, 16'd4}; #10;
        check(11, 32'hFABCD123, "SRAI");

        // SLTI R12, R2, 500 => R12 = (100 < 500) ? 1 : 0 => 1
        instr = {OPC_SLTI, 5'd2, 5'd12, 16'd500}; #10;
        check(12, 1, "SLTI (true)");

        // SGTI R13, R2, 50 => R13 = (100 > 50) ? 1 : 0 => 1
        instr = {OPC_SGTI, 5'd2, 5'd13, 16'd50}; #10;
        check(13, 1, "SGTI (true)");

        $display("\n--- All tests completed ---");
        $finish;
    end

    // Verification task
    task check(input [3:0] addr, input [31:0] expected_val, input [20*8:1] test_name);
        if (dut.rb.regs[addr] === expected_val) begin
            $display("  [PASS] %s: R%0d = %d", test_name, addr, dut.rb.regs[addr]);
        end else begin
            $display("  [FAIL] %s: R%0d. Expected: %d, Got: %d", test_name, addr, expected_val, dut.rb.regs[addr]);
        end
    endtask

endmodule