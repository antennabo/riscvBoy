`ifndef FPGA
    `include "./code/macro/macro_define.v"
`endif 

module pipe_dly #(
    parameter U_DLY     = 1,
    parameter DLY_NUM   = 1,
    parameter DATA_W    = 32,
    parameter RST_VALUE = {SHIFT_NUM*DATA_W{1'b0}}
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire [DATA_W-1:0]    din,
    output wire [DATA_W-1:0]    dout
);

localparam SHIFT_NUM = DLY_NUM+1;


reg [SHIFT_NUM*DATA_W-1 :  0]  shift_reg;

always @(posedge clk or `RST_EDG rst_sys) begin
	if(rst_sys==`RST_ACT) begin
        shift_reg <= #U_DLY RST_VALUE;
    end
    else begin
        shift_reg <= #U_DLY {shift_reg[DLY_NUM*DATA_W-1 :  0],din};
    end
end

assign dout = shift_reg[SHIFT_NUM*DATA_W-1 -: DATA_W];
    
endmodule