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
    input [4:0]   i_rd_addr,
    input         i_mem_wreq,  
    input [3:0]   i_mem_wbe,        
    input         i_mem_rreq,
    input [3:0]   i_mem_rdtype,       
    input [31:0]  i_mem_addr,
    input [31:0]  i_alu_result,
    input [31:0]  i_mem_wdata,

    // interface with data mem
    output        o_mem_wen,        
    output        o_mem_ren,  
    output [3:0]  o_mem_wbe,     
    output [31:0] o_mem_addr,     
    input  [31:0] i_mem_rdata,
    output [31:0] o_mem_wdata,    

    //interface with wb
    output        o_rd_wen,
    output [4:0]  o_rd_addr,
    output        o_rd_mem,
    output [31:0] o_mem_data,
    output [31:0] o_alu_result
 );

wire [3:0] mem_rdtype;
wire [1:0] mem_rdaddr;
reg  [7:0] mem_data_8bit;
reg  [15:0]mem_data_16bit;
assign o_mem_wen = i_mem_wreq;
assign o_mem_ren = i_mem_rreq;
assign o_mem_addr = i_mem_addr;
assign o_mem_wdata = i_mem_wdata;
assign o_mem_wbe = i_mem_wbe;

always @(*)begin
   case(mem_rdaddr)
      2'b00 :mem_data_8bit = i_mem_rdata[7:0];
      2'b01 :mem_data_8bit = i_mem_rdata[15:8];
      2'b10 :mem_data_8bit = i_mem_rdata[23:16];
      2'b11 :mem_data_8bit = i_mem_rdata[31:24];
      default: mem_data_8bit = 8'h00;
   endcase
end

always @(*)begin
   case(mem_rdaddr[1])
      1'b0 :mem_data_16bit = i_mem_rdata[15:0];
      2'b1 :mem_data_16bit = i_mem_rdata[31:16];
      default: mem_data_16bit = 16'h00;
   endcase
end
wire [31:0] mem_lb_data = (mem_rdtype[3])? {{24{mem_data_8bit[7]}},mem_data_8bit}:{24'h0,mem_data_8bit};
wire [31:0] mem_lh_data = (mem_rdtype[3])? {{16{mem_data_16bit[15]}},mem_data_16bit}:{16'h0,mem_data_16bit};
assign o_mem_data = ({32{mem_rdtype[0]}}&i_mem_rdata)|
                     ({32{mem_rdtype[1]}}&mem_lh_data)|
                     ({32{mem_rdtype[2]}}&mem_lb_data);


DFF_RST #(.DATA_WIDTH (1)) rwen_dff(.clk(clk_sys),.rst(rst_sys),.d(i_rd_wen),.q(o_rd_wen));
DFF_RST #(.DATA_WIDTH (5)) raddr_dff(.clk(clk_sys),.rst(rst_sys),.d(i_rd_addr),.q(o_rd_addr));
DFF_RST #(.DATA_WIDTH (1)) mem_sel_dff(.clk(clk_sys),.rst(rst_sys),.d(i_mem_rreq),.q(o_rd_mem));
DFF_RST #(.DATA_WIDTH (4)) mem_rdtype_dff(.clk(clk_sys),.rst(rst_sys),.d(i_mem_rdtype),.q(mem_rdtype));
DFF_RST #(.DATA_WIDTH (2)) mem_rdaddr_dff(.clk(clk_sys),.rst(rst_sys),.d(i_mem_addr[1:0]),.q(mem_rdaddr));
DFF_RST #(.DATA_WIDTH (32)) res_dff(.clk(clk_sys),.rst(rst_sys),.d(i_alu_result),.q(o_alu_result));

endmodule