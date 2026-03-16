`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 15:58:52
// Design Name: 
// Module Name: control_unit
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


module control_unit(opcode,aluSrc,wrReg,rdMem,wrMem,dOut,regAluOut,fnCode,bOp,immSel);
input  wire [5:0] opcode;
output reg        aluSrc;
output reg        wrReg;
output reg        rdMem;
output reg        wrMem;
output reg [1:0]  dOut;
output reg        regAluOut;
output reg [4:0]  fnCode;
output reg [2:0]  bOp; 
output reg        immSel;

always @(*) begin
    aluSrc    = 1'b0;
    wrReg     = 1'b0;
    rdMem     = 1'b0;
    wrMem     = 1'b0;
    dOut      = 2'b00;
    regAluOut = 1'b0;
    fnCode    = 5'b00000;
    bOp       = 3'b000;   
    immSel    = 1'b0;
    case(opcode)
        6'b000000: begin
            aluSrc    = 1'b1;
            wrReg     = 1'b1;
            dOut      = 2'b00;
            regAluOut = 1'b1;
        end
        6'b000001, 6'b000010, 6'b000011, 6'b000100, 6'b000101, 6'b000110,
        6'b000111, 6'b001000, 6'b001001, 6'b001010, 6'b001011, 6'b001100,
        6'b001101, 6'b001110, 6'b001111: begin
            wrReg     = 1'b1;
            dOut      = 2'b00;
            regAluOut = 1'b0;
            fnCode    = opcode -1;
        end
        6'b010000: begin
            wrReg     = 1'b1;
            dOut      = 2'b00;
            regAluOut = 1'b0;
            fnCode    = 5'd15;
        end
        6'b010001: begin
            wrReg     = 1'b1;
            rdMem     = 1'b1;
            dOut      = 2'b01;
            regAluOut = 1'b0;
            fnCode    = 5'd0; 
        end

        6'b010010: begin
            wrMem     = 1'b1;
            fnCode    = 5'd0;
        end
        6'b100000: begin
            bOp    = 3'b100;
            immSel = 1'b1;    // Select J-type immediate
            fnCode = 5'd0;    // ADD for address calc
        end

        // I-Type Branches (BMI, BPL, BZ)
        6'b100001, 6'b100010, 6'b100011: begin
            bOp    = {1'b1, opcode[1:0]}; // Generate bOp from opcode
            immSel = 1'b0;    // Select I-type immediate
            fnCode = 5'd0;    // ADD for address calc
        end
        default: begin
                // Handles HALT, NOP etc.
            end
    endcase
    
end                     
endmodule
