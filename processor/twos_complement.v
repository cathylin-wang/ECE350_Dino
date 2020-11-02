module twos_complement(out, in);
	input [31:0] in;
	output [31:0] out;

    wire Co;
	wire [31:0] flipped;

	assign flipped = ~in;

	cla_32bit ADD(out, Cout, flipped, 0, 1'b1);

endmodule
