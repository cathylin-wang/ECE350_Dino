// decides if we should read from rd instead of rt
module shouldReadRD(readRD, ir);
    input[31:0] ir;
    output readRD;

    wire [4:0] opcode;
    assign opcode = ir[31:27];

    assign readRD = (opcode == 5'b00111) // sw 
        | (opcode == 5'b00010) //bne
        | (opcode == 5'b00100) // jr
        | (opcode == 5'b00110); // blt

endmodule