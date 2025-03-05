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

module regfile (
    input clk_sys,
    input rst_sys,
    input i_pip_flush,
    input rd_we,  //write enable
    input [4:0] rs1_idx,//source register1
    input [4:0] rs2_idx,//source register1
    input [4:0] rd_idx ,//destination register
    input [31:0] rd_data,  //write data
    output [31:0] rs1_data,//read data1 
    output [31:0] rs2_data //read data2
);
    reg [31:0] regs [0:31]; //
    wire [31:0] rs1_data_w;
    wire [31:0] rs2_data_w;

    initial begin: INIT_REG
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'h0;
        end
    end

    always @(posedge clk_sys) begin
        if (rd_we && (rd_idx != 0))
            regs[rd_idx] <= rd_data;
    end

    assign rs1_data = (rd_we&&(rd_idx==rs1_idx)&&(rd_idx != 0)) ? rd_data: regs[rs1_idx];
    assign rs2_data = (rd_we&&(rd_idx==rs2_idx)&&(rd_idx != 0)) ? rd_data: regs[rs2_idx];

endmodule
