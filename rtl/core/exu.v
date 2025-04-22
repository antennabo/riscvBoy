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

 module exu #(
    parameter A =1
 ) (
    input clk_sys,
    input rst_sys,
    input [31:0] i_rv32_rs1,
    input [31:0] i_rv32_rs2,
    input [31:0] i_rv32_imm,
    input [31:0] i_rv32_pc,
    input [13:0] alu_info_bus,  

    input i_pip_flush,

    //from write back: forwarding
    input [31:0] i_wb_frw_data,//wb_regf_wdata
    //output [4:0] o_fwd_rs1idx,
    //output [4:0] o_fwd_rs2idx,
    input [1:0] i_fwd_rs1_e,
    input [1:0] i_fwd_rs2_e,

    input         i_rd_wen,
    input  [4:0]  i_rd_addr,
    output        o_rd_wen,
    output [4:0]  o_rd_addr,

    output        o_mem_wen,   
    output [3:0]  o_mem_wbe,           
    output        o_mem_ren,       
    output [31:0] o_mem_addr,
    output [31:0] o_mem_wdata,
    output [3:0]  o_mem_rdtype,
    output        o_ecall,

    output        o_jump_en,
    output [31:0] o_jump_addr,  
    output [31:0] o_result 
 );

wire        rd_wen_w;
wire [4:0]  rd_addr_w; 
wire        mem_wen_w;   
wire        mem_ren_w;   
wire [31:0] mem_addr_w; 
wire [31:0] mem_wdata_w;
wire        jump_en_w;  
wire [31:0] jump_addr_w; 
wire [31:0] result_w;
wire [31:0] macc_frw_data;
wire [31:0] wb_frw_data;
assign macc_frw_data = o_result;
assign wb_frw_data = i_wb_frw_data;
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [3:0]  mem_rdtype_w;
wire [3:0]  mem_wbe_w;
assign rs1_data = ({32{i_fwd_rs1_e[1]}}&macc_frw_data)|
                  ({32{i_fwd_rs1_e[0]}}&wb_frw_data)|
                  ({32{&(~i_fwd_rs1_e)}}&i_rv32_rs1);

assign rs2_data = ({32{i_fwd_rs2_e[1]}}&macc_frw_data)|
                  ({32{i_fwd_rs2_e[0]}}&wb_frw_data)|
                  ({32{&(~i_fwd_rs2_e)}}&i_rv32_rs2);

exu_alu u_alu(
    .i_rv32_rs1  (rs1_data    ),//input [31:0] 
    .i_rv32_rs2  (rs2_data    ),//input [31:0] 
    .i_rv32_imm  (i_rv32_imm  ),//input [31:0] 
    .i_rv32_pc   (i_rv32_pc   ),//input [31:0] 
    .alu_info_bus(alu_info_bus),//input [13:0]  
    .o_ecall(o_ecall), 
                   //             
    .i_rd_wen    (i_rd_wen   ),//input        
    .i_rd_addr   (i_rd_addr  ),//input  [4:0] 
    .o_rd_wen    (rd_wen_w   ),//output       
    .o_rd_addr   (rd_addr_w  ),//output [4:0] 
                              //             
    .o_mem_wen   (mem_wen_w  ),//output  
    .o_data_be   (mem_wbe_w),             
    .o_mem_ren   (mem_ren_w  ),//output              
    .o_mem_addr  (mem_addr_w ),//output [31:0]
    .o_mem_wdata (mem_wdata_w),
    .o_mem_rdtype(mem_rdtype_w),
                              //             
    .o_jump_en   (o_jump_en  ),//output       
    .o_jump_addr (o_jump_addr),//output [31:0]  
    .o_result    (result_w   ) //output [31:0]
);

 DFF_RST_CLR #(.DATA_WIDTH (1)) rdwen_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(rd_wen_w),.q(o_rd_wen));
 DFF_RST_CLR #(.DATA_WIDTH (5)) raddr_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(rd_addr_w),.q(o_rd_addr));
 DFF_RST_CLR #(.DATA_WIDTH (1)) mwen_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(mem_wen_w),.q(o_mem_wen));
 DFF_RST_CLR #(.DATA_WIDTH (1)) mren_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(mem_ren_w),.q(o_mem_ren));
 DFF_RST_CLR #(.DATA_WIDTH (32)) maddr_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(mem_addr_w),.q(o_mem_addr));
 DFF_RST_CLR #(.DATA_WIDTH (32)) mwdata_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(mem_wdata_w),.q(o_mem_wdata));
 DFF_RST_CLR #(.DATA_WIDTH (4)) mtype_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(mem_rdtype_w),.q(o_mem_rdtype));
 DFF_RST_CLR #(.DATA_WIDTH (4)) mwbe_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(mem_wbe_w),.q(o_mem_wbe));
 DFF_RST_CLR #(.DATA_WIDTH (32)) res_dff(.clk(clk_sys),.rst(rst_sys),.clr(i_pip_flush),.d(result_w),.q(o_result));

 endmodule
