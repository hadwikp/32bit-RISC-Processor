`timescale 1ns / 1ps

module control_unit (
    input  wire [5:0] opcode,
    input  wire [4:0] funct,
    
    output reg        reg_wr_en,
    output reg        reg_out,
    output reg        immdt_sel,
    output reg        b_sel,
    output reg        alu_src_a,
    output reg        mem_rd,
    output reg        mem_wr,
    output reg        mem_to_reg,
    output reg        is_branch,
    output reg        is_halt,
    output reg        a_imm_sel,
    output reg        is_cmov,      // NEW: Signal for CMOV
    output reg [4:0]  alu_funct  
);

    localparam OPCODE_RTYPE = 6'b000000;
    localparam OPCODE_ADDI  = 6'b000001;
    localparam OPCODE_SUBI  = 6'b000010;
    localparam OPCODE_ANDI  = 6'b000011;
    localparam OPCODE_ORI   = 6'b000100;
    localparam OPCODE_XORI  = 6'b000101;
    localparam OPCODE_NORI  = 6'b000110;
    localparam OPCODE_SLI   = 6'b000111;
    localparam OPCODE_SRLI  = 6'b001000;
    localparam OPCODE_SRAI  = 6'b001001;
    localparam OPCODE_SLTI  = 6'b001010;
    localparam OPCODE_SGTI  = 6'b001011;
    localparam OPCODE_NOTI  = 6'b001100;
    localparam OPCODE_INCI  = 6'b001101;
    localparam OPCODE_DECI  = 6'b001110;
    localparam OPCODE_HAMI  = 6'b001111;
    localparam OPCODE_LUI   = 6'b010000;
    localparam OPCODE_LD    = 6'b010001;
    localparam OPCODE_ST    = 6'b010010;
    localparam OPCODE_BR    = 6'b100000;
    localparam OPCODE_BMI   = 6'b100001;
    localparam OPCODE_BPL   = 6'b100010;
    localparam OPCODE_BZ    = 6'b100011;
    localparam OPCODE_HALT  = 6'b100100;
    localparam OPCODE_NOP   = 6'b100101;
    localparam OPCODE_MOVE  = 6'b010100;
    localparam OPCODE_CMOVE = 6'b010101;
    
    // ALU constants
    localparam ALU_OP_ADD = 5'd0;
    localparam ALU_OP_SUB = 5'd1;
    localparam ALU_OP_AND = 5'd2;
    localparam ALU_OP_OR  = 5'd3;
    localparam ALU_OP_XOR = 5'd4;
    localparam ALU_OP_NOR = 5'd5;
    localparam ALU_OP_SL  = 5'd6;
    localparam ALU_OP_SRL = 5'd7;
    localparam ALU_OP_SRA = 5'd8;
    localparam ALU_OP_SLT = 5'd9;
    localparam ALU_OP_SGT = 5'd10;
    localparam ALU_OP_NOT = 5'd11;
    localparam ALU_OP_INC = 5'd12;
    localparam ALU_OP_DEC = 5'd13;
    localparam ALU_OP_HAM = 5'd14;
    localparam ALU_OP_LUI = 5'd15;
    
    // ISA function codes (5-bit)
    localparam ISA_FUNCT_5b_ADD = 5'b00001;
    localparam ISA_FUNCT_5b_SUB = 5'b00010;
    localparam ISA_FUNCT_5b_AND = 5'b00011;
    localparam ISA_FUNCT_5b_OR  = 5'b00100;
    localparam ISA_FUNCT_5b_XOR = 5'b00101;
    localparam ISA_FUNCT_5b_NOR = 5'b00110;
    localparam ISA_FUNCT_5b_SL  = 5'b00111;
    localparam ISA_FUNCT_5b_SRL = 5'b01000;
    localparam ISA_FUNCT_5b_SRA = 5'b01001;
    localparam ISA_FUNCT_5b_SLT = 5'b01010;
    localparam ISA_FUNCT_5b_SGT = 5'b01011;
    localparam ISA_FUNCT_5b_NOT = 5'b01100;
    localparam ISA_FUNCT_5b_INC = 5'b01101;
    localparam ISA_FUNCT_5b_DEC = 5'b01110;
    localparam ISA_FUNCT_5b_HAM = 5'b01111;
    localparam ISA_FUNCT_5b_CMOV = 5'b10001;  

    always @(*) begin
        reg_wr_en  = 1'b0;
        reg_out    = 1'b0;
        immdt_sel  = 1'b0;
        b_sel      = 1'b1;
        alu_src_a  = 1'b0;
        mem_rd     = 1'b0;
        mem_wr     = 1'b0;
        mem_to_reg = 1'b0;
        is_branch  = 1'b0;
        is_halt    = 1'b0;
        is_cmov    = 1'b0;  
        alu_funct  = 5'b0;
        a_imm_sel  = 1'b0;
        
        case (opcode)
            OPCODE_RTYPE: begin
                reg_wr_en  = 1'b1;
                reg_out    = 1'b1;    // write to rd (R-type)
                b_sel      = 1'b1;    // second operand from register
                
                case (funct[4:0])
                    ISA_FUNCT_5b_ADD: alu_funct = ALU_OP_ADD;
                    ISA_FUNCT_5b_SUB: alu_funct = ALU_OP_SUB;
                    ISA_FUNCT_5b_AND: alu_funct = ALU_OP_AND;
                    ISA_FUNCT_5b_OR:  alu_funct = ALU_OP_OR;
                    ISA_FUNCT_5b_XOR: alu_funct = ALU_OP_XOR;
                    ISA_FUNCT_5b_NOR: alu_funct = ALU_OP_NOR;
                    ISA_FUNCT_5b_SL:  alu_funct = ALU_OP_SL;
                    ISA_FUNCT_5b_SRL: alu_funct = ALU_OP_SRL;
                    ISA_FUNCT_5b_SRA: alu_funct = ALU_OP_SRA;
                    ISA_FUNCT_5b_SLT: alu_funct = ALU_OP_SLT;
                    ISA_FUNCT_5b_SGT: alu_funct = ALU_OP_SGT;
                    ISA_FUNCT_5b_NOT: alu_funct = ALU_OP_NOT;
                    ISA_FUNCT_5b_INC: alu_funct = ALU_OP_INC;
                    ISA_FUNCT_5b_DEC: alu_funct = ALU_OP_DEC;
                    ISA_FUNCT_5b_HAM: alu_funct = ALU_OP_HAM;
                    default:          alu_funct = 5'b0;
                endcase
            end
            
            // I-type arithmetic
            OPCODE_MOVE: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_ADD; end
            OPCODE_ADDI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_ADD; end
            OPCODE_SUBI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_SUB; end
            OPCODE_ANDI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_AND; end
            OPCODE_ORI:  begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_OR;  end
            OPCODE_XORI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_XOR; end
            OPCODE_NORI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_NOR; end
            OPCODE_SLI:  begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_SL;  end
            OPCODE_SRLI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_SRL; end
            OPCODE_SRAI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_SRA; end
            OPCODE_SLTI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_SLT; end
            OPCODE_SGTI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_SGT; end
            OPCODE_NOTI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_NOT; end
            OPCODE_INCI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_INC; end
            OPCODE_DECI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_DEC; end
            OPCODE_HAMI: begin reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_HAM; end
            OPCODE_LUI:  begin a_imm_sel=1'b1; reg_wr_en=1'b1; b_sel=1'b0; alu_funct=ALU_OP_LUI; end
         
            OPCODE_CMOVE: begin
                reg_wr_en  = 1'b1;
                reg_out    = 1'b1;    
                b_sel      = 1'b1;    
                is_cmov    = 1'b1;    
                alu_funct  = ALU_OP_SGT;  
            end
            
            // Load/Store
            OPCODE_LD: begin
                reg_wr_en  = 1'b1;
                b_sel      = 1'b0;
                mem_rd     = 1'b1;
                mem_to_reg = 1'b1;
                alu_funct  = ALU_OP_ADD;
            end
            OPCODE_ST: begin
                b_sel      = 1'b0;
                mem_wr     = 1'b1;
                alu_funct  = ALU_OP_ADD;
            end

            // Branch variants
            OPCODE_BPL, OPCODE_BMI, OPCODE_BZ: begin
                is_branch  = 1'b1;
                alu_src_a  = 1'b1;
                b_sel      = 1'b0;
                alu_funct  = ALU_OP_ADD;
            end
            OPCODE_BR: begin
                is_branch  = 1'b1;
                alu_src_a  = 1'b1;
                b_sel      = 1'b0; 
                immdt_sel  = 1'b1;
                alu_funct  = ALU_OP_ADD;
            end
            
            OPCODE_HALT: begin
                is_halt = 1'b1;
            end
            
            OPCODE_NOP: begin
                // All defaults are NOP
            end

            default: begin
                // All defaults are NOP
            end
        endcase
    end

endmodule