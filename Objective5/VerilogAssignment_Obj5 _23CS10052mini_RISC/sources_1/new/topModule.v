`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2025 15:22:48
// Design Name: 
// Module Name: topModule
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

module topModule(out,clk,rst,btn,instr);
output [15:0] out;
input clk,rst,btn;
input [15:0] instr;

reg [1:0] btn_sync;
always @(posedge clk) begin
    btn_sync <= {btn_sync[0], btn};
end
wire single_pulse_write_en = btn_sync[1] & ~btn_sync[0];

 
wire dft_display_select; 
wire [2:0] alu_op_select;  
wire [3:0] reg_addr_x;         
wire [3:0] reg_addr_y;         
wire [3:0] reg_addr_z;         

assign dft_display_select = instr[15];
assign alu_op_select = instr[14:12];
assign reg_addr_x  = instr[11:8];
assign reg_addr_y  = instr[7:4];
assign reg_addr_z  = instr[3:0];

reg [4:0] alu_op_internal;
always @(*) begin
    case(alu_op_select)
        3'b000: alu_op_internal = 5'd0;  // ADD
        3'b001: alu_op_internal = 5'd1;  // SUB
        3'b010: alu_op_internal = 5'd2;  // AND
        3'b011: alu_op_internal = 5'd4;  //XOR
        3'b100: alu_op_internal = 5'd7;  // SL
        3'b101: alu_op_internal = 5'd9; //SRA
        3'b110: alu_op_internal = 5'd12; // slt
        3'b111: alu_op_internal = 5'd13; //sgt
        default: alu_op_internal = 5'd0; 
    endcase
end

wire [31:0] alu_result;
wire neg_flag, zero_flag;
wire [31:0] reg_data_y, reg_data_z, reg_data_display;

regBank rb_inst (
       .reg_out_y( reg_data_y),
       .reg_out_z(reg_data_z),
       .disp_out(reg_data_display),
       .clk(clk),.rst(rst),.write_en(single_pulse_write_en),
       .addr_y(reg_addr_y),
       .addr_z(reg_addr_z),
       .addr_x(reg_addr_x),
       .data_x(alu_result)
    );
ALU alu_inst (
    .a(reg_data_y),
    .b(reg_data_z),
    .aluOp(alu_op_internal),
    .out(alu_result),
    .negFlag(neg_flag),
    .zeroFlag(zero_flag)
);
assign out = (dft_display_select == 1'b0) ? alu_result[15:0]  // '0' for lower half
                                              : alu_result[31:16]; // '1' for upper half


endmodule
