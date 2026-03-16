`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: regBank .
//////////////////////////////////////////////////////////////////////////////////

module regBank(
    // Control and Clock Signals
    input  wire        clk,
    input  wire        rst,
    input  wire        Wr,    // Write Enable
    // Port Addresses
    input  wire [4:0]  src1,  // Read Address for Port A
    input  wire [4:0]  src2,  // Read Address for Port B
    input  wire [4:0]  dest,  // Write Address
    // Data Ports
    input  wire [31:0] Z,     // Write Data In
    output wire [31:0] A,     // Read Data Out 1
    output wire [31:0] B,      // Read Data Out 2
    input wire [4:0] disp_addr,
    output wire[31:0] disp_data
);
    reg [31:0] registers [31:0];
    integer i;
    // --- SYNCHRONOUS Write and Reset block ---
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= i;
            end
        end
        else if (Wr) begin
            if (dest != 5'd0) begin
                registers[dest] <= Z;
            end
        end
    end

    assign A = (src1 == 5'd0) ? 32'b0 : registers[src1];
    assign B = (src2 == 5'd0) ? 32'b0 : registers[src2];
    assign disp_data=(disp_addr==5'd0) ? 32'd0 : registers[disp_addr];

endmodule