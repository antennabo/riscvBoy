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
module SDP_RAM #(
    parameter RAM_TYPE        = "BRAM",               // "BRAM" or "DRAM"
    parameter DATA_W          = 32,                   // Data bus width
    parameter RAM_DEPTH       = 256,                  // RAM depth
    parameter DEPTH_W         = clogb2(RAM_DEPTH),    // Address width
    parameter LATENCY         = "NORMAL",             // "NORMAL" = output reg, "LOW_LATENCY" = raw output
    parameter INIT_FILE       = "",                   // Memory init file (hex)
    parameter USE_BYTE_ENABLE = 0                     // 1: use byte mask; 0: whole-word write
) (
    input  wire                      clk,
    input  wire                      rst,
    input  wire                      wea,
    input  wire [DATA_W/8-1:0]       byte_enable,
    input  wire                      reb,
    input  wire [DEPTH_W-1:0]        addra,
    input  wire [DEPTH_W-1:0]        addrb,
    input  wire [DATA_W-1:0]         dina,
    output wire [DATA_W-1:0]         doutb
);

    localparam RAM_STYLE = (RAM_TYPE == "BRAM") ? "block" :
                           (RAM_TYPE == "DRAM") ? "distributed" : "";

    // 2D RAM array: each word is DATA_W bits wide
    (* ram_style = RAM_STYLE *) reg [DATA_W-1:0] MEM [0:RAM_DEPTH-1];

    reg [DATA_W-1:0] ram_data;
    integer i;

    always @(posedge clk) begin
        // Write logic
        if (wea) begin
            if (USE_BYTE_ENABLE) begin
                // Byte-wise write
                for (i = 0; i < DATA_W/8; i = i + 1) begin
                    if (byte_enable[i])
                        MEM[addra][i*8 +: 8] <= dina[i*8 +: 8];
                end
            end else begin
                // Full word write
                MEM[addra] <= dina;
            end
        end

        // Read logic
        if (reb)
            ram_data <= MEM[addrb];
    end

    // Output logic: normal (registered) or low latency
    generate
        if (LATENCY == "LOW_LATENCY") begin : low_lat
            assign doutb = ram_data;
        end else begin : reg_out
            reg [DATA_W-1:0] doutb_reg;
            always @(posedge clk or posedge rst)
                if (rst)
                    doutb_reg <= {DATA_W{1'b0}};
                else
                    doutb_reg <= ram_data;
            assign doutb = doutb_reg;
        end
    endgenerate

    // Memory initialization
    generate
        if (INIT_FILE != "") begin : use_init_file
            initial $readmemh(INIT_FILE, MEM);
        end else begin : init_to_zero
            integer i;
            initial begin
                for (i = 0; i < RAM_DEPTH; i = i + 1)
                    MEM[i] = {DATA_W{1'b0}};
            end
        end
    endgenerate

    // clog2 function
    function integer clogb2;
        input integer depth;
        begin
            clogb2 = 0;
            while (depth > 0) begin
                depth = depth >> 1;
                clogb2 = clogb2 + 1;
            end
        end
    endfunction

endmodule



// The following is an instantiation template for SDP_RAM
/*
//Simple Dual Port Single Clock RAM
  SDP_RAM #(
    .RAM_TYPE("BRAM"),                  //Select "BRAM" or "DRAM"
    .RAM_WIDTH(18),                     //Specify RAM data width
    .RAM_DEPTH(1024),                   //Specify RAM depth (number of entries)
    .LATENCY("NORMAL"),                 //Select "NORMAL" or "LOW_LATENCY" 
    .INIT_FILE("")                      // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addra(addra),   // Write address bus, width determined from RAM_DEPTH
    .addrb(addrb),   // Read address bus, width determined from RAM_DEPTH
    .dina(dina),     // RAM input data, width determined from RAM_WIDTH
    .clk(clk),     // Clock
    .wea(wea),       // Write enable
    .reb(reb),	     // Read Enable, for additional power savings, disable when not in use
    .rst(rst),     // Output reset (does not affect memory contents)
    .doutb(doutb)    // RAM output data, width determined from RAM_WIDTH
  );
*/