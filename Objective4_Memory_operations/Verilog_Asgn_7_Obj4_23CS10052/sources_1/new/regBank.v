`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.10.2025 14:43:33
// Design Name: Register Bank
// Module Name: reg_bank
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A 32x32-bit register bank.
//              - Features two combinatorial read ports (A, B).
//              - Features one synchronous write port (Z).
//              - Register 0 is hardwired to zero.
//              - Registers are initialized to their index on reset.
//
// Dependencies:
//
//////////////////////////////////////////////////////////////////////////////////


module regBank(
    // Control and Clock Signals
    input  wire        clk,
    input  wire        rst,
    input  wire        Wr,    // Write Enable
    input  wire        Rd1,   // Read Enable 1 (Note: Unused with combinatorial read)
    input  wire        Rd2,   // Read Enable 2 (Note: Unused with combinatorial read)

    // Port Addresses
    input  wire [4:0]  src1,  // Read Address for Port A
    input  wire [4:0]  src2,  // Read Address for Port B
    input  wire [4:0]  dest,  // Write Address

    // Data Ports
    input  wire [31:0] Z,     // Write Data In
    output wire [31:0] A,     // Read Data Out 1
    output wire [31:0] B      // Read Data Out 2
);

    // Internal storage for 32 registers, each 32 bits wide.
    reg [31:0] registers [31:0];

    // Integer for reset loop.
    integer i;

    // Synchronous Write and Reset Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, initialize each register with its own index value.
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= i;
            end
        end
        else if (Wr) begin
            // If Write Enable is active, write data Z to the destination register.
            // By convention, we prevent writes to register 0.
            if (dest != 5'd0) begin
                registers[dest] <= Z;
            end
        end
    end

    // Combinatorial Read Logic
    assign A = (src1 == 5'd0) ? 32'b0 : registers[src1];
    assign B = (src2 == 5'd0) ? 32'b0 : registers[src2];

endmodule

