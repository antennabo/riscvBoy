module pipe_dly #(
    parameter U_DLY     = 1,
    parameter DLY_NUM   = 1,
    parameter DATA_W    = 32
) (
    input  wire                 clk,
    input  wire [DATA_W-1:0]    din,
    output wire [DATA_W-1:0]    dout
);

localparam SHIFT_NUM = DLY_NUM+1;

reg [SHIFT_NUM*DATA_W-1 :  0]  shift_reg;

always @(posedge clk ) begin
    shift_reg <= #U_DLY {shift_reg[DLY_NUM*DATA_W-1 :  0],din};
end

assign dout = shift_reg[SHIFT_NUM*DATA_W-1 -: DATA_W];
    
endmodule