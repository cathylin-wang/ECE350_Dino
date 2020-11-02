module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

// module register(out, in, clk, input_enable, clr);
    wire [31:0] da, db, d_a, d_b;
    register A(da, data_operandA, clock, ctrl_MULT | ctrl_DIV, 1'b0);
    register B(db, data_operandB, clock, ctrl_MULT | ctrl_DIV, 1'b0);

    assign d_a = ctrl_MULT |  ctrl_DIV ? data_operandA : da;
    assign d_b = ctrl_MULT | ctrl_DIV ? data_operandB : db;

    wire selectRes;
    dffe_ref multORdiv (selectRes, ctrl_MULT, clock, ctrl_MULT, ctrl_DIV);

    wire [31:0] data_result_mul, data_result_div;
    wire data_resultRDY_mul, data_resultRDY_div, data_exception_mul, data_exception_div;

    mul MUL(data_result_mul, data_resultRDY_mul, data_exception_mul, d_a, d_b, ctrl_MULT, clock, ctrl_DIV);

    // Make div parameters positive
    wire [31:0] dividend0, divisor0, dividend, divisor;
    twos_complement COMPA(dividend0, d_a);
    twos_complement COMPB(divisor0, d_b);
    assign dividend = d_a[31] ? dividend0 : d_a;
    assign divisor = d_b[31] ? d_b : divisor0;

    wire [31:0] pos_div_res;
    div DIV(pos_div_res, data_resultRDY_div, data_exception_div, dividend, divisor, ctrl_MULT, clock, ctrl_DIV);

    wire [31:0] neg_div_res;
    twos_complement flipResult(neg_div_res, pos_div_res);
    assign data_result_div = d_a[31] ^ d_b[31] ? neg_div_res : pos_div_res;

    // register 
    // select bt mul or div results
    wire [31:0] data_result_temp, data_result_hold;
    //correct
    assign data_result = selectRes ? data_result_mul: data_result_div; 

    //experiment
    // assign data_result_temp = selectRes ? data_result_mul: data_result_mul;
    // register result(data_result_hold, data_result_temp, ~clock, data_resultRDY_mul | data_resultRDY_div, 1'b0);
    // assign data_result = data_result_mul | data_result_mul ? data_result_temp : data_result_hold;
    
    assign data_exception = selectRes ? data_exception_mul: data_exception_div;
    assign data_resultRDY = selectRes ? data_resultRDY_mul: data_resultRDY_div;

endmodule
