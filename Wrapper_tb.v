// Define 1 ns as the delay time unit and 100 ps of precision in the waveform
`timescale 1 ns / 100 ps
module Wrapper_tb;
    reg clk, reset, up;

    // module to change
    Wrapper processor(clk, reset, up);
    
    initial begin
        // initialize inputs to 0
        clk = 0;
        reset = 1;
        up = 0;

        // time delay (ns)
        #10000
        
        //end testbrach
        $finish;
    end

    //toggle clock
    always
        #10 reset = 0; 
    always
        #10 clk = ~clk;

    // Define output waveform properties
    initial begin
    // Output file name
    $dumpfile("wrapper.vcd");
    // Module to capture and what level, 0 means all wires
    $dumpvars(0, Wrapper_tb);
    end

endmodule
        