`timescale 1ns / 1ps

module topModule_final(
    output reg [15:0] led,
    input  wire        clk,
    input  wire        reset,
    input  wire        sw_select
);

parameter IDLE          = 3'b000,
          RUN_FETCH     = 3'b001,
          INST_MEM_WAIT = 3'b010,
          RUN_EXECUTE   = 3'b011,
          MEM_WAIT      = 3'b100,
          WRITEBACK     = 3'b101;

reg [2:0] current_state;
reg [1:0] mem_wait_count;
reg [31:0] PC;
reg [31:0] ins_reg;
reg [31:0] rs_data_reg, rt_data_reg;
reg [31:0] alu_res_reg;
reg [31:0] mem_data_reg;

// Wires
wire [31:0] ins;
wire [31:0] rs_out, rt_out;
wire [5:0] opcode, func;
wire [4:0] rs, rt, rd;
wire [4:0] shamt;
wire [15:0] imm16;
wire [25:0] imm26;
wire [4:0] aluOp;
wire [31:0] alu_out, final_imm;
wire [31:0] alu_ina, alu_inb;
wire [4:0] dest_reg;
wire reg_wr, reg_out, b_sel, alu_src_a, branch_taken, mem_rd, mem_wr, mem_to_reg, a_imm_sel;
wire immdt_sel, is_halt;
wire is_cmov;  
wire [31:0] reg_write_data;
wire [31:0] mem_read_data;
wire negFlag, zeroFlag;
wire [2:0] bOp_wire;

// FSM logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= RUN_FETCH;
        mem_wait_count <= 2'd0;
        PC <= 32'd0;
    end else begin
        case(current_state)
            IDLE: begin
                current_state <= IDLE;
                if(sw_select) led <= rt_out[31:16];
                else led <= rt_out[15:0];
            end

            RUN_FETCH: begin
                mem_wait_count <= 0;
                current_state <= INST_MEM_WAIT;
            end

            INST_MEM_WAIT: begin
                if(mem_wait_count == 2'd2) begin
                    ins_reg <= ins;
                    rs_data_reg <= rs_out;
                    rt_data_reg <= rt_out;

                    if(is_halt)
                        current_state <= IDLE;
                    else
                        current_state <= RUN_EXECUTE;
                end else begin
                    mem_wait_count <= mem_wait_count + 1;
                    current_state <= INST_MEM_WAIT;
                end
            end

            RUN_EXECUTE: begin
                alu_res_reg <= alu_out;
                if(mem_rd || mem_wr) begin
                    mem_wait_count <= 0;
                    current_state <= MEM_WAIT;
                end else if(branch_taken) begin
                    PC <= alu_out;
                    current_state <= RUN_FETCH;
                end else begin
                    current_state <= WRITEBACK;
                end
            end

            MEM_WAIT: begin
                if(mem_wait_count == 2'd2) begin
                    mem_data_reg <= mem_read_data;
                    current_state <= WRITEBACK;
                end else begin
                    mem_wait_count <= mem_wait_count + 1;
                    current_state <= MEM_WAIT;
                end
            end

            WRITEBACK: begin
                if(~branch_taken) PC <= PC + 4;
                current_state <= RUN_FETCH;
            end

        endcase
    end
end

instr i_mem (
    .clka(clk), 
    .ena(1'b1), 
    .addra(PC[9:2]), 
    .douta(ins)
);

assign opcode = ins_reg[31:26];
assign func = ins_reg[4:0];
assign rs = ins_reg[25:21];
assign rt = ins_reg[20:16];
assign rd = ins_reg[15:11];
assign shamt = ins_reg[10:5];
assign imm16 = ins_reg[15:0];
assign imm26 = ins_reg[25:0];

control_unit cu(
    .opcode(opcode),
    .funct(func),
    .alu_funct(aluOp),
    .alu_src_a(alu_src_a), 
    .reg_wr_en(reg_wr),
    .b_sel(b_sel),
    .immdt_sel(immdt_sel),
    .reg_out(reg_out),
    .mem_rd(mem_rd),
    .mem_wr(mem_wr),
    .mem_to_reg(mem_to_reg),
    .a_imm_sel(a_imm_sel),
    .is_halt(is_halt),
    .is_cmov(is_cmov) 
);

assign dest_reg = reg_out ? rd : rt;
wire [4:0] rs_addr = (current_state == INST_MEM_WAIT) ? ins[25:21] : rs;
wire [4:0] rt_addr = (current_state == IDLE) ? 5'd2 : ((current_state == INST_MEM_WAIT) ? ins[20:16] : rt);

regBank REGFILE(
    .clk(clk),
    .rst(reset),
    .Wr(reg_wr && (current_state == WRITEBACK)),
    .src1(rs_addr),
    .src2(rt_addr),
    .dest(dest_reg),
    .Z(reg_write_data),
    .A(rs_out),
    .B(rt_out),
    .disp_addr(5'd0),
    .disp_data()
);

// ALU
ALU alu(
    .out(alu_out),
    .negFlag(negFlag),
    .zeroFlag(zeroFlag),
    .a(alu_ina),
    .b(alu_inb),
    .aluOp(aluOp) 
);

wire [31:0] imm16_ext = {{16{imm16[15]}}, imm16};
wire [31:0] imm26_ext = {{6{imm26[25]}}, imm26};
assign final_imm = immdt_sel ? imm26_ext : imm16_ext;

assign alu_inb = b_sel ? rt_data_reg : final_imm;
assign alu_ina = a_imm_sel ? alu_inb : (alu_src_a ? PC : rs_data_reg);

assign bOp_wire = (opcode == 6'b100000) ? 3'b100 : // BR
                  (opcode == 6'b100001) ? 3'b101 : // BMI
                  (opcode == 6'b100010) ? 3'b110 : // BPL
                  (opcode == 6'b100011) ? 3'b111 : // BZ
                  3'b000;

// Branch Comparator
branch_comparator branch_comp (
    .isBranch(branch_taken),
    .bOp(bOp_wire),
    .reg_data_in(rs_data_reg)
);


wire [31:0] cmov_result;
assign cmov_result = alu_out[0] ? rt_data_reg : rs_data_reg;

wire [31:0] final_alu_result;
assign final_alu_result = is_cmov ? cmov_result : alu_res_reg;

assign reg_write_data = mem_to_reg ? mem_data_reg : final_alu_result;

// Data Memory
wire mem_access_enable = (current_state == MEM_WAIT);
wire [0:0] mem_write_enable = {mem_wr && mem_access_enable};

mem_32bit dmem(
    .clka(clk),
    .ena(mem_access_enable),
    .wea(mem_write_enable),
    .addra(alu_res_reg[9:2]),
    .dina(rt_data_reg),
    .douta(mem_read_data)
);

// Simulation display
always @(posedge clk) begin
    if (!reset) begin 
        $display("T=%0t | St=%0d | PC=%08d | IR=%08h | R0=%0d | R1=%0d | R2=%0d | R3=%0d | R4=%0d | R5=%0d | R6=%0d | R7=%0d",
                 $time, current_state, PC/4 + 1, ins_reg,
                 REGFILE.registers[0], REGFILE.registers[1], REGFILE.registers[2], REGFILE.registers[3],
                 REGFILE.registers[4], REGFILE.registers[5], REGFILE.registers[6], REGFILE.registers[7]);
    end
end

endmodule