module dff (
    input wire clk,      // 时钟信号
    input wire rst_n,    // 低电平复位
    input wire d,        // 数据输入
    output reg q         // 数据输出
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;  // 复位时输出 0
        else
            q <= d;     // 正常情况下，时钟上升沿时锁存数据
    end
endmodule