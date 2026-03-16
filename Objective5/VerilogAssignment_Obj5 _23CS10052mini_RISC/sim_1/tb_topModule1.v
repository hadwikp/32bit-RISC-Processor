`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: tb_topModule_comprehensive
// Description:
// Testbench for the 'Verilog_Assignment_Mini_RISCV' ISA.
// Runs a comprehensive test program to validate most instructions.
//
//////////////////////////////////////////////////////////////////////////////////

module tb_topModule1; 

    // --- DUT I/Os ---
    reg clk;
    reg reset;
    reg sw_select;
    wire [15:0] led;
   
    // --- Instantiate DUT ---
    topModule_final uut (
        .led(led),
        .clk(clk),
        .reset(reset),
        .sw_select(sw_select)
    );
   
    // --- Clock Generation (100 MHz -> 10 ns period) ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- Task for checking the final result ---
    task check_final_state;
    begin
        #20; // Allow signals to settle
        $display("[%0t] Now in IDLE state. Verifying results...", $time);

        // --- Check Registers ---
        check_reg(1, 0);
        check_reg(2, 19);
        check_reg(3, 30);
        check_reg(4, 10);
        check_reg(5, 1);
        check_reg(6, 0);
        check_reg(7, 32'hFFFFFFF5); // ~10
        check_reg(9, 32'hAAAA5555);
        check_reg(11, 32'hAAAA5555);
        check_reg(12, 32'hAAAA5555);
        check_reg(13, 11);
        check_reg(14, 11);
        check_reg(15, 4);

        // --- Check Memory ---
        // Address 8 -> 8/4 = mem[2]
        if (uut.data_memory_bram.mem[2] === 32'hAAAA5555) begin
            $display("  -> SUCCESS: Data Memory[2] holds 0x%h.", uut.data_memory_bram.mem[2]);
        end else begin
            $display("  -> FAILURE: Data Memory[2] holds 0x%h, expected 0x%h", uut.data_memory_bram.mem[2], 32'hAAAA5555);
        end
       
        // --- Check Final LED Output (should be R2) ---
        sw_select = 0; #5;
        if (led === 16'h0013) // 19
            $display("  -> SUCCESS: LED[15:0] (R2) shows 16'h%h", led);
        else
            $display("  -> FAILURE: LED[15:0] (R2) shows 16'h%h, expected 16'h0013", led);
           
        sw_select = 1; #5;
        if (led === 16'h0000)
            $display("  -> SUCCESS: LED[31:16] (R2) shows 16'h%h", led);
        else
            $display("  -> FAILURE: LED[31:16] (R2) shows 16'h%h, expected 16'h0000", led);

    end
    endtask

    // Helper task to check a register
    task check_reg;
        input [4:0] addr;
        input [31:0] expected_val;
        reg [31:0] actual_val;
    begin
        actual_val = uut.reg_bank_unit.registers[addr];
        if (actual_val === expected_val)
            $display("  -> SUCCESS: R%0d = %0d (0x%h)", addr, actual_val, actual_val);
        else
            $display("  -> FAILURE: R%0d = %0d (0x%h), expected %0d (0x%h)", addr, actual_val, actual_val, expected_val, expected_val);
    end
    endtask

    // --- Test Control ---
    initial begin
        //$dumpfile("processor_tb.vcd");
        $dumpvars(0, tb_topModule1);

        // Monitor key signals from the multi-cycle FSM
        $monitor("[%0t] State=%d, PC=%0d, Instr=%h, R1_Data=%0d, R2_Data=%0d, ALU_Out=%h, LED_Out=%h",
                 $time, uut.state, uut.pc, uut.instruction_from_bram,
                 uut.reg_bank_unit.registers[1], uut.reg_bank_unit.registers[2], // Peek inside regBank
                 uut.alu_out_wire, led);
                 
        reset = 1;
        sw_select = 0;
        #50; // Hold reset
        reset = 0;
        $display("[%0t] Reset released. Program execution starts.", $time);

        // Wait until the processor FSM reaches the IDLE state (state=0)
        wait (uut.state === 3'd0);

        // Once halted, run our verification tasks
        check_final_state();
       
        $display("\n=== TEST COMPLETE ===");
        $finish;
    end

endmodule

// -----------------------------------------------------------------------------
// Behavioral Mock: Instruction ROM (blk_mem_gen_0)
// -----------------------------------------------------------------------------
module blk_mem_gen_0(
    input wire clka,
    input wire ena,
    input wire [0:0] wea, // Not used for ROM
    input wire [4:0] addra, // 5 bits for pc[6:2]
    input wire [31:0] dina,
    output reg [31:0] douta
);

    reg [31:0] mem [0:31];
    integer i;
    initial begin
        // Hand-assembled comprehensive test program
        // PC   Addr
        mem[0]  = 32'h0401000A; // 0:  ADDI R1, R0, 10
        mem[1]  = 32'h04020014; // 4:  ADDI R2, R0, 20
        mem[2]  = 32'h4009AAAA; // 8:  LUI  R9, 0xAAAA
        mem[3]  = 32'h11295555; // 12: ORI  R9, R9, 0x5555
        mem[4]  = 32'h48090008; // 16: ST   R9, 8(R0)
        mem[5]  = 32'h440B0008; // 20: LD   R11, 8(R0)
        mem[6] = 32'h94000000;
        mem[7]  = 32'h51606000; // 24: MOVE R12, R11
        mem[8]  = 32'h00221801; // 28: ADD  R3, R1, R2
        mem[9]  = 32'h00622002; // 32: SUB  R4, R3, R2
        mem[10]  = 32'h0022280A; // 36: SLT  R5, R1, R2
        mem[11] = 32'h0022300B; // 40: SGT  R6, R1, R2
        mem[12] = 32'h0001380C; // 44: NOT  R7, R1
        mem[13] = 32'h0001080D; // 48: INC  R1, R1
        mem[14] = 32'h0002100E; // 52: DEC  R2, R2
        mem[15] = 32'h54226800; // 56: CMOV R13, R1, R2
        mem[17] = 32'h54417000; // 60: CMOV R14, R2, R1
        mem[16] = 32'h94000000; // 64: NOP
        mem[18] = 32'h8C000004; // 68: BZ   R0, #4 (Target=72+4+4 = 80)
        mem[19] = 32'h040F0001; // 72: ADDI R15, R0, 1  (SKIPPED)
        mem[20] = 32'h00000000; // 76: (SKIPPED) -> Not in log, but to be safe
        mem[21] = 32'h85E00004; // 80: BMI  R7, #4 (Target=80+4+4 = 88)
        mem[22] = 32'h07EF0002; // 84: ADDI R15, R15, 2 (SKIPPED)
        mem[23] = 32'h07EF0004; // 88: ADDI R15, R15, 4 (R15 = 0+4=4)
        mem[24] = 32'h0421FFFF; // 92: ADDI R1, R1, -1 (LOOP START)
        mem[25] = 32'h8820FFF8; // 96: BPL  R1, #-8 (Target=96+4-8 = 92)
        mem[26] = 32'h90000000; // 100: HALT
       
        // Fill rest with HALT
        for (i = 27; i < 32; i = i + 1) mem[i] = 32'h90000000;
        douta = 32'h00000000;
    end

    always @(posedge clka) begin
        if (ena)
            douta <= mem[addra];
    end
endmodule

// -----------------------------------------------------------------------------
// Behavioral Mock: Data Memory (mem_32bit)
// -----------------------------------------------------------------------------
module mem_32bit(
    input wire clka,
    input wire ena,
    input wire [3:0] wea,  // 4-bit write enable
    input wire [7:0] addra, // 8 bits for alu_out_wire[9:2]
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
            // Byte-enable write logic
            if (wea[0]) mem[addra][7:0]   <= dina[7:0];
            if (wea[1]) mem[addra][15:8]  <= dina[15:8];
            if (wea[2]) mem[addra][23:16] <= dina[23:16];
            if (wea[3]) mem[addra][31:24] <= dina[31:24];
           
            // Read logic (1-cycle latency)
            douta <= mem[addra];
        end
    end
endmodule