`timescale 1ns / 1ps

module tb_top_cpu;

    // Parameters
    parameter INSTR_WIDTH = 8;  // Each instruction segment is 8 bits
    parameter ADDR_WIDTH = 7;   // Address width remains 7 bits

    // Inputs
    reg clk;
    reg rst;
    reg pmWrEn;
    reg [INSTR_WIDTH-1:0] instructionIn;
    reg [ADDR_WIDTH-1:0] pmAddr;

    // Outputs
    wire [31:0] aluresult;
    //wire [31:0] aluIn1, aluIn2;  // ALU input registers

    // Instantiate the Unit Under Test (UUT)
    top_cpu uut (
        .clk(clk), 
        .rst(rst), 
        .pmWrEn(pmWrEn), 
        .instructionIn(instructionIn), 
        .pmAddr(pmAddr), 
        .aluresult(aluresult)
    );

    initial begin
        clk = 0;
        rst = 1;
        pmWrEn = 0;
        instructionIn = 0;
        pmAddr = 0;
        #10;

        pmWrEn = 1'b1; // Enable Memory Write

        // Load R1 = #3
        pmAddr = 7'b000_0000; instructionIn = 8'b1_0010011; #10; // LSB
        pmAddr = 7'b000_0001; instructionIn = 8'b0_000_0000; #10;
        pmAddr = 7'b000_0010; instructionIn = 8'b00000_0011; #10;
        pmAddr = 7'b000_0011; instructionIn = 8'b0000000_0; #10; // MSB

        // Load R2 = #2
        pmAddr = 7'b000_0100; instructionIn = 8'b1_0010011; #10;
        pmAddr = 7'b000_0101; instructionIn = 8'b0_000_0000; #10;
        pmAddr = 7'b000_0110; instructionIn = 8'b00000_0010; #10;
        pmAddr = 7'b000_0111; instructionIn = 8'b0000000_0; #10;

        // NOP
        pmAddr = 7'b000_1000; instructionIn = 8'b0; #10;
        pmAddr = 7'b000_1001; instructionIn = 8'b0; #10;
        pmAddr = 7'b000_1010; instructionIn = 8'b0; #10;
        pmAddr = 7'b000_1011; instructionIn = 8'b0; #10;

        // ADD R3 = R1 + R2
        pmAddr = 7'b000_1100; instructionIn = 8'b1_0110011; #10;
        pmAddr = 7'b000_1101; instructionIn = 8'b0_000_0001; #10;
        pmAddr = 7'b000_1110; instructionIn = 8'b00010_0001; #10;
        pmAddr = 7'b000_1111; instructionIn = 8'b0000000_0; #10;

        // Load R4 = #8
        pmAddr = 7'b001_0000; instructionIn = 8'b1_0010011; #10;
        pmAddr = 7'b001_0001; instructionIn = 8'b0_000_0000; #10;
        pmAddr = 7'b001_0010; instructionIn = 8'b00000_1000; #10;
        pmAddr = 7'b001_0011; instructionIn = 8'b0000000_0; #10;

        // NOP
        pmAddr = 7'b001_0100; instructionIn = 8'b0; #10;
        pmAddr = 7'b001_0101; instructionIn = 8'b0; #10;
        pmAddr = 7'b001_0110; instructionIn = 8'b0; #10;
        pmAddr = 7'b001_0111; instructionIn = 8'b0; #10;

        // SUB R5 = R4 - R3
        pmAddr = 7'b001_1000; instructionIn = 8'b1_0110011; #10;
        pmAddr = 7'b001_1001; instructionIn = 8'b0_000_0100; #10;
        pmAddr = 7'b001_1010; instructionIn = 8'b00011_0010; #10;
        pmAddr = 7'b001_1011; instructionIn = 8'b0100000_0; #10;

        // AND R6 = R4 & R3
        pmAddr = 7'b001_1100; instructionIn = 8'b1_0110011; #10;
        pmAddr = 7'b001_1101; instructionIn = 8'b0_000_0100; #10;
        pmAddr = 7'b001_1110; instructionIn = 8'b00011_0110; #10;
        pmAddr = 7'b001_1111; instructionIn = 8'b0000000_0; #10;

        // OR R7 = R4 | R3
        pmAddr = 7'b010_0000; instructionIn = 8'b1_0110011; #10;
        pmAddr = 7'b010_0001; instructionIn = 8'b0_000_0100; #10;
        pmAddr = 7'b010_0010; instructionIn = 8'b00011_0111; #10;
        pmAddr = 7'b010_0011; instructionIn = 8'b0000000_0; #10;

        // XOR R8 = R4 ^ R3
        pmAddr = 7'b010_0100; instructionIn = 8'b1_0110011; #10;
        pmAddr = 7'b010_0101; instructionIn = 8'b0_000_0100; #10;
        pmAddr = 7'b010_0110; instructionIn = 8'b00011_0100; #10;
        pmAddr = 7'b010_0111; instructionIn = 8'b0000000_0; #10;

        // HALT
        pmAddr = 7'b010_1000; instructionIn = 8'b00000001; #10;
        pmAddr = 7'b010_1001; instructionIn = 8'b00000000; #10;
        pmAddr = 7'b010_1010; instructionIn = 8'b00000000; #10;
        pmAddr = 7'b010_1011; instructionIn = 8'b00000000; #10;

        pmWrEn = 1'b0;
        #5 rst = 1'b0;
        #1000 $finish;
    end

    // Clock generation
    always #5 clk = !clk;

    // ✅ Corrected Monitor Statement
    initial begin
        $display("Time | ALU Input1 | ALU Input2 | ALU Output");
        $monitor("%4t  |  %10d  |  %10d  |  %10d", 
                 $time, uut.muxOut, uut.data2, aluresult);
    end

    // VCD Dump for Simulation
    initial begin 
        $dumpfile("dump.vcd"); 
        $dumpvars; 
    end

endmodule
