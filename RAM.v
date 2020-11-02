/* The write enable in RAM is so you only enable it when you're using an instruction that actively writes to memory (such as sw).
So, you can route a control signal through it.
Note the 'wren' output in processor.v - that is routed to the RAM module.
Everything else is the same conceptually as the ROM module.

MEMORY
*/
`timescale 1ns / 1ps
module RAM #( parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 12, DEPTH = 4096, MEMFILE = "init_mem.mem") (
    input wire                     clk,
    input wire                     wEn,
    input wire [ADDRESS_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0]    dataIn, //dataIn is what you want to store into memory.
    output reg [DATA_WIDTH-1:0]    dataOut = 0);
    
    reg[DATA_WIDTH-1:0] MemoryArray[0:DEPTH-1];
    
    initial begin
        if(MEMFILE > 0) begin
            $readmemh(MEMFILE, MemoryArray);
        end
    end
    
    always @(posedge clk) begin
        if(wEn) begin
            MemoryArray[addr] <= dataIn;
        end else begin
            dataOut <= MemoryArray[addr];
        end
    end
endmodule
