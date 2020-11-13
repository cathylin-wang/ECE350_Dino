
`timescale 1 ns / 100 ps
module random_test;
	reg clk;
	reg[15:0] a, b;
  initial begin
		clk = 0;

		#1000

		$finish;
	end

	always
		#10 clk = ~clk;

	integer i;
	always @(posedge clk) begin
			a=$urandom % 3; 
			#100
			b=$urandom % 3;
			$display("A %d, B: %d",a,b);
  end

	initial begin
    // Output file name
    $dumpfile("random_test.vcd");
    // Module to capture and what level, 0 means all wires
    $dumpvars(0, random_test);
    end
endmodule
