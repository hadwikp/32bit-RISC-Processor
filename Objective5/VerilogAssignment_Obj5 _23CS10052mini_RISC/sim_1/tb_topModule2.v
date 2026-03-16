`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2025 15:03:29
// Design Name: 
// Module Name: tb_topModule2
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


module tb_topModule2();

    // -- Testbench signals --
    reg clk;
    reg [15:0] sw;
    reg btnc;
    reg btnu;
    wire [15:0] led;

    // -- Instantiate the Device Under Test (DUT) --
    topModule2 dut (
        .clk(clk),
        .sw(sw),
        .btnc(btnc),
        .btnu(btnu),
        .led(led)
    );

    // -- Clock Generator --
    // Generate a 100MHz clock (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -- Main Test Sequence --
    initial begin
        $display("----------------------------------------------------");
        $display("Starting Testbench for topModule2 at time %0t", $time);
        $display("----------------------------------------------------");

        // Initialize all inputs
        sw   <= 16'h0000;
        btnc <= 1'b0;
        btnu <= 1'b0;
        #20; // Wait for a moment

        // == 1. System Reset Test ==
        $display("\n[TEST 1] Resetting the system...");
        btnu <= 1'b1; // Press the reset button
        #100;         // Hold it for 100ns
        btnu <= 1'b0; // Release the reset button
        #20;
        $display("[INFO] System reset complete at time %0t.", $time);


        // == 2. Store Word (ST) Test: ST R2, 8(R4) ==
        // R2 contains value 2. R4 contains value 4.
        // Effective address = R4 + 8 = 4 + 8 = 12.
        // We will store the value 2 into memory at address 12.
        $display("\n[TEST 2] Configuring for ST R2, 8(R4)...");
        sw <= {
            1'b0,        // SW[15] DFT Select: Display lower half
            1'b1,        // SW[14] is_store: 1 for ST
            4'b0010,     // SW[13:10] Src Register: R2
            4'b0100,     // SW[9:6]  Base Register: R4
            6'b001000    // SW[5:0]  Immediate: 8
        };
        #10;
        $display("[INFO] Switches set to: %b", sw);
        $display("[ACTION] Pressing Execute button...");
        btnc <= 1'b1; // Press execute
        #100;
        btnc <= 1'b0; // Release execute
        #100; // Wait for FSM to complete and return to idle
        $display("[INFO] ST operation complete at time %0t.", $time);
        

        // == 3. Load Word (LD) Test: LD R9, 8(R4) ==
        // We will now load the value from address 12 into R9.
        // We expect R9 to become 2.
        $display("\n[TEST 3] Configuring for LD R9, 8(R4)...");
        sw <= {
            1'b0,        // SW[15] DFT Select: Display lower half of R9
            1'b0,        // SW[14] is_store: 0 for LD
            4'b1001,     // SW[13:10] Dst Register: R9
            4'b0100,     // SW[9:6]  Base Register: R4
            6'b001000    // SW[5:0]  Immediate: 8
        };
        #10;
        $display("[INFO] Switches set to: %b", sw);
        $display("[ACTION] Pressing Execute button...");
        btnc <= 1'b1; // Press execute
        #100;
        btnc <= 1'b0; // Release execute
        #100; // Wait for FSM to complete
        $display("[VERIFY] LD operation complete. Checking LED output for R9[15:0]...");
        $display("[INFO] LED output is: %h", led);
        
        // Verification for lower half
        if (led === 16'h0002) begin
            $display("[SUCCESS] Lower half of R9 is 0002 as expected.");
        end else begin
            $display("[FAILURE] Lower half of R9 is %h, expected 0002.", led);
        end

        // Check the upper half of R9
        $display("[VERIFY] Checking upper half of R9...");
        sw[15] <= 1'b1; // Set DFT select to show upper bits
        #20; // Let the combinatorial logic update
        $display("[INFO] LED output is: %h", led);
        if (led === 16'h0000) begin
            $display("[SUCCESS] Upper half of R9 is 0000 as expected.");
        end else begin
            $display("[FAILURE] Upper half of R9 is %h, expected 0000.", led);
        end
        sw[15] <= 1'b0; // Reset DFT switch
        #20;


        // == 4. ST with Negative Offset: ST R5, -4(R10) ==
        // R5 contains 5. R10 contains 10.
        // Effective address = R10 - 4 = 10 - 4 = 6.
        // Note: This is an unaligned address. The hardware will use word address floor(6/4)=1.
        $display("\n[TEST 4] Configuring for ST R5, -4(R10)...");
         sw <= {
            1'b0,        // SW[15] DFT Select
            1'b1,        // SW[14] is_store: 1 for ST
            4'b0101,     // SW[13:10] Src Register: R5
            4'b1010,     // SW[9:6]  Base Register: R10
            6'b111100    // SW[5:0]  Immediate: -4 (6-bit 2's complement)
        };
        #10;
        $display("[INFO] Switches set to: %b", sw);
        $display("[ACTION] Pressing Execute button...");
        btnc <= 1'b1; #100; btnc <= 1'b0; #100;
        $display("[INFO] ST (negative offset) complete at time %0t.", $time);
        

        // == 5. LD with Negative Offset: LD R11, -4(R10) ==
        // Read back the value from address 6 into R11. Expect value 5.
        $display("\n[TEST 5] Configuring for LD R11, -4(R10)...");
        sw <= {
            1'b0,        // SW[15] DFT Select: Display lower half of R11
            1'b0,        // SW[14] is_store: 0 for LD
            4'b1011,     // SW[13:10] Dst Register: R11
            4'b1010,     // SW[9:6]  Base Register: R10
            6'b111100    // SW[5:0]  Immediate: -4
        };
        #10;
        $display("[INFO] Switches set to: %b", sw);
        $display("[ACTION] Pressing Execute button...");
        btnc <= 1'b1; #100; btnc <= 1'b0; #100;
        $display("[VERIFY] LD (negative offset) complete. Checking LED output for R11[15:0]...");
        $display("[INFO] LED output is: %h", led);
        
        if (led === 16'h0005) begin
            $display("[SUCCESS] Lower half of R11 is 0005 as expected.");
        end else begin
            $display("[FAILURE] Lower half of R11 is %h, expected 0005.", led);
        end
        #50;

        $display("\n----------------------------------------------------");
        $display("Testbench finished at time %0t", $time);
        $display("----------------------------------------------------");
        $finish;
    end

endmodule
