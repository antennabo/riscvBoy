module dff_en (
    input wire clk,
    input wire rst_n,
    input wire en,  // 使能信号
    input wire d,
    output reg q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else if (en)
            q <= d;
        else ;
    end
endmodule