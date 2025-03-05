module dmem #(
    parameter INSTR_WIDTH                  = 32        ,
    parameter MEM_DEPTH                    = 4096       ,
    parameter MEM_DEPTH_W                  = clogb2(MEM_DEPTH) ,
    parameter U_DLY                        = 1         
) (
    input                       clk,
    input                       rst,
    input                       i_data_wena,
    input  [MEM_DEPTH_W-1: 0]   i_data_waddra,
    input  [INSTR_WIDTH-1: 0]   i_data_dina,
    input  [MEM_DEPTH_W-1: 0]   i_addrb,
    output [INSTR_WIDTH-1: 0]   o_dout_b
);

    SDP_RAM #(
        .RAM_TYPE   ("BRAM"         ),//Select "BRAM" or "DRAM"
        .DATA_W     (INSTR_WIDTH    ),//Specify RAM data width
        .RAM_DEPTH  (MEM_DEPTH      ),//Specify RAM depth (number of entries)
        .LATENCY    ("LOW_LATENCY"  ),//Select "NORMAL" or "LOW_LATENCY" 
        .INIT_FILE  (""             ) // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) u_data_mem (
        .addra      (i_data_waddra  ),// Write address bus, width determined from RAM_DEPTH
        .addrb      (i_addrb        ),// Read address bus, width determined from RAM_DEPTH
        .dina       (i_data_dina    ),// RAM input data, width determined from RAM_WIDTH
        .clk        (clk            ),// Clock
        .wea        (i_data_wena    ),// Write enable
        .reb        (1'b1           ),// Read Enable, for additional power savings, disable when not in use
        .rst        (rst            ),// Output reset (does not affect memory contents)
        .doutb      (o_dout_b       ) // RAM output data, width determined from RAM_WIDTH
    );

    function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
    endfunction

endmodule
