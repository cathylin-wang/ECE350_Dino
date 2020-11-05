// Define 1 ns as the delay time unit and 100 ps of precision in the waveform
`timescale 1 ns / 100 ps
module Wrapper_tb;
    reg clk, reset, up;

    wire hSync, vSync;
    wire [3:0] VGA_R, VGA_G, VGA_B;

    // module to change
    Wrapper processor(clk, reset, hSync, vSync, VGA_R, VGA_G, VGA_B, up, 1'b0);

    initial begin
        // initialize inputs to 0
        clk = 0;
        reset = 1;
        up = 0;

        #1 reset = 0;

        // time delay (ns)
        #1000
        
        //end testbrach
        $finish;
    end

    //toggle clock
    always
        #1 clk = ~clk;
    always
        #5 up = ~up;

    // Define output waveform properties
    initial begin
    // Output file name
    $dumpfile("wrapper.vcd");
    // Module to capture and what level, 0 means all wires
    $dumpvars(0, Wrapper_tb);
    end

endmodule
        