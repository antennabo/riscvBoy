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

 module exu_alu_agu #(
    parameter DATA_WIDTH = 32
 ) (
    input                           i_mem_wreq,
    input                           i_mem_rreq,
    input      [DATA_WIDTH -1:0]    i_alu_res,
    input      [DATA_WIDTH -1:0]    i_rs2_data,
    input      [2:0]                i_mem_wtype,
    output                          o_mem_wen,
    output     [31:0]               o_mem_addr,
    output reg [DATA_WIDTH -1:0]    o_mem_wdata,
    output reg [3:0]                o_data_be,
    output                          o_mem_ren
 );

assign o_mem_ren = i_mem_rreq;
assign o_mem_wen = i_mem_wreq;
assign o_mem_addr = i_alu_res;

always@(*) begin
   case (i_mem_wtype)  // Data type 001 Word, 010 Half word, 100 byte
      3'b001: begin  // Writing a word
            o_data_be = 4'b1111;
      end
      3'b010: begin  // Writing a half word
          case (o_mem_addr[1:0])
            2'b00:   o_data_be = 4'b0011;
            2'b01:   o_data_be = 4'b0110;
            2'b10:   o_data_be = 4'b1100;
            default: o_data_be = 4'b1000;
          endcase
      end
      3'b100: begin  // Writing a byte
        case (o_mem_addr[1:0])
          2'b00:   o_data_be = 4'b0001;
          2'b01:   o_data_be = 4'b0010;
          2'b10:   o_data_be = 4'b0100;
          default: o_data_be = 4'b1000;
        endcase
      end
   endcase
end

  always@(*) begin
    case (o_mem_addr[1:0])
      2'b00: o_mem_wdata = i_rs2_data[31:0];
      2'b01: o_mem_wdata = {i_rs2_data[23:0], i_rs2_data[31:24]};
      2'b10: o_mem_wdata = {i_rs2_data[15:0], i_rs2_data[31:16]};
      2'b11: o_mem_wdata = {i_rs2_data[7:0], i_rs2_data[31:8]};
    endcase
  end

endmodule