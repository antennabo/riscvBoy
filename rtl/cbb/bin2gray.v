module bin2gray #(
    parameter SIZE = 4
) (
    input       [SIZE-1:0] bin,
    output reg  [SIZE-1:0] gray
);

    always @(*)begin
        gray = (bin>>1)^bin;
    end
    
endmodule