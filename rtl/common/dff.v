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

// ===========================================================================
// Description:
// DFF module without Load-enable, no reset. 
// ===========================================================================
module DFF #(
    parameter DATA_WIDTH = 32
)(
    input                             clk,// clk 
    input       [DATA_WIDTH-1:0]      d,// input data

    output reg  [DATA_WIDTH-1:0]      q//flipflop out
);
    
    always @(posedge clk) begin
        q <= d;
    end
    
endmodule

module DFF_RST #(
    parameter  DATA_WIDTH = 32,
    parameter  RST_VALUE  = {DATA_WIDTH{1'b0}}
) (
    input                             clk,// clk
    input                             rst,
    input       [DATA_WIDTH-1:0]      d,// input data

    output reg  [DATA_WIDTH-1:0]      q//flipflop out
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 0;
        else 
            q <= d; 
    end
    
endmodule

module DFF_EN #(
    parameter  DATA_WIDTH = 32
) (
    input                             clk,// clk
    input                             en,
    input       [DATA_WIDTH-1:0]      d,// input data

    output reg  [DATA_WIDTH-1:0]      q//flipflop out
);
    
    always @(posedge clk) begin
        if (en) 
            q <= d; //
    end
    
endmodule

module DFF_RST_EN #(
    parameter  DATA_WIDTH = 32,
    parameter  RST_VALUE  = {DATA_WIDTH{1'b0}}
) (
    input                             clk,// clk
    input                             rst,   
    input                             en,
    input       [DATA_WIDTH-1:0]      d,// input data

    output reg  [DATA_WIDTH-1:0]      q//flipflop out   
);

    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 0;
        else if (en) 
            q <= d; 
        else ;
    end

endmodule


module DFF_RST_EN_CLR #(
    parameter  DATA_WIDTH = 32,
    parameter  RST_VALUE  = {DATA_WIDTH{1'b0}}
) (
    input                             clk,  
    input                             rst, 
    input                             clr,
    input                             en,  
    input       [DATA_WIDTH-1:0]      d,     

    output reg  [DATA_WIDTH-1:0]      q     
);

    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 'h0;     
        else if (clr) 
            q <= 'h0;     
        else if (en) 
            q <= d;        
    end

endmodule


module DFF_RST_CLR #(
    parameter  DATA_WIDTH = 32,
    parameter  RST_VALUE  = {DATA_WIDTH{1'b0}}
) (
    input                             clk,  
    input                             rst, 
    input                             clr,
    input       [DATA_WIDTH-1:0]      d,     

    output reg  [DATA_WIDTH-1:0]      q     
);

    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 'h0;     
        else if (clr) 
            q <= 'h0;     
        else
            q <= d;        
    end

endmodule