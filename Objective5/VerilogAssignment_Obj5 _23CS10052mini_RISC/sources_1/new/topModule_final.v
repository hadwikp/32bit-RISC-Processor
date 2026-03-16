`timescale 1ns / 1ps

module topModule_final(led, clk, reset, sw_select);
input wire clk, reset, sw_select;
output wire [15:0] led;

localparam IDLE = 4'd0;
localparam RUN = 4'd1;
localparam FLUSH = 4'd2;
localparam STALL = 4'd3;
localparam EXECUTE_WAIT = 4'd4;
localparam WRITEBACK = 4'd5;
localparam WMFC_READ = 4'd6;
localparam WMFC_WRITE = 4'd7;
localparam WMFC_STORE = 4'd8;
localparam FETCH_WAIT = 4'd9;

localparam R_TYPE_1  = 6'b000000;
localparam MOVE_OP   = 6'b010100;
localparam CMOV_OP   = 6'b010101;
localparam ADDI_OP   = 6'b000001;
localparam SUBI_OP   = 6'b000010;
localparam NOTI_OP   = 6'b001100;
localparam LUI_OP    = 6'b010000;
localparam LOAD_OP   = 6'b010001;
localparam STORE_OP  = 6'b010010;
localparam BR_OP     = 6'b100000;
localparam BMI_OP    = 6'b100001;
localparam BPL_OP    = 6'b100010;
localparam BZ_OP     = 6'b100011;
localparam HALT_OP   = 6'b100100;
localparam NOP_OP    = 6'b100101;

localparam FUNC_ADD = 5'd1;
localparam FUNC_SUB = 5'd2;
localparam FUNC_AND = 5'd3;
localparam FUNC_OR  = 5'd4;
localparam FUNC_XOR = 5'd5;
localparam FUNC_NOR = 5'd6;
localparam FUNC_SL  = 5'd7;
localparam FUNC_SRL = 5'd8;
localparam FUNC_SRA = 5'd9;
localparam FUNC_SLT = 5'd10;
localparam FUNC_SGT = 5'd11;
localparam FUNC_NOT = 5'd12;
localparam FUNC_INC = 5'd13;
localparam FUNC_DEC = 5'd14;
localparam FUNC_HAM = 5'd15;
localparam FUNC_MOVE = 5'd16;

localparam ALU_OP_ADD = 5'd0;
localparam ALU_OP_SUB = 5'd1;
localparam ALU_OP_AND = 5'd2;
localparam ALU_OP_OR  = 5'd3;
localparam ALU_OP_XOR = 5'd4;
localparam ALU_OP_NOR = 5'd5;
localparam ALU_OP_SL  = 5'd6;
localparam ALU_OP_SRL = 5'd7;
localparam ALU_OP_SRA = 5'd8;
localparam ALU_OP_SLT = 5'd9;
localparam ALU_OP_SGT = 5'd10;
localparam ALU_OP_NOT = 5'd11;
localparam ALU_OP_INC = 5'd12;
localparam ALU_OP_DEC = 5'd13;
localparam ALU_OP_HAM = 5'd14;
localparam ALU_OP_LUI = 5'd15;

reg  sync_reset_r1;
reg  sync_reset_r2;
wire sync_reset;

always @(posedge clk) begin
    sync_reset_r1 <= reset;
    sync_reset_r2 <= sync_reset_r1;
end
assign sync_reset = sync_reset_r2;

reg [3:0] state, next_state;
reg [31:0] pc;
wire [31:0] pc_plus_4 = pc + 4;

wire fsm_bram_enable; 

wire [31:0] instruction_from_bram;
blk_mem_gen_0 instruction_memory_unit (
  .clka(clk), 
  .ena(fsm_bram_enable), 
  .wea(1'b0),
  .addra(pc[6:2]), 
  .dina(32'd0), 
  .douta(instruction_from_bram)
);

wire [5:0] opcode = instruction_from_bram[31:26];
wire [4:0] rs     = instruction_from_bram[25:21];
wire [4:0] rt     = instruction_from_bram[20:16];
wire [4:0] rd     = instruction_from_bram[15:11];
wire [4:0] func   = instruction_from_bram[4:0];
wire [31:0] imm_i_type = {{16{instruction_from_bram[15]}}, instruction_from_bram[15:0]};

reg [31:0] next_pc;

reg [31:0] alu_in_A_reg, alu_in_B_reg;
reg [4:0]  alu_op_reg;
reg [31:0] alu_out_reg;

reg [31:0] fsm_alu_in_A;
reg [31:0] fsm_alu_in_B;
reg [31:0] fsm_write_data;
reg [4:0]  fsm_alu_op;

reg [4:0]  wr_addr_latch;
reg [4:0]  rt_latch;

wire [31:0] reg_data_A_wire, reg_data_B_wire;
wire [31:0] alu_out_wire;
wire [31:0] mem_read_data;
wire        negFlag, zeroFlag;

ALU alu_unit (
    .out(alu_out_wire), 
    .negFlag(negFlag), 
    .zeroFlag(zeroFlag),
    .a(alu_in_A_reg),
    .b(alu_in_B_reg), 
    .aluOp(alu_op_reg)
);

wire [31:0] display_data_output;
reg [4:0]  wr_addr_reg;
reg        wrReg_final, rdMem_final, wrMem_final;

regBank reg_bank_unit (
    .clk(clk), 
    .rst(sync_reset),
    .Wr(wrReg_final),
    .src1(rs), .src2(rt),
    .dest(wr_addr_reg),
    .Z(fsm_write_data),
    .A(reg_data_A_wire), .B(reg_data_B_wire),
    .disp_addr(5'd2),
    .disp_data(display_data_output)
);

always @(posedge clk) begin
    if (sync_reset) begin
        alu_in_A_reg <= 32'd0;
        alu_in_B_reg <= 32'd0;
        alu_op_reg <= 5'd0;
        alu_out_reg <= 32'd0;
    end
    else begin
        alu_in_A_reg <= fsm_alu_in_A;
        alu_in_B_reg <= fsm_alu_in_B;
        alu_op_reg <= fsm_alu_op;
        alu_out_reg <= alu_out_wire;
    end
end

always @(posedge clk) begin
    if (sync_reset) begin
        state <= RUN;
        pc    <= 32'd0;
        wr_addr_latch <= 5'd0;
        rt_latch <= 5'd0;
    end
    else begin
        if (state == FETCH_WAIT) begin
            if (next_state == EXECUTE_WAIT) begin
                if (opcode == R_TYPE_1 || opcode == MOVE_OP)
                    wr_addr_latch <= rd;
                else if (opcode == ADDI_OP || opcode == SUBI_OP || 
                         (opcode >= NOTI_OP && opcode <= (NOTI_OP + 3)) || 
                         opcode == LUI_OP)
                    wr_addr_latch <= rt;
                else if (opcode == LOAD_OP) begin
                    wr_addr_latch <= rt;
                    rt_latch <= rt;
                end
                else
                    wr_addr_latch <= 5'd0;
            end
        end
        
        state <= next_state;
        pc <= next_pc;
    end
end

reg fsm_bram_enable_reg;

always @(*) begin
    next_state = state;
    next_pc = pc_plus_4;
    
    wrMem_final = 1'b0;
    wrReg_final = 1'b0;
    rdMem_final = 1'b0;
    wr_addr_reg = 5'd0;
    
    fsm_alu_op = 5'd0;
    fsm_alu_in_A = 32'd0;
    fsm_alu_in_B = 32'd0;
    fsm_write_data = 32'd0;
    
    fsm_bram_enable_reg = 1'b0;
    
    case (state)
        IDLE: begin
            next_state = IDLE;
            next_pc = pc;
        end
        
        RUN: begin
            fsm_bram_enable_reg = 1'b1;
            next_state = FETCH_WAIT;
            next_pc = pc;
        end

        FETCH_WAIT: begin
            next_pc = pc_plus_4;

            if (opcode == HALT_OP) begin
                next_state = IDLE;
                next_pc = pc;
            end
            
            else if ( (opcode == R_TYPE_1) || (opcode == MOVE_OP) ||
                      (opcode >= ADDI_OP && opcode <= (ADDI_OP + 10)) ||
                      (opcode >= NOTI_OP && opcode <= (NOTI_OP + 3)) ||
                      (opcode == LUI_OP) ) begin
                
                if (opcode == R_TYPE_1) begin
                    if (func >= FUNC_ADD && func <= FUNC_SGT) begin
                        fsm_alu_in_A = reg_data_A_wire; fsm_alu_in_B = reg_data_B_wire; fsm_alu_op = func - 5'd1;
                    end else if (func >= FUNC_NOT && func <= FUNC_HAM) begin
                        fsm_alu_in_A = reg_data_B_wire; fsm_alu_in_B = 32'd0; fsm_alu_op = func - 5'd1;
                    end else if (func == FUNC_MOVE) begin
                        fsm_alu_in_A = reg_data_A_wire; fsm_alu_in_B = 32'd0; fsm_alu_op = ALU_OP_ADD;
                    end
                end else if (opcode == MOVE_OP) begin
                    fsm_alu_in_A = reg_data_A_wire; fsm_alu_in_B = 32'd0; fsm_alu_op = ALU_OP_ADD;
                end else if (opcode >= ADDI_OP && opcode <= (ADDI_OP + 10)) begin
                    fsm_alu_in_A = reg_data_A_wire; fsm_alu_in_B = imm_i_type; fsm_alu_op = (opcode - 6'd1) & 5'h1F;
                end else if (opcode >= NOTI_OP && opcode <= (NOTI_OP + 3)) begin
                    fsm_alu_in_A = imm_i_type; fsm_alu_in_B = 32'd0; fsm_alu_op = (opcode - 6'd1) & 5'h1F;
                end else if (opcode == LUI_OP) begin
                    fsm_alu_in_A = 32'd0; fsm_alu_in_B = imm_i_type; fsm_alu_op = ALU_OP_LUI;
                end
                next_state = EXECUTE_WAIT;
            end

            else if (opcode == STORE_OP || opcode == LOAD_OP) begin
                fsm_alu_in_A = reg_data_A_wire;
                fsm_alu_in_B = imm_i_type;
                fsm_alu_op = ALU_OP_ADD;
                next_state = EXECUTE_WAIT;
            end

            else if (opcode == BR_OP) begin
                next_pc = pc + imm_i_type;
                next_state = FLUSH;
            end
            else if (opcode == BMI_OP) begin
                if (reg_data_A_wire[31] == 1'b1) begin
                    next_pc = pc + imm_i_type; next_state = FLUSH;
                end
            end
            else if (opcode == BPL_OP) begin
                if (reg_data_A_wire[31] == 1'b0 && reg_data_A_wire != 32'd0) begin
                    next_pc = pc + imm_i_type; next_state = FLUSH;
                end
            end
            else if (opcode == BZ_OP) begin
                if (reg_data_A_wire == 32'd0) begin
                    next_pc = pc + imm_i_type; next_state = FLUSH;
                end
            end
            
            else if (opcode == NOP_OP) begin
                next_state = RUN;
            end
            
            else begin
                next_state = EXECUTE_WAIT; 
            end
        end

        EXECUTE_WAIT: begin
            if (opcode == LOAD_OP)
                next_state = WMFC_READ;
            else if (opcode == STORE_OP)
                next_state = WMFC_STORE;
            else
                next_state = WRITEBACK;
            next_pc = pc;
        end

        WRITEBACK: begin
            fsm_write_data = alu_out_reg;
            wr_addr_reg = wr_addr_latch;
            wrReg_final = 1'b1;
            next_state = RUN;
            next_pc = pc; 
        end

        WMFC_STORE: begin
            wrMem_final = 1'b1;
            next_state = RUN;
            next_pc = pc;
        end

        WMFC_READ: begin
            rdMem_final = 1'b1;
            next_state = WMFC_WRITE;
            next_pc = pc;
        end
        
        WMFC_WRITE: begin
            wr_addr_reg = wr_addr_latch;
            fsm_write_data = mem_read_data;
            wrReg_final = 1'b1;
            next_pc = pc;
            
            fsm_bram_enable_reg = 1'b1;
            if ((rt_latch != 0) && (rt_latch == instruction_from_bram[25:21] || rt_latch == instruction_from_bram[20:16])) begin
                next_state = STALL;
            end else begin
                next_state = RUN;
            end
        end
        
        FLUSH: begin
            next_state = RUN;
            next_pc = pc;
        end
        
        STALL: begin
            fsm_bram_enable_reg = 1'b1;
            if ((rt_latch != 0) && (rt_latch == instruction_from_bram[25:21] || rt_latch == instruction_from_bram[20:16])) begin
                next_state = STALL;
            end else begin
                next_state = RUN;
            end
            next_pc = pc;
        end

        default: begin
            next_state = IDLE;
            next_pc = pc;
        end
    endcase
end

assign fsm_bram_enable = fsm_bram_enable_reg;

reg [7:0] mem_addr_reg;
reg mem_wr_reg, mem_rd_reg;

always @(posedge clk) begin
    if (sync_reset) begin
        mem_addr_reg <= 8'd0;
        mem_wr_reg <= 1'b0;
        mem_rd_reg <= 1'b0;
    end
    else begin
        mem_addr_reg <= alu_out_reg[9:2];
        mem_wr_reg <= wrMem_final;
        mem_rd_reg <= rdMem_final;
    end
end

mem_32bit data_memory_bram (
    .clka(clk), 
    .ena(mem_rd_reg | mem_wr_reg),
    .wea({4{mem_wr_reg}}),
    .addra(mem_addr_reg),
    .dina(reg_data_B_wire),
    .douta(mem_read_data)
);

reg [15:0] led_reg;
always @(posedge clk) begin
    if (sync_reset) begin
        led_reg <= 16'd0;
    end
    else
        led_reg <= sw_select ? display_data_output[31:16] : display_data_output[15:0];
end

assign led = led_reg;

endmodule
