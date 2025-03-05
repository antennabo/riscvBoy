module gray2bin #(
    parameter   SIZE = 4
) (
    input  [SIZE-1:0]     gray,
    output [SIZE-1:0]     bin
);
    
    reg [SIZE-1:0] bin;

    /*
    bit0: bin[0] = gray[n]^gray[n-1]^   ...^ gray[0]
    bit1: bin[1] = 1'b0   ^gray[n-1]^   ...^ gray[0]
    ...
    bitn: bin[n] = 1'b0   ^      ...^  1'b0^ gray[0]
    */
    integer i;
    always @(gray)
        for (i=0; i<SIZE; i=i+1)
            bin[i] = ^(gray>>i);

endmodule