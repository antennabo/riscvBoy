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

module exu_alu (
    input [31:0] i_rv32_rs1,
    input [31:0] i_rv32_rs2,
    input [31:0] i_rv32_imm,
    input [31:0] i_rv32_pc,
    input [13:0] alu_info_bus,  

    input         i_rd_wen,
    input  [4:0]  i_rd_addr,
    output        o_rd_wen,
    output [4:0]  o_rd_addr,

    output        o_mem_wen,  
    output [3:0]  o_data_be,      
    output        o_mem_ren,
    output [31:0] o_mem_wdata,     
    output [31:0] o_mem_addr,
    output [3:0]  o_mem_rdtype,

    output  o_ecall,
    output        o_jump_en,
    output [31:0] o_jump_addr,  
    output [31:0] o_result 
);

wire  [64:0] dec_alu_add_info;
wire  [63:0] dec_alu_or_info; 
wire  [63:0] dec_alu_xor_info;
wire  [63:0] dec_alu_and_info; 
wire  [36:0] dec_alu_sll_info;  
wire  [36:0] dec_alu_srl_info; 
wire  [36:0] dec_alu_sra_info;
wire  [64:0] dec_alu_slt_info;
wire  [64:0] dec_alu_sltu_info;
wire  [31:0] alu_res;
wire  [2:0] alu_bjp_cmp_res;
wire  [7:0] dec_bjp_jump_req;
wire  [2:0] dec_agu_wtype;
wire dec_agu_mem_wreq;
wire dec_agu_mem_rreq;

assign o_rd_wen = i_rd_wen;
assign o_rd_addr = i_rd_addr;

exu_alu_dec u_alu_dec(
    .i_rv32_rs1    (i_rv32_rs1),//input   [31:0] 
    .i_rv32_rs2    (i_rv32_rs2),//input   [31:0] 
    .i_rv32_imm    (i_rv32_imm),//input   [31:0] 
    .i_rv32_pc     (i_rv32_pc),//input   [31:0] 
    .alu_info_bus  (alu_info_bus),//input   [13:0]  
    .o_ecall       (o_ecall),
                                   
    .o_mem_wreq    (dec_agu_mem_wreq),//output         
    .o_mem_rreq    (dec_agu_mem_rreq),//output         
    //.o_mem_addr,  //output [31:0]
    .o_mem_wtype   (dec_agu_wtype ),
    .o_mem_rdtype  (o_mem_rdtype),
    .o_jump_req    (dec_bjp_jump_req),//output  [6:0]  
    //.o_jump_addr, //output [31:0] 
    .o_add_info    (dec_alu_add_info),//output  [64:0] 
    .o_or_info     (dec_alu_or_info),//output  [63:0] 
    .o_xor_info    (dec_alu_xor_info),//output  [63:0] 
    .o_and_info    (dec_alu_and_info),//output  [63:0] 
    .o_sll_info    (dec_alu_sll_info),//output  [36:0] 
    .o_srl_info    (dec_alu_srl_info),//output  [36:0] 
    .o_sra_info    (dec_alu_sra_info),//output  [36:0] 
    .o_slt_info    (dec_alu_slt_info),//output  [63:0] 
    .o_sltu_info   (dec_alu_sltu_info)//output  [63:0] 
);

exu_alu_calc u_alu_calc(
    .i_add_info    (dec_alu_add_info),//input [64:0] 
    .i_or_info     (dec_alu_or_info),//input [63:0] 
    .i_xor_info	   (dec_alu_xor_info),//input [63:0] 
    .i_and_info	   (dec_alu_and_info),//input [63:0]  
    .i_sll_info	   (dec_alu_sll_info),//input [36:0] 
    .i_srl_info	   (dec_alu_srl_info),//input [36:0] 
    .i_sra_info	   (dec_alu_sra_info),//input [36:0] 
    .i_slt_info	   (dec_alu_slt_info),//input [63:0] 
    .i_sltu_info   (dec_alu_sltu_info),//input [63:0] 
    .o_cmp_res     (alu_bjp_cmp_res),//output [2:0] 
    .o_result      (o_result)//output [31:0]
);

///
///TBD : move to idu
///
exu_alu_bjp u_alu_bjp(
     .i_rv32_rs1   (i_rv32_rs1),
     .i_imm        (i_rv32_imm),//input [31:0]        
     .i_pc         (i_rv32_pc),//input [31:0] 
     .i_jump_req   (dec_bjp_jump_req),//input [7:0]  
     .i_cmp_res    (alu_bjp_cmp_res),//input [2:0]  
     .o_jump_en    (o_jump_en),//output       
     .o_jump_addr  (o_jump_addr)//output [31:0]
);

exu_alu_agu u_alu_agu(
    .i_mem_wreq    (dec_agu_mem_wreq),//input 
    .i_mem_rreq    (dec_agu_mem_rreq),//input
    .i_alu_res     (o_result),//input [31:0] 
    .i_rs2_data    (i_rv32_rs2),
    .i_mem_wtype   (dec_agu_wtype),
    .o_mem_wdata   (o_mem_wdata),
    .o_mem_wen     (o_mem_wen),//output 
    .o_data_be     (o_data_be),
    .o_mem_addr    (o_mem_addr),//output [31:0] 
    .o_mem_ren     (o_mem_ren)//output 
 );
endmodule
