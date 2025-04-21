`timescale 1ns/1ps

module tb_cpu;
`ifdef TESTCASE
    localparam testcase = `TESTCASE;
`else
    localparam testcase = "default_test";
`endif
    logic clk, reset;
    wire [31:0] result;

    `define INSTR_MEM cpu.u_imem.u_ins_mem
    `define DATA_MEM cpu.u_dmem.u_data_mem
    `define REG_FILE cpu.u_core_top.u_regs
    parameter INSTR_RAM_DP=2048;
    parameter DATA_RAM_DP=4096;
    
    riscvboy_top cpu(
        .clk_sys         (clk),
        .rst             (reset)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz
    end

    integer j;
    initial begin
        reset = 1;
        #25 reset = 0; 
        #20000;
        
        for (j = 0; j < 32; j = j + 1) begin
            $display("INSTR_MEM 0x%0h: %h", j, `REG_FILE.regs[j]);
        end

        $display("TESTCASE: %s", testcase);
        test_result_summary( `REG_FILE.regs[3]);
        $finish;
    end



    integer i;
    reg [31:0] instr_mem [0:DATA_RAM_DP-1];
    initial begin
        $readmemh({ "./../isa_lib/rv32ui/", testcase, ".hex"}, instr_mem);
        for (i = 0; i < 10; i = i + 1) begin
            $display("imem[%0d] = %h", i, instr_mem[i]);
        end

        for (i = 0; i < INSTR_RAM_DP; i = i + 1) begin
            `INSTR_MEM.MEM[i] = instr_mem[i];
        end

        for (i = INSTR_RAM_DP; i < DATA_RAM_DP; i = i + 1) begin
            `DATA_MEM.MEM[i] = instr_mem[i];
        end

        $display("INSTR_MEM 0x00: %h", `INSTR_MEM.MEM[8'h00]);
    end 

    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, tb_cpu);
    end

    task test_result_summary;
    //input string testcase;
    input integer x3;
    begin
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~ Test Result Summary ~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

        $display("Final x3 Reg value: %d", x3);

        if (x3 == 1) begin
            $display("~~~~~~~~~~~~~~~~ TEST PASS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        end else begin
            $display("~~~~~~~~~~~~~~~~ TEST FAIL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        end
    end
endtask



endmodule
