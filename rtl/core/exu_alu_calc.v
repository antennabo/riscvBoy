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

module exu_alu_calc (
    input [64:0] i_add_info,
    input [63:0] i_or_info,  
    input [63:0] i_xor_info,
    input [63:0] i_and_info,   
    input [36:0] i_sll_info,  
    input [36:0] i_srl_info, 
    input [36:0] i_sra_info, 
    input [63:0] i_slt_info,
    input [63:0] i_sltu_info,
    output [2:0] o_cmp_res,
    output [31:0]o_result 
);

/*
ADDER
*/
wire cin;
wire [31:0] add_in2;
wire [31:0] add_in1;
assign {cin, add_in2, add_in1} = i_add_info;
wire [31:0] addsub_result = add_in1 + add_in2 + cin;

/*
OR
*/
wire [31:0] or_in1;
wire [31:0] or_in2;
assign {or_in2,or_in1} = i_or_info;
wire [31:0] or_result = or_in1 | or_in2;
/*
XOR
*/
wire [31:0] xor_in1;
wire [31:0] xor_in2;
assign {xor_in2,xor_in1} = i_xor_info;
wire [31:0] xor_result = xor_in1 ^ xor_in2;
/*
AND
*/
wire [31:0] and_in1;
wire [31:0] and_in2;  
assign {and_in2,and_in1} = i_and_info;
wire [31:0] and_result = and_in1 & and_in2;

/*
sll
*/
wire [31:0] sll_in1;
wire [4:0] sll_in2;  
assign {sll_in2,sll_in1} = i_sll_info;
wire [31:0] sll_result = sll_in1 << sll_in2;

/*
srl
*/
wire [31:0] srl_in1;
wire [4:0] srl_in2;  
assign {srl_in2,srl_in1} = i_srl_info;
wire [31:0] srl_result = srl_in1 >> srl_in2;

/*
sra
Consider merging with SRA in the future.
*/
wire [31:0] sra_in1;
wire [4:0] sra_in2;  
assign {sra_in2,sra_in1} = i_sra_info;
wire [31:0] sr_shift = sra_in1 >> sra_in2;
wire [31:0] sr_shift_mask = 32'hffffffff >> sra_in2;
wire [31:0] sra_result = (sr_shift & sr_shift_mask) | ({32{sra_in1[31]}} & (~sr_shift_mask));

/*
slt
*/
wire [31:0] slt_in1;
wire [31:0] slt_in2;  
assign {slt_in2,slt_in1} = i_slt_info;
wire slt_result = $signed(slt_in1) >= $signed(slt_in2);

/*
sltu
Consider merging with SLT in the future.
*/
wire [31:0] sltu_in1;
wire [31:0] sltu_in2;  
assign {sltu_in2,sltu_in1} = i_sltu_info;
wire sltu_result = sltu_in1 >= sltu_in2;
wire op1_eq_op2 = (sltu_in1 == sltu_in2);

assign o_result = 
    addsub_result |
    or_result |
    xor_result|
    and_result|
    sll_result|
    srl_result|
    sra_result;

assign o_cmp_res = {slt_result,sltu_result,op1_eq_op2};

endmodule
