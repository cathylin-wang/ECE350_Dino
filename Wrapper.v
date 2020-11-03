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

module Wrapper(clock, reset, up_button);
    input clock, reset, up_button;

    wire rwe, mwe;
    wire[4:0] rd, rs1, rs2;
    wire[31:0] instAddr, instData, 
               rData, regA, regB,
               memAddr, memDataIn, memDataOut;
    
    ///// Main Processing Unit
    processor CPU(.clock(clock), .reset(reset), 
                  
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
                  .io_jump(up_button)
                  ); 
                  
    ///// Instruction Memory (ROM)
    ROM #(.MEMFILE("ECE350F2020 ToolChain/jio_test.mem"))InstMem(.clk(clock), .wEn(1'b0), .addr(instAddr[11:0]), .dataIn(32'b0), .dataOut(instData));
    
    ///// Register File
    regfile RegisterFile(.clock(clock), 
             .ctrl_writeEnable(rwe), .ctrl_reset(reset), 
             .ctrl_writeReg(rd),
             .ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
             .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
             
    ///// Processor Memory (RAM)
    RAM ProcMem(.clk(clock), .wEn(mwe), .addr(memAddr[11:0]), .dataIn(memDataIn), .dataOut(memDataOut));


endmodule
