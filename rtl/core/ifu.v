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

module ifu #(
    parameter PC_W = 32,
    parameter INSTR_W = 32
) (
    input                           clk_sys,
    input                           rst_sys,
    //interface with imem
    output                          o_instr_ren,
    output      [PC_W-1:0]          o_instr_raddr,
    input       [INSTR_W-1 : 0]     i_instr_dina,

    input i_stall_f,
    input i_stall_d,
    input i_flush_d,
    input i_flush_f,
    //decode stage
    output      [INSTR_W-1 : 0]     o_instr,
    output      [PC_W-1:0]          o_pc,
    //execution stage
    input                           i_jump_en,
    input       [PC_W-1:0]          i_jump_addr
);

localparam PC_RST_ADDR = 0;//initial value of PC
localparam PC_ADD_VAL = 'h4;//for 32bit instructions
wire [PC_W-1  :   0]                  pc_cur      ;
wire [PC_W-1  :   0]                  pc_nxt_pre  ;
wire [PC_W-1  :   0]                  pc_nxt      ;
wire [PC_W-1  :   0]                  add_op1     ;
wire [PC_W-1  :   0]                  add_op2     ;

//output-stage 0
assign o_instr_ren = ~i_stall_d;
assign o_instr_raddr =pc_cur;
//output-stage 1
assign o_instr = i_instr_dina&{32{instr_ren}};

assign add_op1 = pc_cur;
assign add_op2 = PC_ADD_VAL;
assign pc_nxt_pre = add_op1 + add_op2;
assign pc_nxt = (i_jump_en)?i_jump_addr: pc_nxt_pre;

DFF_RST_EN_CLR #(.DATA_WIDTH (PC_W)) u_pc_dff(.clk(clk_sys),.rst(rst_sys),.en(~i_stall_f),.clr(1'b0),.d(pc_nxt),.q(pc_cur));
DFF_RST_EN_CLR #(.DATA_WIDTH (PC_W)) u_opc_dff(.clk(clk_sys),.rst(rst_sys),.en(~i_stall_d),.clr(i_flush_d),.d(pc_cur),.q(o_pc));
DFF_RST_EN_CLR #(.DATA_WIDTH (1)) u_ren(.clk(clk_sys),.rst(rst_sys),.en(~i_stall_d),.clr(i_flush_d),.d(1'b1),.q(instr_ren));
    
endmodule
