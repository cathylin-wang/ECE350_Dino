module set_xm_inputs(rd, xm_o_in, ir, exception, ALUout, PC1);
    input[31:0] ir, ALUout, PC1;
    input exception;
    output [4:0] rd;
    output[31:0] xm_o_in;

    wire [4:0] opcode, aluop, rd_og, rd_1;
    assign opcode = ir[31:27];
    assign aluop = ir[6:2];
    assign rd_og = ir[26:22];

    wire isJal, isAddi, ALUopHasException, isSetx;
    assign isJal = (opcode == 5'b00011);
    assign isAddi = opcode == 5'b00101;
    assign ALUopHasException = ((opcode == 5'b00000) & (aluop == 5'b00000 | aluop == 5'b00001 | aluop == 5'b00110 | aluop == 5'b00111)); // addi or alu op w exception
    assign isSetx = opcode == 5'b10101;

    assign rd_1 = isJal ? 5'd31 : ir[26:22]; //set rd to 31 if jal
    assign rd = (isSetx | (exception & (isAddi | ALUopHasException))) ? 5'd30 : rd_1;

    //END RD CALC

    //START ALUOUT/MN IN CALC
    wire [31:0] w1, w2, w3, w4, T;

    ex_T getT(T, ir[26:0]);

    mux_4 MUX(w1, aluop[1:0], 32'd1, 32'd3, 32'd4, 32'd5); // figure out exception
    assign w2 = (exception & ALUopHasException) ? w1 : ALUout; // if exception --> exception mux result; else aluout
    assign w3 = (isAddi & exception) ? 2 : w2; //output = 2 if exception and addi
    assign w4 = isJal ? PC1 : w3; //output = pc+1 if jal
    assign xm_o_in = isSetx ? T : w4;

endmodule

/* last 2 bits of alu op : exception

add: 00 - 1
sub: 01 - 3
mul: 10 - 4
div: 11 - 5


addi: 2
setx: T*/


	
	// ALUop [6:2]
	// 00 -> 1
	// 01 -> 3
	// 10 -> 4
	// 11 -> 5
	// addi 00101 -> 2
	