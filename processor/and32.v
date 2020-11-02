module and32(data_result, data_operandA, data_operandB);
        
    input [31:0] data_operandA, data_operandB;

    output [31:0] data_result;

        /*
		for(int i = 0; i < 32; i++){
		    System.out.println("and bit" + i +" (data_result[" + i + "], data_operandA[" + i + "], data_operandB[" + i + "]);");
		}
        */

    and bit0 (data_result[0], data_operandA[0], data_operandB[0]);
    and bit1 (data_result[1], data_operandA[1], data_operandB[1]);
    and bit2 (data_result[2], data_operandA[2], data_operandB[2]);
    and bit3 (data_result[3], data_operandA[3], data_operandB[3]);
    and bit4 (data_result[4], data_operandA[4], data_operandB[4]);
    and bit5 (data_result[5], data_operandA[5], data_operandB[5]);
    and bit6 (data_result[6], data_operandA[6], data_operandB[6]);
    and bit7 (data_result[7], data_operandA[7], data_operandB[7]);
    and bit8 (data_result[8], data_operandA[8], data_operandB[8]);
    and bit9 (data_result[9], data_operandA[9], data_operandB[9]);
    and bit10 (data_result[10], data_operandA[10], data_operandB[10]);
    and bit11 (data_result[11], data_operandA[11], data_operandB[11]);
    and bit12 (data_result[12], data_operandA[12], data_operandB[12]);
    and bit13 (data_result[13], data_operandA[13], data_operandB[13]);
    and bit14 (data_result[14], data_operandA[14], data_operandB[14]);
    and bit15 (data_result[15], data_operandA[15], data_operandB[15]);
    and bit16 (data_result[16], data_operandA[16], data_operandB[16]);
    and bit17 (data_result[17], data_operandA[17], data_operandB[17]);
    and bit18 (data_result[18], data_operandA[18], data_operandB[18]);
    and bit19 (data_result[19], data_operandA[19], data_operandB[19]);
    and bit20 (data_result[20], data_operandA[20], data_operandB[20]);
    and bit21 (data_result[21], data_operandA[21], data_operandB[21]);
    and bit22 (data_result[22], data_operandA[22], data_operandB[22]);
    and bit23 (data_result[23], data_operandA[23], data_operandB[23]);
    and bit24 (data_result[24], data_operandA[24], data_operandB[24]);
    and bit25 (data_result[25], data_operandA[25], data_operandB[25]);
    and bit26 (data_result[26], data_operandA[26], data_operandB[26]);
    and bit27 (data_result[27], data_operandA[27], data_operandB[27]);
    and bit28 (data_result[28], data_operandA[28], data_operandB[28]);
    and bit29 (data_result[29], data_operandA[29], data_operandB[29]);
    and bit30 (data_result[30], data_operandA[30], data_operandB[30]);
    and bit31 (data_result[31], data_operandA[31], data_operandB[31]);

endmodule