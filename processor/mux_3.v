module mux_3(out, select, in0, in1, in2);
	input [1:0] select;
	input [31:0] in0, in1, in2;
	output [31:0] out;
	wire [31:0] w1;

	assign w1 = (select == 2'b00) ? in0 : in2;
	assign out = (select == 2'b01) ? in1 : w1; 
endmodule
