// Define 1 ns as the delay time unit and 100 ps of precision in the waveform
`timescale 1 ns / 100 ps
module score_tb;
    reg clk;
		reg[4:0] score_4, score_3, score_2, score_1, score_0, A_mod;
		reg[16:0] curr_score, A_copy;

		// wire[4:0] out_4, out_3, out_2, out_1, out_0;

    // module to change
    // score SC(out_4, out_3, out_2, out_1, out_0, curr_score, clk);

    initial begin
        // initialize inputs to 0
        clk = 0;
				curr_score = 0;
				score_4 = 0;
				score_3 = 0;
				score_2 = 0; 
				score_1 = 0; 
				score_0 = 0;
				A_mod = 0;
				A_copy = 0;

        // time delay (ns)
        #1000000
        
        //end testbrach
        $finish;
    end

    //toggle clock
    always
			#1 clk = ~clk;
		
		integer i;

		always @(posedge clk) begin
			if (curr_score <= 100000) begin
				A_copy <= curr_score;
				for (i=0; i<5; i=i+1) begin
					A_mod = A_copy%10;
					case(i)
						0 : score_0 <= A_mod;
						1 : score_1 <= A_mod;
						2 : score_2 <= A_mod;
						3 : score_3 <= A_mod;
						4 : score_4 <= A_mod;
						default : score_0 <= A_mod;
					endcase
					A_copy = A_copy/10;
				end
			end
			curr_score <= curr_score + 1;
		end


    // Define output waveform properties
    initial begin
			// Output file name
			$dumpfile("score.vcd");
			// Module to capture and what level, 0 means all wires
			$dumpvars(0, score_tb);
    end

endmodule
