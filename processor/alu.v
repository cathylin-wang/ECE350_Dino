module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0]  b0, adderresult, subtractresult, g, p, shiftleftresult, shiftrightresult, b_addsub;
    
/********************** Adder ********************** 
 * also operates as a subtractor when the ALU op is for subtraction
 * implemented this way so that we only calculate overflow once */

    // if im subracting, send in !b
    not32 bnot(b0, data_operandB);
    mux_2 bsubadd(b_addsub, ctrl_ALUopcode[0], data_operandB, b0);

    wire carryOutadd, ab_msb;
    cla_32bit adder(.S(adderresult), .c32(carryOutadd), .a(data_operandA), .b(b_addsub), .c0(ctrl_ALUopcode[0]));      // Adder: (S, c32, a, b, c0); 

/********************** Oveflow **********************/
    wire nota_msb, notb_msb, not_s_msb, m1o, m6o;
    not not_a_msb(nota_msb, data_operandA[31]);
    not not_b_msb(notb_msb, b_addsub[31]);
    not notmsb_sum(not_s_msb, adderresult[31]);
    and m1(m1o, nota_msb, notb_msb, adderresult[31]);
    and m2(m6o, data_operandA[31], b_addsub[31], not_s_msb);
    or getOverflow(overflow, m1o, m6o);

/********************** isNotEqual **********************/
    wire beq0_1, beq0_2, beq0_3, beq0_4;

    or compareToZero1(beq0_1, adderresult[0], adderresult[1], adderresult[2], adderresult[3], adderresult[4], adderresult[5], adderresult[6], adderresult[7]);
    or compareToZero2(beq0_2, adderresult[8], adderresult[9], adderresult[10], adderresult[11], adderresult[12], adderresult[13], adderresult[14], adderresult[15]);
    or compareToZero3(beq0_3, adderresult[16], adderresult[17], adderresult[18], adderresult[19], adderresult[20], adderresult[21], adderresult[22],  adderresult[23]);
    or compareToZero4(beq0_4, adderresult[24], adderresult[25], adderresult[26], adderresult[27], adderresult[28], adderresult[29], adderresult[30], adderresult[31]);
    // if result is 0, then adder result is equal to 0 --> isNotEual = 0
    or compareResultToZero(isNotEqual, beq0_1, beq0_2, beq0_3, beq0_4);

/********************** Subtractor ********************** 
 * Designated subtractor for subtraction and calculating isLessThan */
    wire carryOutsub, ad, ab0, b0d;
    cla_32bit subber(.S(subtractresult), .c32(carryOutsub), .a(data_operandA), .b(b0), .c0(1'b1));      // Adder: (S, c32, a, b, c0); 
    
/********************** isLessThan **********************/
    and a_d(ad, data_operandA[31], subtractresult[31]);
    and a_b0(ab0, data_operandA[31], b0[31]);
    and b_0d(b0d, b0[31], subtractresult[31]);
    or lessthansub(isLessThan, ad, ab0, b0d);


/**********************  Shifting **********************
 * module shift_left(out, in, shiftby) */
    shift_left leftshift(shiftleftresult, data_operandA, ctrl_shiftamt);

    //module sra(out, in, shiftby);
    sra rightshift(shiftrightresult, data_operandA, ctrl_shiftamt);

/********************** And/Or **********************/

    // calculate all the g' --- only use bits 0-7
    and32 calcGs(g,data_operandA,data_operandB);
    // calculate all the p' --- only use bits 0-7
    or32 calcPs(p,data_operandA,data_operandB);

/********************** Select Output **********************/
    //module mux_8_brute(out, select, in0, in1, in2, in3, in4, in5, in6, in7); 
    mux_8 pickOutput(data_result, ctrl_ALUopcode[2:0], adderresult, subtractresult, g, p, shiftleftresult, shiftrightresult, 0, 0);


endmodule