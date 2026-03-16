`timescale 1ns / 1ps

module bigTopModule(
    input clk,
    input rst,
    input [31:0] instr,
    output [31:0] disp_out
);
    wire [5:0] opcode = instr[31:26];
    wire [4:0] rs_idx  = instr[25:21];
    wire [4:0] rt_idx  = instr[20:16];
    wire [4:0] rd_idx  = instr[15:11];
    wire [4:0] func    = instr[4:0];
    wire [15:0] imm16  = instr[15:0];
    wire [3:0] addr_rs = rs_idx[3:0];
    wire [3:0] addr_rt = rt_idx[3:0];
    wire [3:0] addr_rd = rd_idx[3:0];

    wire [31:0] reg_y;
    wire [31:0] reg_z;
    wire [31:0] reg_disp;

    reg [3:0] addr_x;
    reg write_en_reg;
    wire [31:0] alu_out;
    wire negFlag, zeroFlag;
    reg [31:0] alu_a, alu_b;
    reg [4:0] aluOp;
    
    regBank rb (
        .reg_out_y(reg_y),
        .reg_out_z(reg_z),
        .disp_out(reg_disp),
        .clk(clk),
        .rst(rst),
        .write_en(write_en_reg),
        .addr_y(addr_rs),
        .addr_z(addr_rt),
        .addr_x(addr_x),
        .data_x(alu_out)
    );

    assign disp_out = reg_disp;

    ALU alu (
        .out(alu_out),
        .negFlag(negFlag),
        .zeroFlag(zeroFlag),
        .a(alu_a),
        .b(alu_b),
        .aluOp(aluOp)
    );

    localparam OPC_RTYPE = 6'b000000;
    localparam OPC_ADDI  = 6'b000001;
    localparam OPC_SUBI  = 6'b000010;
    localparam OPC_ANDI  = 6'b000011;
    localparam OPC_ORI   = 6'b000100;
    localparam OPC_XORI  = 6'b000101;
    localparam OPC_NORI  = 6'b000110;
    localparam OPC_SLI   = 6'b000111;
    localparam OPC_SRLI  = 6'b001000;
    localparam OPC_SRAI  = 6'b001001;
    localparam OPC_SLTI  = 6'b001010;
    localparam OPC_SGTI  = 6'b001011;
    localparam OPC_NOTI  = 6'b001100;
    localparam OPC_INCI  = 6'b001101;
    localparam OPC_DECI  = 6'b001110;
    localparam OPC_HAMI  = 6'b001111;
    localparam OPC_LUI   = 6'b010000;

    localparam FUNC_ADD  = 5'b00001;
    localparam FUNC_SUB  = 5'b00010;
    localparam FUNC_AND  = 5'b00011;
    localparam FUNC_OR   = 5'b00100;
    localparam FUNC_XOR  = 5'b00101;
    localparam FUNC_NOR  = 5'b00110;
    localparam FUNC_SL   = 5'b00111;
    localparam FUNC_SRL  = 5'b01000;
    localparam FUNC_SRA  = 5'b01001;
    localparam FUNC_SLT  = 5'b01010;
    localparam FUNC_SGT  = 5'b01011;
    localparam FUNC_NOT  = 5'b01100;
    localparam FUNC_INC  = 5'b01101;
    localparam FUNC_DEC  = 5'b01110;
    localparam FUNC_HAM  = 5'b01111;
    localparam FUNC_LUI  = 5'b11111;

    function [31:0] signext16(input [15:0] in);
        signext16 = {{16{in[15]}}, in}; 
    endfunction

    always @(*) begin
        aluOp = 5'd0;
        alu_a = 32'd0;
        alu_b = 32'd0;
        write_en_reg = 1'b0;
        addr_x = 4'd0;

        case (opcode)
            OPC_RTYPE: begin
                alu_a = reg_y;
                alu_b = reg_z;
                addr_x = addr_rd;
                write_en_reg = 1'b1;
                case (func)
                    FUNC_ADD: aluOp = 5'd0;
                    FUNC_SUB: aluOp = 5'd1;
                    FUNC_AND: aluOp = 5'd2;
                    FUNC_OR:  aluOp = 5'd3;
                    FUNC_XOR: aluOp = 5'd4;
                    FUNC_NOR: aluOp = 5'd5;
                    FUNC_NOT: aluOp = 5'd6;
                    FUNC_SL:  aluOp = 5'd7;
                    FUNC_SRL: aluOp = 5'd8;
                    FUNC_SRA: aluOp = 5'd9;
                    FUNC_INC: aluOp = 5'd10;
                    FUNC_DEC: aluOp = 5'd11;
                    FUNC_SLT: aluOp = 5'd12;
                    FUNC_SGT: aluOp = 5'd13;
                    FUNC_LUI: aluOp = 5'd14;
                    FUNC_HAM: aluOp = 5'd15;
                    default:  aluOp = 5'd0;
                endcase
            end

            OPC_ADDI, OPC_SUBI, OPC_ANDI, OPC_ORI, OPC_XORI, OPC_NORI,
            OPC_SLI, OPC_SRLI, OPC_SRAI, OPC_SLTI, OPC_SGTI,
            OPC_NOTI, OPC_INCI, OPC_DECI, OPC_HAMI, OPC_LUI: begin
                alu_a = reg_y;
                alu_b = signext16(imm16);
                addr_x = addr_rt;
                write_en_reg = 1'b1;
                
                case (opcode)
                    OPC_ADDI: aluOp = 5'd0;
                    OPC_SUBI: begin aluOp = 5'd1; alu_b = signext16(imm16); end
                    OPC_ANDI: begin aluOp = 5'd2; alu_b = {16'b0, imm16}; end
                    OPC_ORI:  begin aluOp = 5'd3; alu_b = {16'b0, imm16}; end
                    OPC_XORI: begin aluOp = 5'd4; alu_b = {16'b0, imm16}; end
                    OPC_NORI: begin aluOp = 5'd5; alu_b = {16'b0, imm16}; end
                    OPC_SLI:  begin aluOp = 5'd7; alu_b = {27'b0, imm16[4:0]}; end
                    OPC_SRLI: begin aluOp = 5'd8; alu_b = {27'b0, imm16[4:0]}; end
                    OPC_SRAI: begin aluOp = 5'd9; alu_b = {27'b0, imm16[4:0]}; end
                    OPC_SLTI: begin aluOp = 5'd12; alu_b = signext16(imm16); end
                    OPC_SGTI: begin aluOp = 5'd13; alu_b = signext16(imm16); end
                    OPC_NOTI: begin aluOp = 5'd6; alu_b = 32'd0; end
                    OPC_INCI: begin aluOp = 5'd10; alu_b = 32'd0; end
                    OPC_DECI: begin aluOp = 5'd11; alu_b = 32'd0; end
                    OPC_HAMI: begin aluOp = 5'd15; alu_b = 32'd0; end
                    OPC_LUI:  begin
                        alu_a = {16'd0, imm16};
                        alu_b = 32'd0;
                        aluOp = 5'd14;
                    end
                    default: aluOp = 5'd0;
                endcase
            end

            default: begin
                write_en_reg = 1'b0;
                addr_x = 4'd0;
                aluOp = 5'd0;
                alu_a = reg_y;
                alu_b = reg_z;
            end
        endcase
    end
endmodule
