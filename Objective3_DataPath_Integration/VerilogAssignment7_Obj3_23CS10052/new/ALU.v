`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2025 14:16:40
// Design Name: 
// Module Name: ALU
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


module ALU(out,negFlag,zeroFlag,a,b,aluOp);
output reg [31:0] out;
output negFlag,zeroFlag;
input [31:0] a,b;
input [4:0] aluOp;

wire [31:0] add_out,sub_out,inc_out,dec_out,lui_out,sl_out,slt_out,sgt_out,ham_out,sra_out,srl_out;
wire [31:0] incr_out,decr_out;
wire add_cout,sub_cout,of;

adder32 m1(add_out,add_cout,of,a,b);
sub32 m2 (sub_out,sub_cout,of,a,b);
SL m3 (sl_out,a,b[4:0]);
SLT m4 (slt_out,a,b);
SGT m5 (sgt_out,a,b);
SRA m6  (sra_out,a,b[4:0]);
SRL m7 (srl_out ,a ,b[4:0]);
HAM m8 (ham_out,a);
LUI m9 (lui_out,a[15:0]);
incr m10(incr_out,a);
decr m11 (decr_out,a);

always @(*)begin
    case(aluOp)
        5'd0:   out=add_out;
        5'd1:   out=sub_out;
        5'd2:   out=a&b;
        5'd3:   out=a|b;
        5'd4:   out=a^b;
        5'd5:   out=~(a|b);
        5'd6:   out=~a;
        5'd7:   out=sl_out;
        5'd8:   out=srl_out;
        5'd9:   out = sra_out;
        5'd10:  out= incr_out;
        5'd11:  out = decr_out;
        5'd12:  out = slt_out;
        5'd13:  out = sgt_out;
        5'd14:  out = lui_out;
        5'd15:  out = ham_out;
        default: out = 32'd0;     
     endcase
    end
assign negFlag = out[31];
assign zeroFlag = (out == 0) ? 1 : 0;
endmodule
