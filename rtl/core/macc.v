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

 module macc #(
    parameter A =1
 ) (
    input clk_sys,
    input rst_sys,

    //interface with exu
    input         i_rd_wen,
    input  [4:0]  i_rd_addr,
    input         i_mem_wreq,        
    input         i_mem_rreq,       
    input [31:0]  i_mem_addr,
    input [31:0]  i_alu_result,

    // interface with data mem
    output        o_mem_wen,        
    output        o_mem_ren,       
    output [31:0] o_mem_addr,     
    input  [31:0] i_mem_rdata,
    output [31:0] o_mem_wdata,    

    //interface with wb
    output        o_rd_wen,
    output [4:0]  o_rd_addr,
    output [31:0] o_mem_data,
    output [31:0] o_alu_result
 );

 assign o_mem_wen = i_mem_wreq;
 assign o_mem_ren = i_mem_rreq;
 assign o_mem_addr = i_mem_addr;
 assign o_mem_wdata = i_alu_result;

 assign o_mem_data = i_mem_rdata;

 DFF_RST #(.DATA_WIDTH (1)) rwen_dff(.clk(clk_sys),.rst(rst_sys),.d(i_rd_wen),.q(o_rd_wen));
 DFF_RST #(.DATA_WIDTH (5)) raddr_dff(.clk(clk_sys),.rst(rst_sys),.d(i_rd_addr),.q(o_rd_addr));
 DFF_RST #(.DATA_WIDTH (32)) res_dff(.clk(clk_sys),.rst(rst_sys),.d(i_alu_result),.q(o_alu_result));
 endmodule