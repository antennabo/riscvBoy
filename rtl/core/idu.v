 /*                                                                      
 Copyright 2025 Haoyu Tang, haoyu.tang@hotmail.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

module idu#(
    parameter DECODE_INFO_BUS_WIDTH = 14,
    parameter INSTR_WIDTH = 32
) (
    input clk_sys,
    input rst_sys,
    //interface with decode
    input      [31:0]             i_pc,
    input      [INSTR_WIDTH-1:0]  i_instr,
    //interface with regfile
    output     [4:0]              o_rs1_idx,
    output     [4:0]              o_rs2_idx,
    input      [31:0]             i_rs1_data,
    input      [31:0]             i_rs2_data,
    output                        o_rd_en,
    output                        o_rs1_en,
    output                        o_rs2_en,
    //interface hzd ctrl
    input                         i_id2ex_stall,
    input                         i_id2ex_flush,
    output     [4:0]              o_rs1idx_e,
    output     [4:0]              o_rs2idx_e,
    output                        o_mem2reg,
    //interface with exu
    output     [31:0]             o_pc_e,
    output     [4:0]              o_rdidx_e,
    output     [31:0]             o_rs1data_e,
    output     [31:0]             o_rs2data_e,
    output     [31:0]             o_imm_e,
    output     [DECODE_INFO_BUS_WIDTH-1:0] o_decode_info_bus
);
    
    localparam DECODE_INFO_TYPE_WIDTH = 3;
    localparam DECODE_INFO_TYPE = 11;
    localparam ALU_INFO_WIDTH= DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH;
    localparam ALU_INFO_ADD  = 0;
    localparam ALU_INFO_SUB  = 1;
    localparam ALU_INFO_SLL  = 2;
    localparam ALU_INFO_SLT  = 3;
    localparam ALU_INFO_SLTU = 4;
    localparam ALU_INFO_XOR  = 5;
    localparam ALU_INFO_SRL  = 6;
    localparam ALU_INFO_SRA  = 7;
    localparam ALU_INFO_OR   = 8;
    localparam ALU_INFO_AND  = 9;
    localparam ALU_INFO_IMM_VAL  = 10;
    localparam ALU_INFO_TYPE = DECODE_INFO_TYPE;
    localparam BJP_INFO_WIDTH= DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH;
    localparam BJP_INFO_JUMP  = 0;
    localparam BJP_INFO_BEQ  = 1;
    localparam BJP_INFO_BNE  = 2;
    localparam BJP_INFO_BLT  = 3;
    localparam BJP_INFO_BGE  = 4;
    localparam BJP_INFO_BLTU = 5;
    localparam BJP_INFO_BGEU = 6;
    localparam BJP_INFO_SRA  = 7;
    localparam BJP_INFO_OR   = 8;
    localparam BJP_INFO_AND  = 9;
    localparam BJP_INFO_IMM_VAL  = 10;
    localparam BJP_INFO_TYPE = DECODE_INFO_TYPE;
    localparam MEM_INFO_WIDTH= DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH;
    /*
    localparam BJP_INFO_JUMP  = 0;
    localparam BJP_INFO_BEQ  = 1;
    localparam BJP_INFO_BNE  = 2;
    localparam BJP_INFO_BLT  = 3;
    localparam BJP_INFO_BGE  = 4;
    localparam BJP_INFO_BLTU = 5;
    localparam BJP_INFO_BGEU = 6;
    localparam BJP_INFO_SRA  = 7;
    localparam BJP_INFO_OR   = 8;
    localparam BJP_INFO_AND  = 9;
    localparam BJP_INFO_IMM_VAL  = 10;
    localparam BJP_INFO_TYPE = DECODE_INFO_TYPE;
    */

    wire [6:0] opcode;
    wire [6:0] func7;
    wire [2:0] func3;
    assign opcode = i_instr[6:0];
    assign func7 = i_instr[31:25];
    assign func3 = i_instr[14:12];

    wire func3_000 = (func3==3'b000);
    wire func3_001 = (func3==3'b001);
    wire func3_010 = (func3==3'b010);
    wire func3_011 = (func3==3'b011);
    wire func3_100 = (func3==3'b100);
    wire func3_101 = (func3==3'b101);
    wire func3_110 = (func3==3'b110);
    wire func3_111 = (func3==3'b111);

    wire func7_0000000 = (func7==7'b0000000); 
    wire func7_0100000 = (func7==7'b0100000); 

    wire opcode_1_0_00  = (opcode[1:0] == 2'b00);
    wire opcode_1_0_01  = (opcode[1:0] == 2'b01);
    wire opcode_1_0_10  = (opcode[1:0] == 2'b10);
    wire opcode_1_0_11  = (opcode[1:0] == 2'b11);

    wire opcode_4_2_100  = (opcode[4:2]==3'b100);
    wire opcode_4_2_101  = (opcode[4:2]==3'b101);
    wire opcode_4_2_011  = (opcode[4:2]==3'b011);
    wire opcode_4_2_001  = (opcode[4:2]==3'b001);
    wire opcode_4_2_000  = (opcode[4:2]==3'b000);

    wire opcode_6_5_00   = (opcode[6:5]==2'b00);
    wire opcode_6_5_01   = (opcode[6:5]==2'b01);
    wire opcode_6_5_10   = (opcode[6:5]==2'b10);
    wire opcode_6_5_11   = (opcode[6:5]==2'b11);


    wire rv32_type_r   = opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;
    wire rv32_type_i_i = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;
    wire rv32_type_i_l = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11;
    wire rv32_type_i_j = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;
    wire rv32_type_i_f = opcode_6_5_00 & opcode_4_2_011 & opcode_1_0_11;  
    wire rv32_type_b   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;
    wire rv32_type_s   = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11;
    wire rv32_type_i_c = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11; 

    // R-type instruction
    wire rv32_add  = rv32_type_r & func3_000 & func7_0000000;
    wire rv32_sub  = rv32_type_r & func3_000 & func7_0100000;
    wire rv32_sll  = rv32_type_r & func3_001 & func7_0000000;
    wire rv32_slt  = rv32_type_r & func3_010 & func7_0000000;
    wire rv32_sltu = rv32_type_r & func3_011 & func7_0000000;
    wire rv32_xor  = rv32_type_r & func3_100 & func7_0000000;
    wire rv32_srl  = rv32_type_r & func3_101 & func7_0000000;
    wire rv32_sra  = rv32_type_r & func3_101 & func7_0100000;
    wire rv32_or   = rv32_type_r & func3_110 & func7_0000000;
    wire rv32_and  = rv32_type_r & func3_111 & func7_0000000;

    // I-type instruction
    wire rv32_addi  = rv32_type_i_i & func3_000;
    wire rv32_slti  = rv32_type_i_i & func3_010;
    wire rv32_sltiu = rv32_type_i_i & func3_011;
    wire rv32_xori  = rv32_type_i_i & func3_100;
    wire rv32_ori   = rv32_type_i_i & func3_110;
    wire rv32_andi  = rv32_type_i_i & func3_111;
    wire rv32_slli  = rv32_type_i_i & func3_001 & (i_instr[31:25] == 7'b0000000);
    wire rv32_srli  = rv32_type_i_i & func3_101 & (i_instr[31:25] == 7'b0000000);
    wire rv32_srai  = rv32_type_i_i & func3_101 & (i_instr[31:25] == 7'b0100000);

    // U-type instruction
    wire rv32_lui   = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;
    wire rv32_auipc = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11;

    // J-type instruction
    wire rv32_jal   = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;

    // I-type (JALR)
    wire rv32_jalr  = rv32_type_i_j & func3_000;

    // B-type branch instruction
    wire rv32_beq   = rv32_type_b & func3_000;
    wire rv32_bne   = rv32_type_b & func3_001;
    wire rv32_blt   = rv32_type_b & func3_100;
    wire rv32_bge   = rv32_type_b & func3_101;
    wire rv32_bltu  = rv32_type_b & func3_110;
    wire rv32_bgeu  = rv32_type_b & func3_111;

    // I-type (Load instruction)
    wire rv32_lb    = rv32_type_i_l & func3_000;
    wire rv32_lh    = rv32_type_i_l & func3_001;
    wire rv32_lw    = rv32_type_i_l & func3_010;
    wire rv32_lbu   = rv32_type_i_l & func3_100;
    wire rv32_lhu   = rv32_type_i_l & func3_101;

    assign o_mem2reg = rv32_type_i_l;

    // S-type (Store instruction)
    wire rv32_sb    = rv32_type_s & func3_000;
    wire rv32_sh    = rv32_type_s & func3_001;
    wire rv32_sw    = rv32_type_s & func3_010;

    // system instruction
    wire rv32_fence    = rv32_type_i_f & func3_000 & (i_instr[31:28] == 4'b0000);
    wire rv32_fence_i  = rv32_type_i_f & func3_001 & (i_instr[31:28] == 4'b0000);

    wire rv32_ecall    = rv32_type_i_c & func3_000 & (i_instr[31:20] == 12'b000000000000);
    wire rv32_ebreak   = rv32_type_i_c & func3_000 & (i_instr[31:20] == 12'b000000000001);
    wire rv32_csrrw    = rv32_type_i_c&func3_001;
    wire rv32_csrrs    = rv32_type_i_c&func3_010;
    wire rv32_csrrc    = rv32_type_i_c&func3_011;
    wire rv32_csrrwi   = rv32_type_i_c&func3_101;
    wire rv32_csrrsi   = rv32_type_i_c&func3_110;
    wire rv32_csrrci   = rv32_type_i_c&func3_111;
    wire rv32_csr = rv32_type_i_c & (~func3_000);

    wire [DECODE_INFO_BUS_WIDTH-1:0] decode_info_bus = ({DECODE_INFO_BUS_WIDTH{alu_bus_op}}&alu_info_bus)|
                               ({DECODE_INFO_BUS_WIDTH{bjp_bus_op}}&bjp_info_bus)|
                               ({DECODE_INFO_BUS_WIDTH{agu_bus_op}}&agu_info_bus)|
                               ({DECODE_INFO_BUS_WIDTH{csr_bus_op}}&csr_info_bus);
    

    wire [ALU_INFO_WIDTH-1:0] alu_info_bus;
    wire alu_bus_op = rv32_type_i_i|rv32_type_r;
    assign alu_info_bus[ALU_INFO_ADD]  = rv32_add | rv32_addi;
    assign alu_info_bus[ALU_INFO_SUB]  = rv32_sub;
    assign alu_info_bus[ALU_INFO_SLL]  = rv32_sll | rv32_slli;
    assign alu_info_bus[ALU_INFO_SLT]  = rv32_slt | rv32_slti;
    assign alu_info_bus[ALU_INFO_SLTU] = rv32_sltu | rv32_sltiu;
    assign alu_info_bus[ALU_INFO_XOR]  = rv32_xor | rv32_xori;
    assign alu_info_bus[ALU_INFO_SRL]  = rv32_srl | rv32_srli;
    assign alu_info_bus[ALU_INFO_SRA]  = rv32_sra | rv32_srai;
    assign alu_info_bus[ALU_INFO_OR]   = rv32_or | rv32_ori;
    assign alu_info_bus[ALU_INFO_AND]  = rv32_and | rv32_andi;
    assign alu_info_bus[ALU_INFO_IMM_VAL]  = imm_val;
    assign alu_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]=3'b001;
    
    wire imm_val = 
        rv32_type_i_i |
        rv32_type_i_l |
        rv32_type_i_j |
        rv32_jal|
        rv32_type_b;

    wire [31:0] rv32_imm = 
        ({32{rv32_type_i_i|rv32_type_i_j}}&rv32_i_imm) |
        ({32{rv32_type_b  }}&rv32_b_imm) |
        ({32{rv32_type_i_l}}&rv32_i_imm) |
        ({32{rv32_jal}}&rv32_j_imm) |
        ({32{rv32_lui|rv32_auipc}}&rv32_u_imm)|
        ({32{rv32_type_s}}&rv32_s_imm)
        ;

    wire [31:0] rv32_s_imm = {
        {20{i_instr[31]}} ,
        i_instr[31:25],
        i_instr[11:7]
    };
    
    wire [31:0]  rv32_i_imm = { 
        {20{i_instr[31]}} ,
        i_instr[31:20]
        };

    wire [31:0]  rv32_b_imm = {
        {19{i_instr[31]}}, 
        i_instr[31],
        i_instr[7], 
        i_instr[30:25], 
        i_instr[11:8], 
        1'b0
        };

    wire [31:0]  rv32_u_imm = {i_instr[31:12],12'b0};

    wire [31:0]  rv32_j_imm = {
            {11{i_instr[31]}}, 
            i_instr[31], 
            i_instr[19:12],
            i_instr[20], 
            i_instr[30:21], 
            1'b0
           };
    
    assign o_rs1_idx = {5{rv32_need_rs1}}&i_instr[19:15];
    assign o_rs2_idx = {5{rv32_need_rs1}}&i_instr[24:20];


    wire rv32_need_rd = 
        rv32_lui     |
        rv32_auipc   |
        rv32_jal     |
        rv32_type_i_j|
        rv32_type_i_l|
        rv32_type_i_i|
        rv32_type_r  |
        rv32_csr
        ;
    wire rv32_need_rs1 = 
        rv32_type_i_j |
        rv32_type_b   |
        rv32_type_i_l |
        rv32_type_s   |
        rv32_type_i_i |
        rv32_type_r   |
        rv32_csrrw    |
        rv32_csrrs    |
        rv32_csrrc
        ;
    wire rv32_need_rs2 = 
        rv32_type_b   |
        rv32_type_s   |
        rv32_type_r
        ;

    assign o_rs1_en = rv32_need_rs1; 
    assign o_rs2_en = rv32_need_rs2;


    wire [BJP_INFO_WIDTH-1:0] bjp_info_bus;
    wire bjp_bus_op = rv32_jal | rv32_jalr|rv32_type_b|rv32_lui|rv32_auipc;
    //assign o_branch = bjp_bus_op;
    assign bjp_info_bus[BJP_INFO_JUMP] = rv32_jal;
    assign bjp_info_bus[BJP_INFO_BEQ]  = rv32_beq;
    assign bjp_info_bus[BJP_INFO_BNE]  = rv32_bne;
    assign bjp_info_bus[BJP_INFO_BLT]  = rv32_blt;
    assign bjp_info_bus[BJP_INFO_BGE]  = rv32_bge;
    assign bjp_info_bus[BJP_INFO_BLTU] = rv32_bltu;
    assign bjp_info_bus[BJP_INFO_BGEU] = rv32_bgeu;
    assign bjp_info_bus[BJP_INFO_SRA]  = rv32_lui;
    assign bjp_info_bus[BJP_INFO_OR]   = rv32_auipc;
    assign bjp_info_bus[BJP_INFO_AND]  = rv32_jalr;
    assign bjp_info_bus[BJP_INFO_IMM_VAL]  = 1'b0;
    assign bjp_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]=3'b010;

    ////
    //load store instruction}
    ////
    wire [MEM_INFO_WIDTH-1:0] agu_info_bus;
    wire agu_bus_op = rv32_type_i_l | rv32_type_s;
    assign agu_info_bus[BJP_INFO_JUMP] = rv32_lb;
    assign agu_info_bus[BJP_INFO_BEQ]  = rv32_lh;
    assign agu_info_bus[BJP_INFO_BNE]  = rv32_lw;
    assign agu_info_bus[BJP_INFO_BLT]  = rv32_lbu;
    assign agu_info_bus[BJP_INFO_BGE]  = rv32_lhu;
    assign agu_info_bus[BJP_INFO_BLTU] = rv32_sb;
    assign agu_info_bus[BJP_INFO_BGEU] = rv32_sh;
    assign agu_info_bus[BJP_INFO_SRA]  = rv32_sw;
    assign agu_info_bus[BJP_INFO_OR]   = 1'b0;
    assign agu_info_bus[BJP_INFO_AND]  = 1'b0;
    assign agu_info_bus[BJP_INFO_IMM_VAL]  = 1'b0;
    assign agu_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]=3'b011;


    wire [MEM_INFO_WIDTH-1:0] csr_info_bus;
    wire csr_bus_op = rv32_type_i_c|rv32_type_i_f;
    assign csr_info_bus[BJP_INFO_JUMP] = rv32_fence;
    assign csr_info_bus[BJP_INFO_BEQ]  = rv32_fence_i;
    assign csr_info_bus[BJP_INFO_BNE]  = rv32_ecall;
    assign csr_info_bus[BJP_INFO_BLT]  = rv32_ebreak;
    assign csr_info_bus[BJP_INFO_BGE]  = rv32_csrrw;
    assign csr_info_bus[BJP_INFO_BLTU] = rv32_csrrs;
    assign csr_info_bus[BJP_INFO_BGEU] = rv32_csrrc;
    assign csr_info_bus[BJP_INFO_SRA]  = rv32_csrrwi;
    assign csr_info_bus[BJP_INFO_OR]   = rv32_csrrsi;
    assign csr_info_bus[BJP_INFO_AND]  = rv32_csrrci;
    assign csr_info_bus[BJP_INFO_IMM_VAL]  = 1'b0;
    assign csr_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]=3'b100;

    DFF_RST_EN_CLR #(.DATA_WIDTH (DECODE_INFO_BUS_WIDTH)) u_infobus_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(decode_info_bus),.q(o_decode_info_bus));
    DFF_RST_EN_CLR #(.DATA_WIDTH (32)) u_imm_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(rv32_imm),.q(o_imm_e));
    DFF_RST_EN_CLR #(.DATA_WIDTH (32)) u_pc_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(i_pc),.q(o_pc_e));
    DFF_RST_EN_CLR #(.DATA_WIDTH (1)) u_rdwen_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(rv32_need_rd),.q(o_rd_en));
    DFF_RST_EN_CLR #(.DATA_WIDTH (5)) u_rdidx_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(i_instr[11:7]),.q(o_rdidx_e));
    DFF_RST_EN_CLR #(.DATA_WIDTH (5)) u_rs1idx_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(o_rs1_idx),.q(o_rs1idx_e));
    DFF_RST_EN_CLR #(.DATA_WIDTH (5)) u_rs2idx_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(o_rs2_idx),.q(o_rs2idx_e));
    DFF_RST_EN_CLR #(.DATA_WIDTH (32)) u_rs1d_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(i_rs1_data),.q(o_rs1data_e));
    DFF_RST_EN_CLR #(.DATA_WIDTH (32)) u_rs2d_dff(.clk(clk_sys),.rst(rst_sys),.en(i_id2ex_stall),.clr(i_id2ex_flush),.d(i_rs2_data),.q(o_rs2data_e));

endmodule
