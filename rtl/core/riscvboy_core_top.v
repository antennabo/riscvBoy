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


module riscvboy_core_top #(
    parameter           PC_W    = 32,
    parameter           INS_W   = 32
) (
   input                clk_sys,
   input                rst     ,

   //instruction fetch intf
   output               o_instr_ren,
   output [31:0]        o_instr_raddr    ,
   input  [INS_W-1:0]   i_instr_dina ,

   output               o_mem_wen,        
   output               o_mem_ren,       
   output [31:0]        o_mem_addr,     
   input  [31:0]        i_mem_rdata,
   output [31:0]        o_mem_wdata     
);

wire [INS_W-1:0]         ifu2idu_instr;
wire [4:0]               idu2reg_rs1idx;
wire [4:0]               idu2reg_rs2idx;
wire [PC_W-1:0]          dec2exu_pc;
wire [PC_W-1:0]          ifu2dec_pc;
wire                     dec2exu_rden;
wire [4:0]               dec_exu_rdidx;
wire [13:0]              dec2exu_infobus;
wire                     exu_macc_rdwen;
wire [4:0]               exu_macc_rdaddr;
wire                     exu_macc_mwreq;
wire                     exu_macc_mrreq;   
wire [31:0]              exu_macc_maddr;
wire [31:0]              exu_macc_wdata;
wire [31:0]              exu_macc_alures;
wire macc_wb_rdwen;
wire [4:0]macc_wb_rdaddr;
wire [31:0] macc_wb_alures;
wire [31:0] macc_wb_mdata;
wire                    wb2reg_rdwen;
wire [4:0]              wb2reg_rdaddr;
wire [31:0]             wb2reg_wdata;
wire [31:0] reg2idu_rs1d;
wire [31:0] reg2idu_rs2d;
wire [31:0] idu2exu_rs1d;
wire [31:0] idu2exu_rs2d;

wire [31:0] dec2exu_imm;
wire exu2ifu_jumpen;
wire [31:0] exu2ifu_jumpaddr;
wire stall_d;
wire stall_f;
wire dec_hzd_brh;
wire hzd_ifu_flush;
wire hzd2idu_flush_id2ex;
wire ctrl_exu_flush;
wire [4:0] exu2hzd_rs1idx;
wire [4:0] exu2hzd_rs2idx;
wire [1:0] ctrl_exu_rs1e;
wire [1:0] ctrl_exu_rs2e;


ifu u_instr_fec_unit(
    .clk_sys            (clk_sys),
    .rst_sys            (rst),

    .i_stall_f          (ecall|stall_f),
    .i_stall_d          (stall_d),
    .i_flush_d          (hzd_ifu_flush|ecall),
    .i_flush_f          (1'b0),

    .o_instr_ren        (o_instr_ren),
    .o_instr_raddr      (o_instr_raddr),
    .i_instr_dina       (i_instr_dina),

    .i_jump_en          (exu2ifu_jumpen),
    .i_jump_addr        (exu2ifu_jumpaddr),

    .o_instr            (ifu2idu_instr),
    .o_pc               (ifu2dec_pc)
);

idu u_instr_dec_unit(
    .clk_sys          (clk_sys),
    .rst_sys          (rst),
    //interface with ifu
    .i_pc             (ifu2dec_pc),
    .i_instr          (ifu2idu_instr),
    //interface with regfile
    .o_rs1_idx        (idu2reg_rs1idx),
    .o_rs2_idx        (idu2reg_rs2idx),
    .i_rs1_data       (reg2idu_rs1d),
    .i_rs2_data       (reg2idu_rs2d),
    .o_rd_en          (dec2exu_rden),
    .o_rs1_en         (),
    .o_rs2_en         (),
    //interface with hzd ctrl
    .i_id2ex_stall    (~ecall),
    .i_id2ex_flush    (hzd2idu_flush_id2ex),
    .o_rs1idx_e       (exu2hzd_rs1idx),
    .o_rs2idx_e       (exu2hzd_rs2idx),
    .o_mem2reg        (idu2hzd_mem2reg),

    .o_rs1data_e      (idu2exu_rs1d),
    .o_rs2data_e      (idu2exu_rs2d),
    .o_rdidx_e        (dec_exu_rdidx),
    .o_pc_e           (dec2exu_pc),
    .o_imm_e          (dec2exu_imm),
    .o_decode_info_bus(dec2exu_infobus)
);

regfile u_regs(
    .clk_sys          (clk_sys),
    .rst_sys          (rst),
    //.i_pip_flush(hzd2idu_flush_id2ex),

    .rs1_idx          (idu2reg_rs1idx),
    .rs2_idx          (idu2reg_rs2idx),
    .rs1_data         (reg2idu_rs1d), 
    .rs2_data         (reg2idu_rs2d),

    .rd_we            (wb2reg_rdwen),
    .rd_idx           (wb2reg_rdaddr),
    .rd_data          (wb2reg_wdata)
);

exu u_instr_execu_unit(
    .clk_sys          (clk_sys),
    .rst_sys          (rst),
    .i_rv32_rs1       (idu2exu_rs1d),
    .i_rv32_rs2       (idu2exu_rs2d),
    .i_rv32_imm       (dec2exu_imm),
    .i_rv32_pc        (dec2exu_pc),
    .alu_info_bus     (dec2exu_infobus),  
    .o_ecall          (ecall), 
    .i_wb_frw_data    (wb2reg_wdata),
    //output [4:0] o_fwd_rs1idx,
    //output [4:0] o_fwd_rs2idx,
    .i_fwd_rs1_e      (ctrl_exu_rs1e),
    .i_fwd_rs2_e      (ctrl_exu_rs2e),

    .i_pip_flush      (ctrl_exu_flush),

    .i_rd_wen         (dec2exu_rden),
    .i_rd_addr        (dec_exu_rdidx),
    .o_rd_wen         (exu_macc_rdwen),
    .o_rd_addr        (exu_macc_rdaddr),

    .o_mem_wen        (exu_macc_mwreq),        
    .o_mem_ren        (exu_macc_mrreq),       
    .o_mem_addr       (exu_macc_maddr),
    .o_mem_wdata      (exu_macc_wdata),

    .o_jump_en        (exu2ifu_jumpen),
    .o_jump_addr      (exu2ifu_jumpaddr),  
    .o_result         (exu_macc_alures)
 );

 
 macc u_mem_access_unit(
    .clk_sys(clk_sys),
    .rst_sys(rst),

    //interface with exu
    .i_rd_wen(exu_macc_rdwen),
    .i_rd_addr(exu_macc_rdaddr),
    .i_mem_wreq(exu_macc_mwreq),        
    .i_mem_rreq(exu_macc_mrreq),       
    .i_mem_addr(exu_macc_maddr),
    .i_mem_wdata(exu_macc_wdata),
    .i_alu_result(exu_macc_alures),

    // interface with data mem
    .o_mem_wen  (o_mem_wen),        
    .o_mem_ren  (o_mem_ren),       
    .o_mem_addr (o_mem_addr),     
    .i_mem_rdata(i_mem_rdata),
    .o_mem_wdata(o_mem_wdata),    

    //interface with wb
    .o_rd_mem(macc_wb_sel),
    .o_rd_wen(macc_wb_rdwen),
    .o_rd_addr(macc_wb_rdaddr),
    .o_mem_data(macc_wb_mdata),
    .o_alu_result(macc_wb_alures)
 );

 wb u_write_back (
    .sel(macc_wb_sel),
    .i_rd_wen(macc_wb_rdwen),
    .i_rd_addr(macc_wb_rdaddr),
    .i_alu_result(macc_wb_alures),
    .i_mem_data(macc_wb_mdata),
    .o_rd_wen(wb2reg_rdwen),
    .o_rd_addr(wb2reg_rdaddr),
    .o_rd_wdata(wb2reg_wdata)
 );


 ctrl u_ctrl(
    //interface with exu
    .i_fwd_rs1idx(exu2hzd_rs1idx),
    .i_fwd_rs2idx(exu2hzd_rs2idx),
    .o_fwd_rs1_e(ctrl_exu_rs1e),
    .o_fwd_rs2_e(ctrl_exu_rs2e),
    // interface with mem
    .i_rdidx_mem(exu_macc_rdaddr),
    .i_rdwen_mem(exu_macc_rdwen),
    .i_rdren_mem(idu2hzd_mem2reg),
    //interface with write back
    .i_rdidx_wb(macc_wb_rdaddr),
    .i_rdwen_wb(macc_wb_rdwen),

    //.i_dec_brh(dec_hzd_brh),
    .i_exu_jump(exu2ifu_jumpen),
    .o_stall_d(stall_d),
    .o_stall_f(stall_f),
    .o_flush_d(hzd2idu_flush_id2ex),
    .o_flush_e(ctrl_exu_flush),
    .o_flush_f(hzd_ifu_flush)
 );
endmodule
