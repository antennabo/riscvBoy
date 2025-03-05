module riscvboy_top #(
    parameter A = 1
) (
    input  wire clk_sys,
    input  wire rst
);

wire [31:0]  addr_core_imem;
wire [31:0]  instr_imem_core;
wire         core_dmem_wen;
wire         core_dmem_ren;
wire [31:0]  core_dmem_addr;
wire [31:0]  dmem_core_rdata;
wire [31:0]  core_dmem_wdata;
wire instr_ren;
    
riscvboy_core_top #(
    .PC_W    (32),
    .INS_W   (32)
)u_core_top (
   .clk_sys             (clk_sys        ),
   .rst                 (rst            ),

   //instruction fetch intf
   .o_instr_ren         (instr_ren),
   .o_instr_raddr       (addr_core_imem  ),
   .i_instr_dina        (instr_imem_core ),
   
   .o_mem_wen           (core_dmem_wen),        
   .o_mem_ren           (core_dmem_ren),       
   .o_mem_addr          (core_dmem_addr),     
   .i_mem_rdata         (dmem_core_rdata),
   .o_mem_wdata         (core_dmem_wdata)   
);

imem #(
    .INSTR_WIDTH (32),
    .MEM_DEPTH(2048) 
)u_imem  (
    .clk(clk_sys),
    .rst(rst),
    .i_instr_wena(),
    .i_instr_waddra(),
    .i_instr_dina(),
    .i_instr_ren(instr_ren),
    .i_addrb(addr_core_imem[13:2]),
    .o_instr(instr_imem_core)
);

dmem #(
    .INSTR_WIDTH                  (32),
    .MEM_DEPTH                    (4096)     
)u_dmem(
    .clk(clk_sys),
    .rst(rst),
    .i_data_wena(core_dmem_wen),
    .i_data_waddra(core_dmem_addr[12:0]),
    .i_data_dina(core_dmem_wdata),
    .i_addrb(core_dmem_addr[12:0]),
    .o_dout_b(dmem_core_rdata)
);

endmodule