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

 module wb #(
    parameter A =1
 ) (
    input sel,
    input i_rd_wen,
    input [4:0]i_rd_addr,
    input [31:0] i_alu_result,
    input [31:0] i_mem_data,
    output o_rd_wen,
    output [4:0]o_rd_addr,
    output [31:0]o_rd_wdata
 );
    assign o_rd_wdata = (~sel)? i_alu_result : i_mem_data;
    assign o_rd_wen = i_rd_wen;
    assign o_rd_addr = i_rd_addr;
 endmodule