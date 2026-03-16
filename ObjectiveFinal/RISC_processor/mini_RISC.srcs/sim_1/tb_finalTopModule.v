`timescale 1ns / 1ps

module tb_finalTopModule; 

    reg clk;
    reg rst;
    reg sw;
    wire [15:0] led;
    integer i;

    topModule_final UUT (
        .clk(clk),
        .reset(rst),      
        .sw_select(sw),  
        .led(led)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $display("=================================================");
        $display("               PROCESSOR SIMULATION              ");
        $display("=================================================\n");

        rst = 1;
        sw = 0;
        #15;
        rst = 0;
        
        $display("Reset released. Processor is now running...");
        #2000; 
    end
    
    always @(posedge clk) begin
          if (UUT.current_state == 3'b000 && UUT.PC != 0) begin 
            $display("HALT reached at T=%0t PC=%08h. Processor is now IDLE.", $time, UUT.PC);
            $finish;
          end
    end

endmodule