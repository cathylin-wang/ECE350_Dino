module decoder32(out, select, enable);
    input [4:0] select;
    input enable;
    output [31:0] out;

    wire [4:0] ns;
	not not1(ns[0], select[0]);
	not not2(ns[1], select[1]);
	not not3(ns[2], select[2]);
	not not4(ns[3], select[3]);
	not not5(ns[4], select[4]);
	and and0(out[0], ns[4], ns[3], ns[2], ns[1], ns[0]);
	and and1(out[1], ns[4], ns[3], ns[2], ns[1], select[0]);
	and and2(out[2], ns[4], ns[3], ns[2], select[1], ns[0]);
	and and3(out[3], ns[4], ns[3], ns[2], select[1], select[0]);
	and and4(out[4], ns[4], ns[3], select[2], ns[1], ns[0]);
	and and5(out[5], ns[4], ns[3], select[2], ns[1], select[0]);
	and and6(out[6], ns[4], ns[3], select[2], select[1], ns[0]);
	and and7(out[7], ns[4], ns[3], select[2], select[1], select[0]);
	and and8(out[8], ns[4], select[3], ns[2], ns[1], ns[0]);
	and and9(out[9], ns[4], select[3], ns[2], ns[1], select[0]);
	and and10(out[10], ns[4], select[3], ns[2], select[1], ns[0]);
	and and11(out[11], ns[4], select[3], ns[2], select[1], select[0]);
	and and12(out[12], ns[4], select[3], select[2], ns[1], ns[0]);
	and and13(out[13], ns[4], select[3], select[2], ns[1], select[0]);
	and and14(out[14], ns[4], select[3], select[2], select[1], ns[0]);
	and and15(out[15], ns[4], select[3], select[2], select[1], select[0]);
	and and16(out[16], select[4], ns[3], ns[2], ns[1], ns[0]);
	and and17(out[17], select[4], ns[3], ns[2], ns[1], select[0]);
	and and18(out[18], select[4], ns[3], ns[2], select[1], ns[0]);
	and and19(out[19], select[4], ns[3], ns[2], select[1], select[0]);
	and and20(out[20], select[4], ns[3], select[2], ns[1], ns[0]);
	and and21(out[21], select[4], ns[3], select[2], ns[1], select[0]);
	and and22(out[22], select[4], ns[3], select[2], select[1], ns[0]);
	and and23(out[23], select[4], ns[3], select[2], select[1], select[0]);
	and and24(out[24], select[4], select[3], ns[2], ns[1], ns[0]);
	and and25(out[25], select[4], select[3], ns[2], ns[1], select[0]);
	and and26(out[26], select[4], select[3], ns[2], select[1], ns[0]);
	and and27(out[27], select[4], select[3], ns[2], select[1], select[0]);
	and and28(out[28], select[4], select[3], select[2], ns[1], ns[0]);
	and and29(out[29], select[4], select[3], select[2], ns[1], select[0]);
	and and30(out[30], select[4], select[3], select[2], select[1], ns[0]);
	and and31(out[31], select[4], select[3], select[2], select[1], select[0]);


endmodule