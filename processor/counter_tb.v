`timescale 1 ns / 100 ps
module counter_tb;

    wire data_resultRDY, clk;
    reg ctrl_MULT;
	// Instantiate the module to test
    counter ct(data_resultRDY, clk, ctrl_MULT);

    initial begin
    // Output file name
    $dumpfile("counter_tb.vcd");
    // Module to capture and what level, 0 means all wires
    $dumpvars(0, counter_tb);
    end

	////// Input Manipulation //////
	////// Output Results //////
    integer i, j;
    assign {clk} = i[0];
    initial begin
    for(i = 0; i < 65; i = i+1) begin
        // if (i == 2 || == 3)
        // begin
        //     ctrl_MULT = 1;
        // end
        // else
        // begin
        //     ctrl_MULT = 0;
        // end
    // Allow time for the outputs to stabilize
    #25;
    // Display the outputs for the current inputs
		$display("%d: data_resultRDY:%b, ctrl_MULT:%b", i, data_resultRDY, j[2]);
    end
    // End the testbench
    $finish;
    end
endmodule
