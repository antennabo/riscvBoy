module hzd_ctrl #(
    parameter A =1
) (
    //from idu
    input [4:0] i_rs1idx_d,
    input [4:0] i_rs2idx_d,
    output [1:0] o_fwd_rs1_d,
    output [1:0] o_fwd_rs2_d,
    //from exu
    input [4:0] i_fwd_rs1idx,
    input [4:0] i_fwd_rs2idx,
    output [1:0] o_fwd_rs1_e,
    output [1:0] o_fwd_rs2_e,
    //interface with mem acc
    input [4:0] i_rdidx_mem,
    input       i_rdwen_mem,
    //interface with write back
    input [4:0] i_rdidx_wb,
    input       i_rdwen_wb,


    //input  i_dec_brh,
    input  i_exu_jump,
    output o_stall_f,
    output o_stall_d,
    output o_flush_d,
    output o_flush_e,
    output o_flush_f
);

    reg [1:0] fwd_rs1_E;
    reg [1:0] fwd_rs2_E;
    reg [1:0] fwd_rs1_d;
    reg [1:0] fwd_rs2_d;

    assign o_stall_d = 1'b0;
    assign o_stall_f = 1'b0;
    assign o_flush_d = i_exu_jump;
    assign o_flush_f = i_exu_jump;
    assign o_flush_e = 1'b0;

    //forwarding sources to E stage (ALU)
    assign o_fwd_rs1_e = fwd_rs1_E;
    assign o_fwd_rs2_e = fwd_rs2_E;

	always @(*) begin
		fwd_rs1_E = 2'b00;
		fwd_rs2_E = 2'b00;
		if(i_fwd_rs1idx != 0) begin
			if(i_fwd_rs1idx == i_rdidx_mem & i_rdwen_mem)
				fwd_rs1_E = 2'b10;
			else if(i_fwd_rs1idx == i_rdidx_wb & i_rdwen_wb)
				fwd_rs1_E = 2'b01;
		end

		if(i_fwd_rs2idx != 0) begin
			if(i_fwd_rs2idx == i_rdidx_mem & i_rdwen_mem) 
				fwd_rs2_E = 2'b10;
			else if(i_fwd_rs2idx == i_rdidx_wb & i_rdwen_wb)
				fwd_rs2_E = 2'b01;
		end
	end

    //forwarding stage decode
	//forwarding sources to D stage (branch equality)
	assign forwardaD = (i_rs1idx_d != 0 & i_rs1idx_d == i_rdidx_mem & i_rdwen_mem);
	assign forwardbD = (i_rs2idx_d != 0 & i_rs2idx_d == i_rdidx_mem & i_rdwen_mem);
endmodule