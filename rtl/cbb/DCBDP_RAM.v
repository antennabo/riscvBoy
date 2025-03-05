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
 module DCBDP_RAM #(
    parameter RAM_TYPE                  = "BRAM"    ,//BRAM or DRAM
    parameter DATA_W                    = 2        ,
    parameter RAM_DEPTH                 = 256        ,      
    parameter DEPTH_W                   = clogb2(RAM_DEPTH)-1,
    parameter LATENCY                   = "NORMAL",
    parameter INIT_FILE                 = "" 
) (
    input wire                          clk_a,
    input wire                          clk_b,
    input                               rst_b,
    input wire                          wea ,
    input wire                          reb ,
    input wire [DEPTH_W-1       :   0]  addra,
    input wire [DEPTH_W-1       :   0]  addrb,
    input wire [DATA_W-1        :   0]  dina,
    output     [DATA_W-1        :   0]  doutb
);

    //(* ram_style = "block" *) define the ram type as Block RAM
    //(* ram_style = "distributed" *) define the ram type as distributed RAM
    localparam RAM_STYLE = (RAM_TYPE == "BRAM") ? "block" : 
                           (RAM_TYPE == "DRAM") ? "distributed" : "";

    (* ram_style = RAM_STYLE *) reg [DATA_W-1:0] MEM [RAM_DEPTH-1:0];

    reg      [DATA_W-1        :   0]  ram_data;

    always @(posedge clk_a) begin
        if (wea)
            MEM[addra] <= dina;

    end

    always @(posedge clk_b) begin
        if (reb)
            ram_data <= MEM[addrb];
    end

    //  The following code generates NORMAL (use output register) or LOW_LATENCY (no output register)
    generate
        if (LATENCY == "LOW_LATENCY") begin: no_output_register

        // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
        assign doutb = ram_data;

    end else begin: output_register

        // The following is a 2 clock cycle read latency with improve clock-to-out timing

        reg [DATA_W-1:0] doutb_reg = {DATA_W{1'b0}};

        always @(posedge clk_b or posedge rst_b)
            if (rst_b)
                doutb_reg <= {DATA_W{1'b0}};
            else
                doutb_reg <= ram_data;

        assign doutb = doutb_reg;
    end
    endgenerate

    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (INIT_FILE != "") begin: use_init_file
        initial
            $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
        end else begin: init_bram_to_zero
            integer ram_index;
            initial
            for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            MEM[ram_index] = {DATA_W{1'b0}};
        end
    endgenerate
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

// The following is an instantiation template for SDP_RAM
/*
//Simple Dual Port Single Clock RAM
  DCBDP_RAM #(
    .RAM_TYPE("BRAM"),                  //Select "BRAM" or "DRAM"
    .RAM_WIDTH(18),                     //Specify RAM data width
    .RAM_DEPTH(1024),                   //Specify RAM depth (number of entries)
    .LATENCY("NORMAL"),                 //Select "NORMAL" or "LOW_LATENCY" 
    .INIT_FILE("")                      // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addra(addra),   // Write address bus, width determined from RAM_DEPTH
    .addrb(addrb),   // Read address bus, width determined from RAM_DEPTH
    .dina(dina),     // RAM input data, width determined from RAM_WIDTH
    .clk_a(clk_a),     // Clock for write port
    .clk_b(clk_b),     // Clock for read port
    .wea(wea),       // Write enable
    .reb(reb),	     // Read Enable, for additional power savings, disable when not in use
    .rst_b(rst_b),     // Output reset (does not affect memory contents)
    .doutb(doutb)    // RAM output data, width determined from RAM_WIDTH
  );
*/
