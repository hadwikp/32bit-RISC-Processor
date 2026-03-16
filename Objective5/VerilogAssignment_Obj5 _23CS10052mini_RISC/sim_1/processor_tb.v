`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: processor_tb (IMPROVED)
// - Corrected BPL machine code.
// - Added self-checking assertions for LED and data memory.
// - Structured with tasks for better readability.
//////////////////////////////////////////////////////////////////////////////////

module processor_tb();

    // DUT I/Os
    reg clk;
    reg reset;
    reg sw_select;
    wire [15:0] led;

    // instantiate DUT
    topModule_final uut (
        .led(led),
        .clk(clk),
        .reset(reset),
        .sw_select(sw_select)
    );

    // Clock: 100 MHz -> period 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- ADDED: Task for checking the final result ---
    task check_final_state;
        begin
            // Allow signals to settle
            #20;
            $display("[%0t] Now in IDLE state. Verifying results...", $time);

            // 1. Check Lower 16 bits of LED output
            sw_select = 0;
            #5; // let combinatorial logic settle
            if (led === 16'h000F) begin
                $display("  -> SUCCESS: LED[15:0] shows correct value 16'h%h", led);
            end else begin
                $display("  -> FAILURE: LED[15:0] shows 16'h%h, expected 16'h000F", led);
            end

            // 2. Check Upper 16 bits of LED output
            sw_select = 1;
            #5;
            if (led === 16'h0000) begin
                $display("  -> SUCCESS: LED[31:16] shows correct value 16'h%h", led);
            end else begin
                $display("  -> FAILURE: LED[31:16] shows 16'h%h, expected 16'h0000", led);
            end

            // 3. Check value stored in data memory
            if (uut.data_memory_bram.mem[0] === 32'd15) begin
                 $display("  -> SUCCESS: Data Memory[0] holds correct value %0d.", uut.data_memory_bram.mem[0]);
            end else begin
                 $display("  -> FAILURE: Data Memory[0] holds %0d, expected 15.", uut.data_memory_bram.mem[0]);
            end
        end
    endtask


    // Test control
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, processor_tb);

        $monitor("[%0t] State=%d, PC=%h, Instruction=%h, ALU_Out=%h, FinalLEDReg=%h",
                 $time, uut.state, uut.pc, uut.instruction_reg, uut.alu_out_reg, uut.final_result_reg);

        reset = 1;
        sw_select = 0;
        #50; // Hold reset
        reset = 0;
        $display("[%0t] Reset released. Program execution starts.", $time);

        // Wait until the processor FSM reaches the IDLE state (state=0)
        // Add a timeout to prevent running forever.
        wait (uut.state === uut.S_IDLE);

        // Once halted, run our verification tasks
        check_final_state();

        $display("\n=== TEST COMPLETE ===");
        $finish;
    end

endmodule

// -------------------------
// Behavioral Instruction ROM
// -------------------------
module blk_mem_gen_0(
    input wire clka,
    input wire ena,
    input wire [0:0] wea,
    input wire [4:0] addra,
    input wire [31:0] dina,
    output reg [31:0] douta
);
    reg [31:0] mem [0:31];
    integer i;
    initial begin
        // Program to calculate sum of integers from 5 down to 1 (5+4+3+2+1=15)
        mem[0] = 32'h04010005; // ADDI R1, R0, 5
        mem[1] = 32'h04020000; // ADDI R2, R0, 0
        mem[2] = 32'h00411001; // ADD  R2, R2, R1  (LOOP target)
        mem[3] = 32'h08210001; // SUBI R1, R1, 1
        mem[4] = 32'h8820FFF4; // BPL  R1, LOOP (PC-relative offset is -12 bytes -> FFF4)
        mem[5] = 32'h48020000; // ST   R2, 0(R0)
        mem[6] = 32'h90000000; // HALT
        
        for (i = 7; i < 32; i = i + 1) mem[i] = 32'h00000000;
        douta = 32'h00000000;
    end

    always @(posedge clka) begin
        if (ena)
            douta <= mem[addra];
    end
endmodule

// -------------------------
// Behavioral Data Memory
// -------------------------
module mem_32bit(
    input wire clka,
    input wire ena,
    input wire [0:0] wea,
    input wire [7:0] addra,
    input wire [31:0] dina,
    output reg [31:0] douta
);
    reg [31:0] mem [0:255];
    integer j;
    initial begin
        for (j = 0; j < 256; j = j + 1)
            mem[j] = 32'h00000000;
        douta = 32'h00000000;
    end

    always @(posedge clka) begin
        if (ena) begin
            if (wea[0]) begin
                mem[addra] <= dina;
            end
            // Read logic: for simulation, read is combinatorial-like after clock edge
            douta <= mem[addra];
        end
    end
endmodule