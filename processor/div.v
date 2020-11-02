
module div(data_result, data_resultRDY, data_exception, dividend, divisor, ctrl_MULT, clock, ctrl_DIV);

    input  [31:0] dividend, divisor;
    input ctrl_MULT, clock, ctrl_DIV;

    output [31:0] data_result;
    output data_exception, data_resultRDY;
   
    // cnt to 32 -- may have to change to 33 or something
    wire data_resultRDY_hold;
    divcounter ctr(data_resultRDY, data_resultRDY_hold, clock, ctrl_MULT, ctrl_DIV);

    wire [63:0] prod, prod_shft, prod_mod, initialReg, reg_in;
    
    // at the beginning: reset product register
    assign initialReg[31:0] = dividend;
    assign initialReg[63:32] = 0; //clear high reg
    
    assign prod_shft = prod << 1;
    assign reg_in = ctrl_DIV ? initialReg : prod_mod;
    // wire [31:0] M0;
    // assign M0 = ~divisor;

    // PRODUCT REGISTER
    register64 productregister(prod, reg_in, clock, ~data_resultRDY | ~data_resultRDY_hold, 1'b0);
    
    /// Subtractor
    wire  [31:0] sub_res;
    wire c32;
    // module cla_32bit(S, c32, a, b, c0);
    cla_32bit subber(sub_res, c32, prod_shft[63:32], divisor, 1'b0);

    // is A less than M?
    wire isLessThan;
    assign isLessThan = sub_res[31]; // if result is neg, then A < M

    //2:1 mux to determine if we subtract or not
    assign prod_mod[63:32] = isLessThan ? prod_shft[63:32] : sub_res; // if A < M, then do nothing... else replace w/ subtracted
    assign prod_mod[31:1] = prod_shft[31:1];
    assign prod_mod[0] = ~isLessThan;

    // data_exception = true when divisor = 0
    assign data_exception = ~(divisor[31] | divisor[30] | divisor[29] | divisor[28] | divisor[27] | divisor[26] | divisor[25] | divisor[24] | divisor[23] | divisor[22] | divisor[21] | divisor[20] | divisor[19] | divisor[18] | divisor[17] | divisor[16] | divisor[15] | divisor[14] | divisor[13] | divisor[12] | divisor[11] | divisor[10] | divisor[9] | divisor[8] | divisor[7] | divisor[6] | divisor[5] | divisor[4] | divisor[3] | divisor[2] | divisor[1] | divisor[0]);

    // assign result to low reg
    assign data_result = prod[31:0];

    //remainder is in high reg but we dont care

endmodule