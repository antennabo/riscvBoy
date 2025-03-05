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

module exu_alu_bjp(
    input [31:0]  i_imm,
    input [31:0]  i_pc,
    input [6:0]   i_jump_req,
    input [2:0]   i_cmp_res,
    output        o_jump_en,
    output [31:0] o_jump_addr
);
    

wire [31:0] jump_add_op1 = i_pc;
wire [31:0] jump_add_op2 = i_imm;

assign o_jump_addr = jump_add_op1 + jump_add_op2;

assign {rv32_jal,
        rv32_beq,
        rv32_bne,
        rv32_blt,
        rv32_bge,
        rv32_bltu,
        rv32_bgeu} = i_jump_req;

assign {slt_result,sltu_result,op1_eq_op2} = i_cmp_res;

assign o_jump_en=  rv32_jal|
                  (rv32_beq&op1_eq_op2)|
                  (rv32_bne&(~op1_eq_op2))|
                  (rv32_blt&(~slt_result))|
                  (rv32_bge&slt_result)|
                  (rv32_bltu&(~sltu_result))|
                  (rv32_bgeu&(sltu_result));
endmodule