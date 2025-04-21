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

module exu_alu_dec (
    input   [31:0] i_rv32_rs1,
    input   [31:0] i_rv32_rs2,
    input   [31:0] i_rv32_imm,
    input   [31:0] i_rv32_pc,
    input   [13:0] alu_info_bus,  

    output  o_ecall,

    output          o_mem_wreq,
    output          o_mem_rreq,
    //output [31:0]   o_mem_addr,
    output  [7:0]   o_jump_req,
    //output [31:0] o_jump_addr,  
    output  [64:0] o_add_info,
    output  [63:0] o_or_info,  
    output  [63:0] o_xor_info,
    output  [63:0] o_and_info,   
    output  [36:0] o_sll_info,  
    output  [36:0] o_srl_info, 
    output  [36:0] o_sra_info,
    output  [64:0] o_slt_info,
    output  [64:0] o_sltu_info
);

localparam DECODE_INFO_BIT_0  = 0;
localparam DECODE_INFO_BIT_1  = 1;
localparam DECODE_INFO_BIT_2  = 2;
localparam DECODE_INFO_BIT_3  = 3;
localparam DECODE_INFO_BIT_4  = 4;
localparam DECODE_INFO_BIT_5  = 5;
localparam DECODE_INFO_BIT_6  = 6;
localparam DECODE_INFO_BIT_7  = 7;
localparam DECODE_INFO_BIT_8  = 8;
localparam DECODE_INFO_BIT_9  = 9;
localparam DECODE_INFO_BIT_10 = 10;
localparam DECODE_INFO_TYPE_WIDTH = 3;
localparam DECODE_INFO_TYPE = 11;
wire alu_sel   = alu_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]==3'b001;
wire bjp_sel   = alu_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]==3'b010;
wire agu_sel   = alu_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]==3'b011;
wire csr_sel   = alu_info_bus[DECODE_INFO_TYPE+DECODE_INFO_TYPE_WIDTH-1:DECODE_INFO_TYPE]==3'b100;

wire rv32_add     = alu_sel&alu_info_bus[DECODE_INFO_BIT_0];
wire rv32_sub     = alu_sel&alu_info_bus[DECODE_INFO_BIT_1];
wire rv32_sll     = alu_sel&alu_info_bus[DECODE_INFO_BIT_2];
wire rv32_slt     = alu_sel&alu_info_bus[DECODE_INFO_BIT_3];
wire rv32_sltu    = alu_sel&alu_info_bus[DECODE_INFO_BIT_4];
wire rv32_xor     = alu_sel&alu_info_bus[DECODE_INFO_BIT_5];
wire rv32_srl     = alu_sel&alu_info_bus[DECODE_INFO_BIT_6];
wire rv32_sra     = alu_sel&alu_info_bus[DECODE_INFO_BIT_7];
wire rv32_or      = alu_sel&alu_info_bus[DECODE_INFO_BIT_8];
wire rv32_and     = alu_sel&alu_info_bus[DECODE_INFO_BIT_9];
wire imm_val      = alu_sel&alu_info_bus[DECODE_INFO_BIT_10];

wire rv32_jal     = bjp_sel&alu_info_bus[DECODE_INFO_BIT_0];
wire rv32_beq     = bjp_sel&alu_info_bus[DECODE_INFO_BIT_1];
wire rv32_bne     = bjp_sel&alu_info_bus[DECODE_INFO_BIT_2];
wire rv32_blt     = bjp_sel&alu_info_bus[DECODE_INFO_BIT_3];
wire rv32_bge     = bjp_sel&alu_info_bus[DECODE_INFO_BIT_4];
wire rv32_bltu    = bjp_sel&alu_info_bus[DECODE_INFO_BIT_5];
wire rv32_bgeu    = bjp_sel&alu_info_bus[DECODE_INFO_BIT_6];
wire rv32_lui     = bjp_sel&alu_info_bus[DECODE_INFO_BIT_7];//handled in decode
wire rv32_auipc   = bjp_sel&alu_info_bus[DECODE_INFO_BIT_8];
wire rv32_jalr   = bjp_sel&alu_info_bus[DECODE_INFO_BIT_9];

wire rv32_lb      = agu_sel&alu_info_bus[DECODE_INFO_BIT_0];
wire rv32_lh      = agu_sel&alu_info_bus[DECODE_INFO_BIT_1];
wire rv32_lw      = agu_sel&alu_info_bus[DECODE_INFO_BIT_2];
wire rv32_lbu     = agu_sel&alu_info_bus[DECODE_INFO_BIT_3];
wire rv32_lhu     = agu_sel&alu_info_bus[DECODE_INFO_BIT_4];
wire rv32_sb      = agu_sel&alu_info_bus[DECODE_INFO_BIT_5];
wire rv32_sh      = agu_sel&alu_info_bus[DECODE_INFO_BIT_6];
wire rv32_sw      = agu_sel&alu_info_bus[DECODE_INFO_BIT_7];

wire rv32_fence   = csr_sel&alu_info_bus[DECODE_INFO_BIT_0];
wire rv32_fence_i = csr_sel&alu_info_bus[DECODE_INFO_BIT_1];
wire rv32_ecall   = csr_sel&alu_info_bus[DECODE_INFO_BIT_2];
wire rv32_ebreak  = csr_sel&alu_info_bus[DECODE_INFO_BIT_3];
wire rv32_csrrw   = csr_sel&alu_info_bus[DECODE_INFO_BIT_4];
wire rv32_csrrs   = csr_sel&alu_info_bus[DECODE_INFO_BIT_5];
wire rv32_csrrc   = csr_sel&alu_info_bus[DECODE_INFO_BIT_6];
wire rv32_csrrwi  = csr_sel&alu_info_bus[DECODE_INFO_BIT_7];
wire rv32_csrrsi  = csr_sel&alu_info_bus[DECODE_INFO_BIT_8];
wire rv32_csrrci  = csr_sel&alu_info_bus[DECODE_INFO_BIT_9];
//
assign o_ecall = rv32_ecall;

wire alu_add_sel = rv32_add | //add,addi
                   rv32_sub   //sub
                   ;
wire [31:0] op_src2 = (imm_val)? i_rv32_imm: i_rv32_rs2;
wire [31:0] alu_add_op1 = i_rv32_rs1;
wire [31:0] alu_add_op2 = (rv32_sub)? (~op_src2) : op_src2;
wire cin = rv32_sub;


wire bjp_add_sel =  rv32_jal | rv32_jalr |
                    rv32_auipc;
wire [31:0] bjp_add_op1 = i_rv32_pc;
wire [31:0] bjp_add_op2 = (rv32_auipc)? i_rv32_imm : 'h4;

wire mem_add_sel =  rv32_lb | 
                    rv32_lh |
                    rv32_lw |
                    rv32_lbu|
                    rv32_lhu|
                    rv32_sb|
                    rv32_sh|
                    rv32_sw;
//rv32_lb,rv32_lh,rv32_lw,rv32_lbu,rv32_lhu,rv32_sb,rv32_sh,rv32_sw rd = rs1 + offset;
wire mem_write = rv32_sb|rv32_sh|rv32_sw;
wire mem_read  = rv32_lb|rv32_lh|rv32_lw|rv32_lbu|rv32_lhu;
wire [31:0] mem_add_op1 = i_rv32_rs1;
wire [31:0] mem_add_op2 = i_rv32_imm;

assign o_mem_wreq = mem_write;
assign o_mem_rreq = mem_read;

wire [31:0] lui_add_op1;
wire [31:0] lui_add_op2;
assign lui_add_op1 = 'h0;
assign lui_add_op2 = i_rv32_imm;
wire lui_add_sel =  rv32_lui;

assign o_add_info ={rv32_sub,{32{alu_add_sel}}&alu_add_op2,{32{alu_add_sel}}&alu_add_op1}|
                   {1'b0    ,{32{bjp_add_sel}}&bjp_add_op2,{32{bjp_add_sel}}&bjp_add_op1}|
                   {1'b0    ,{32{mem_add_sel}}&mem_add_op2,{32{mem_add_sel}}&mem_add_op1}|
                   {1'b0    ,{32{lui_add_sel}}&lui_add_op2,{32{lui_add_sel}}&lui_add_op1};
                   
assign o_jump_req = {rv32_jal,
                    rv32_jalr,
                   rv32_beq,
                   rv32_bne,
                   rv32_blt,
                   rv32_bge,
                   rv32_bltu,
                   rv32_bgeu};

wire [31:0] sll_op1 = i_rv32_rs1;
wire [4:0]  sll_op2 = (imm_val)? i_rv32_imm[4:0]: i_rv32_rs2[4:0];
assign o_sll_info = {{32{rv32_sll}}&sll_op2,{32{rv32_sll}}&sll_op1};
 
//unsigned and sign
wire srl_sel = rv32_srl; //srl,srli
wire [31:0] srl_op1 = i_rv32_rs1;
wire [4:0]  srl_op2 = (imm_val)? i_rv32_imm[4:0]: i_rv32_rs2[4:0];
assign o_srl_info = {{32{rv32_srl}}&srl_op2,{32{rv32_srl}}&srl_op1};

wire [31:0] sra_op1 = i_rv32_rs1;
wire [4:0]  sra_op2 = (imm_val)? i_rv32_imm[4:0]: i_rv32_rs2[4:0];
assign o_sra_info = {{32{rv32_sra}}&sra_op2,{32{rv32_sra}}&sra_op1};

wire [31:0] slt_op1 = i_rv32_rs1;
wire [31:0] slt_op2 = op_src2;
wire slt_sel = rv32_slt|rv32_bge|rv32_blt;
assign o_slt_info = {rv32_slt,{32{slt_sel}}&slt_op2,{32{slt_sel}}&slt_op1};

//need to add type b
wire [31:0] sltu_op1 = i_rv32_rs1;
wire [31:0] sltu_op2 = op_src2;
wire sltu_sel = rv32_sltu|rv32_bne|rv32_bgeu|rv32_bltu|rv32_beq;
assign o_sltu_info = {rv32_sltu,{32{sltu_sel}}&sltu_op2,{32{sltu_sel}}&sltu_op1};

wire [31:0] xor_op1 = i_rv32_rs1;
wire [31:0] xor_op2 = op_src2;
assign o_xor_info = {{32{rv32_xor}}&xor_op2,{32{rv32_xor}}&xor_op1};

wire [31:0] or_op1  = i_rv32_rs1;
wire [31:0] or_op2  = op_src2;
assign o_or_info = {{32{rv32_or}}&or_op2,{32{rv32_or}}&or_op1};

wire [31:0] and_op1 = i_rv32_rs1;
wire [31:0] and_op2 = op_src2;
assign o_and_info = {{32{rv32_and}}&and_op2,{32{rv32_and}}&and_op1};

endmodule
