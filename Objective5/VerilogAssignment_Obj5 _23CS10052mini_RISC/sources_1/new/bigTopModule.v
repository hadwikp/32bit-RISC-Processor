`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.10.2025 15:02:17
// Design Name: bigTopModule
// Module Name: bigTopModule
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Top-level module for a single-cycle CPU. It integrates the
//              Control Unit, Register Bank, and ALU, using the specific
//              opcodes from the processor documentation.
//
// Dependencies: reg_bank.v, ALU.v
//
//////////////////////////////////////////////////////////////////////////////////

module bigTopModule(
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire        start_btn,     // Input to trigger instruction execution
    input  wire [31:0] instruction,   // 32-bit instruction
    output reg  [31:0] result         // 32-bit result of the operation
);

    wire [5:0]  opcode    = instruction[31:26];
    wire [4:0]  rs        = instruction[25:21];
    wire [4:0]  rt        = instruction[20:16];
    wire [4:0]  rd        = instruction[15:11];
    wire [4:0]  func      = instruction[4:0];   // 5-bit func code from document
    wire [15:0] immediate = instruction[15:0];

    reg         aluSrc;
    reg         regAluOut;
    reg         wrReg;
    reg         immToAluA;
    reg  [4:0]  alu_op;
    reg         useRtForAluA; 


    wire [31:0] A, B;
    wire [31:0] operand_b;
    wire [31:0] alu_res_wire;
    wire [31:0] imm_extended;
    wire [31:0] alu_input_a;
    wire [4:0]  dest_reg_addr;
    wire [4:0]  src1_reg_addr;
    wire [4:0]  src2_reg_addr;
    wire        neg_flag, zero_flag;


    wire [31:0] sign_extended_imm = {{16{immediate[15]}}, immediate};
    wire [31:0] zero_extended_imm = {16'b0, immediate};
    wire use_zero_extend = (opcode == 6'b000011) || (opcode == 6'b000100) || (opcode == 6'b000101); // ANDI, ORI, XORI
    assign imm_extended  = use_zero_extend ? zero_extended_imm : sign_extended_imm;


    assign operand_b     = aluSrc ? imm_extended : B;
    assign src1_reg_addr = rs;
    assign src2_reg_addr = rt;
    assign dest_reg_addr = regAluOut ? rd : rt;

    wire [31:0] alu_a_mux_out = useRtForAluA ? B : A;
    assign alu_input_a   = immToAluA ? imm_extended : alu_a_mux_out;

    reg start_d;
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) start_d <= 1'b0;
        else       start_d <= start_btn;
    end
    wire start_pulse = start_btn & ~start_d;

    reg exe_stage_valid;
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) exe_stage_valid <= 1'b0;
        else       exe_stage_valid <= start_pulse;
    end

    always @(*) begin
        // Default control signal values
        aluSrc       = 1'b0;
        regAluOut    = 1'b0;
        wrReg        = 1'b0;
        immToAluA    = 1'b0;
        useRtForAluA = 1'b0; 
        alu_op       = 5'd0;

        case (opcode)
            // R-Type Instructions (Opcode: 000000)
            6'b000000: begin
                aluSrc      = 1'b0;
                regAluOut   = 1'b1;
                wrReg       = 1'b1;
                case (func)
                    5'b00001: alu_op = 5'd0;
                    5'b00010: alu_op = 5'd1;
                    5'b00011: alu_op = 5'd2;
                    5'b00100: alu_op = 5'd3;
                    5'b00101: alu_op = 5'd4;
                    5'b00110: alu_op = 5'd5;
                    5'b00111: alu_op = 5'd7;
                    5'b01000: alu_op = 5'd8;
                    5'b01001: alu_op = 5'd9;
                    5'b01010: alu_op = 5'd12;
                    5'b01011: alu_op = 5'd13;
                    5'b01100: begin alu_op = 5'd6;  useRtForAluA = 1'b1; end // NOT
                    5'b01101: begin alu_op = 5'd10; useRtForAluA = 1'b1; end // INC
                    5'b01110: begin alu_op = 5'd11; useRtForAluA = 1'b1; end // DEC
                    5'b01111: begin alu_op = 5'd15; useRtForAluA = 1'b1; end // HAM
                    default:   wrReg  = 1'b0;
                endcase
            end
            // I-Type Instructions
            6'b000001: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd0; end // ADDI
            6'b000010: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd1; end // SUBI
            6'b000011: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd2; end // ANDI
            6'b000100: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd3; end // ORI
            6'b000101: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd4; end // XORI
            6'b000110: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd5; end // NORI
            6'b000111: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd7; end // SLI
            6'b001000: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd8; end // SRLI
            6'b001001: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd9; end // SRAI
            6'b001010: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd12;end // SLTI
            6'b001011: begin aluSrc = 1'b1; wrReg = 1'b1; alu_op = 5'd13;end // SGTI
            //  For unary I-type ops, use immediate as the source for ALU 'a'
            6'b001100: begin immToAluA = 1'b1; wrReg = 1'b1; alu_op = 5'd6; end // NOTI
            6'b001101: begin immToAluA = 1'b1; wrReg = 1'b1; alu_op = 5'd10;end // INCI
            6'b001110: begin immToAluA = 1'b1; wrReg = 1'b1; alu_op = 5'd11;end // DECI
            6'b001111: begin immToAluA = 1'b1; wrReg = 1'b1; alu_op = 5'd15;end // HAMI
            6'b010000: begin immToAluA = 1'b1; wrReg = 1'b1; alu_op = 5'd14;end // LUI
            default:   wrReg = 1'b0;
        endcase
    end

    regBank REG_FILE(
        .clk(clk_i),
        .rst(rst_i),
        .Wr(exe_stage_valid & wrReg),
        .Rd1(start_pulse),
        .Rd2(start_pulse & ~aluSrc),
        .src1(src1_reg_addr),
        .src2(src2_reg_addr),
        .dest(dest_reg_addr),
        .Z(alu_res_wire),
        .A(A),
        .B(B)
    );

    ALU ALU_unit(
        .out(alu_res_wire),
        .negFlag(neg_flag),
        .zeroFlag(zero_flag),
        .a(alu_input_a),
        .b(operand_b),
        .aluOp(alu_op)
    );

 
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            result <= 32'b0;
        else if (exe_stage_valid)
            result <= alu_res_wire;
    end

endmodule

