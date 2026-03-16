`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2025 14:50:22
// Design Name: 
// Module Name: topModule2
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


module topModule2(
    // System signals
    input  wire        clk,
    
    // Board I/O from Nexys 4 DDR
    input  wire [15:0] sw,
    input  wire        btnc,
    input  wire        btnu,
    output wire [15:0] led
);

    // --- Input Mapping and Instruction Decoding ---
    wire        rst = btnu;
    wire        exec = btnc;
    
    wire        display_select = sw[15];
    wire        is_store_op    = sw[14];
    wire [4:0]  rd_rt_addr     = {1'b0, sw[13:10]};
    wire [4:0]  rb_addr        = {1'b0, sw[9:6]};
    wire [31:0] imm_offset     = {{26{sw[5]}}, sw[5:0]};

    // --- FSM State Definitions ---
    localparam S_IDLE        = 3'b000;
    localparam S_EXECUTE     = 3'b001;
    localparam S_MEM_ACCESS  = 3'b010;
    localparam S_WRITEBACK   = 3'b011;
    localparam S_RESET       = 3'b100;

    reg [2:0] current_state;
    reg [7:0] reset_counter;
    
    // --- Datapath and Control Wires ---
    wire [31:0] rb_data, rt_data, alu_result, mem_data_out;
    wire        reg_wr, mem_wr;
    wire [31:0] mem_datain_mux_out;
    reg  [31:0] led_output_reg;
    
    // --- DEBUGGED LOGIC: MUX for the final WORD address sent to memory ---
    wire [7:0] final_mem_word_addr;
    assign final_mem_word_addr = (current_state == S_RESET) ? reset_counter : alu_result[9:2];

    // --- Main FSM Logic ---
    always @(posedge clk) begin
        if (rst) begin
            current_state <= S_RESET;
            reset_counter <= 8'd0;
        end else begin
            case(current_state)
                S_IDLE:       if (exec) current_state <= S_EXECUTE;
                S_EXECUTE:    current_state <= S_MEM_ACCESS;
                S_MEM_ACCESS: if (is_store_op) current_state <= S_IDLE; else current_state <= S_WRITEBACK;
                S_WRITEBACK:  current_state <= S_IDLE;
                // The counter now correctly counts through WORD addresses
                S_RESET:      if (reset_counter == 8'd16) current_state <= S_IDLE; else reset_counter <= reset_counter + 1;
                default:      current_state <= S_IDLE;
            endcase
        end
    end

    // --- Control Signal Generation ---
    assign reg_wr = (current_state == S_WRITEBACK);
    assign mem_wr = (current_state == S_MEM_ACCESS && is_store_op) || (current_state == S_RESET);

    // --- Datapath MUXing for Memory Data Input ---
    // CORRECTED: Data written during reset is now (reset_counter * 2)
    assign mem_datain_mux_out = (current_state == S_RESET) ? {reset_counter[6:0], 1'b0} : rt_data;

    // --- LED Output Register ---
    always @(posedge clk) begin
        if (current_state == S_IDLE) begin
            led_output_reg <= rt_data;
        end
    end

    // --- Module Instantiations ---
    regBank REGFILE (
        .clk(clk), .rst(rst), .Wr(reg_wr),
        .src1(rb_addr), .src2(rd_rt_addr), .dest(rd_rt_addr),
        .A(rb_data), .B(rt_data),
        .Z(mem_data_out)
    );

    ALU ALU_U (
        .a(rb_data), .b(imm_offset),
        .aluOp(5'd0),
        .out(alu_result)
    );

    mem_32bit MEM_U (
        .clka(clk),
        .ena(1'b1),
        .wea({mem_wr}),
        .addra(final_mem_word_addr), // Connect the new corrected address mux
        .dina(mem_datain_mux_out),
        .douta(mem_data_out)
    );

    // --- Final LED Output ---
    assign led = (display_select) ? led_output_reg[31:16] : led_output_reg[15:0];

endmodule




