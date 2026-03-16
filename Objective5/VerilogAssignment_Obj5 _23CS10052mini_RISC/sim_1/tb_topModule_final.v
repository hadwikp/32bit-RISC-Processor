`timescale 1ns / 1ps

module tb_topModule_final;

// Testbench signals
reg clk;
reg reset;
reg sw_select;
wire [15:0] led;

// Instantiate the Unit Under Test (UUT)
topModule_final uut (
    .led(led),
    .clk(clk),
    .reset(reset),
    .sw_select(sw_select)
);

// Clock generation - 100MHz (10ns period)
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Counter for tracking clock cycles
integer cycle_count;

// Simulation control and monitoring
initial begin
    // Initialize inputs
    reset = 1;
    sw_select = 0;
    cycle_count = 0;
    
    #100;
    
    // Release reset
    reset = 0;
    #20;
    
    $display("========================================");
    $display("Starting Post-Implementation Simulation");
    $display("========================================");
    $display("Monitoring LED output every 10 cycles...");
    $display("========================================");
    
    repeat(200) begin
        @(posedge clk);
        cycle_count = cycle_count + 1;
        
        if (cycle_count % 10 == 0) begin
            $display("Cycle %3d: LED = %h (%d decimal)", cycle_count, led, led);
        end
    end
    
    $display("\n========================================");
    $display("Final Results After %d Cycles:", cycle_count);
    $display("========================================");
    
    // Check both switch positions
    sw_select = 0;
    #20;
    $display("LED Output (sw_select=0, lower 16 bits): 0x%04h = %d decimal", led, led);
    
    sw_select = 1;
    #20;
    $display("LED Output (sw_select=1, upper 16 bits): 0x%04h = %d decimal", led, led);
    
    // Reset switch to default position
    sw_select = 0;
    #20;
    
    $display("\n========================================");
    $display("TEST RESULTS:");
    $display("========================================");
    $display("Expected: 15 (0x000F)");
    $display("Actual:   %d (0x%04h)", led, led);
    
    if (led == 16'd15) begin
        $display("*** TEST PASSED! ***");
    end else if (led == 16'd5) begin
        $display("*** TEST FAILED - Got 5 instead of 15 ***");
        $display("This suggests a branch/control flow issue");
    end else begin
        $display("*** TEST FAILED - Got %d instead of 15 ***", led);
    end
    $display("========================================");
    
    #100;
    $finish;
end

initial begin
    #100000; // 100 microseconds timeout
    $display("\n========================================");
    $display("TIMEOUT - Simulation took too long");
    $display("Final LED value: %d (0x%04h)", led, led);
    $display("Total cycles: %d", cycle_count);
    $display("========================================");
    $finish;
end

// Simple LED change detector
reg [15:0] led_prev;
initial led_prev = 16'h0;

always @(posedge clk) begin
    if (led != led_prev) begin
        $display("Cycle %3d: LED changed: %h -> %h (%d -> %d)", 
                 cycle_count, led_prev, led, led_prev, led);
        led_prev <= led;
    end
end

// Generate VCD file for waveform viewing (optional, can be large for post-impl)
initial begin
    $dumpfile("post_impl_sim.vcd");
    $dumpvars(0, tb_topModule_final);
end

endmodule