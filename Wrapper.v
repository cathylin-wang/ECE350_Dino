`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, RegFile and Memory elements together.
 * 
 * We will be using our own separate Wrapper.v to test your code. You are allowed to make changes to the Wrapper file for your
 * own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 */

module Wrapper(
    input clock, 
    input reset, 
    output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	input up, 
    input down);

    wire game_over;
    wire rwe, mwe;
    wire[4:0] rd, rs1, rs2;
    wire[31:0] instAddr, instData, 
               rData, regA, regB,
               memAddr, memDataIn, memDataOut;

    wire screenEnd; // 60 Hz
    wire [31:0] dino_x, dino_y;

    
    wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clock) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

    
    ///// Main Processing Unit
    processor CPU(.clock(clk25), .reset(reset), .screen_end(screenEnd),
                  
		  ///// ROM
                  .address_imem(instAddr), .q_imem(instData),
                  
		  ///// Regfile
                  .ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
                  .ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
                  .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
                  
		  ///// RAM
                  .wren(mwe), .address_dmem(memAddr), 
                  .data(memDataIn), .q_dmem(memDataOut),
                  
          //// IO
                  .io_jump(up)
                  ); 
                  
    ///// Instruction Memory (ROM)
    // acknowledge my change please 3
    ROM #(.MEMFILE("ECE350F2020 ToolChain/game_inst.mem"))InstMem(.clk(clock), .wEn(1'b0), .addr(instAddr[11:0]), .dataIn(32'b0), .dataOut(instData));
    
    ///// Register File
    regfile RegisterFile(.clock(clock), 
             .ctrl_writeEnable(rwe & ~game_over), .ctrl_reset(reset), 
             .ctrl_writeReg(rd),
             .ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
             .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB), .r1(dino_x), .r2(dino_y));
             
    ///// Processor Memory (RAM)
    RAM ProcMem(.clk(clock), .wEn(mwe), .addr(memAddr[11:0]), .dataIn(memDataIn), .dataOut(memDataOut));

    ///// VGA Controller
    VGAController vga(clock, reset, hSync, vSync, VGA_R, VGA_G, VGA_B, screenEnd, up, down, dino_x, dino_y, game_over);

    // Define counter and audio clock
    // System clock is 100 MHz system clock?
	// reg game_clock = 0;
	// reg[31:0] game_clock_ctr = 0;
	// always @(posedge clock) begin
	// 	if (game_clock_ctr < 10000000 - 1)  
	// 		game_clock_ctr <= game_clock_ctr + 1;
	// 	else begin
	// 		game_clock_ctr <= 0;
	// 		game_clock <= ~game_clock;
	// 	end
	// end




endmodule
