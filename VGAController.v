`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz system Clock
	input reset, 		// Reset Signal
	output hSync, 		// H sync Signal
	output vSync, 		// Veritcal sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	output screenEnd,
	input up,
	input down,
	input[31:0] dino_x,
	input[31:0] dino_y,
	output game_over);
	
	/************ LAB MEMORY FILES LOCATION ************/
	// localparam FILES_PATH = "/Users/smwhitt/Duke/2021/F2020/ece350/cpu/ECE350_Dino/assets/"; // FOR SAMMY waveform
	localparam FILES_PATH = "Z:/cpu/ECE350_Dino/assets/"; // FOR SAMMY vivado
	// localparam FILES_PATH = "C:/Users/cwang/Courses/ECE350/final_project/ECE350_Dino/assets/"; //FOR CATHY

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock
	wire scoreClock;

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	reg[4:0] screenEndDivider = 0;
	assign scoreClock = &screenEndDivider;

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active;
	wire[9:0] x;
	wire[8:0] y;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1, // Use built in log2 Command
		GROUND = 335; 

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	/************ WIRES AND REGISTERS ************/
	// VGA OUTPUT
	wire[BITS_PER_COLOR-1:0] colorOut, colorData, tempColor;
	// SCORE
	reg[16:0] high_score = 0, curr_score = 0, curr_score_copy = 0; // overall scores
	reg[13:0] mod_score = 0, curr_score4_addr = 0, curr_score3_addr = 0, curr_score2_addr = 0, curr_score1_addr = 0, curr_score0_addr = 0; // curr score bit breakdown (for RAM)
	reg[13:0] high_score4_addr = 0, high_score3_addr = 0, high_score2_addr = 0, high_score1_addr = 0, high_score0_addr = 0; // high score bit breakdown (for RAM)
	reg[31:0] score_y = 10; // y location for scores
	reg[31:0] curr_score4_x = 495, curr_score3_x = 520, curr_score2_x = 545, curr_score1_x = 570, curr_score0_x = 595; // x location for curr score
	reg[31:0] high_score4_x = 10, high_score3_x = 35, high_score2_x = 60, high_score1_x = 85, high_score0_x = 110; // x location for high score
	wire curr_score4_data, curr_score3_data, curr_score2_data, curr_score1_data, curr_score0_data; // curr score RAM per bit
	wire high_score4_data, high_score3_data, high_score2_data, high_score1_data, high_score0_data; // high score RAM per bit
	wire currScore4Square, currScore3Square, currScore2Square, currScore1Square, currScore0Square; // on pixels where curr score should be
	wire highScore4Square, highScore3Square, highScore2Square, highScore1Square, highScore0Square; // on pixels where high score should be
	wire currScoreData, highScoreData; // display score at that part of the screen (in square and data from RAM)
	wire new_high_score;
	// DINO
	wire dino_data, dinoSquare;
	// CACTI
	reg[31:0] cacti_x = 550, cacti_y = GROUND-80;
	wire[31:0] cacti_update;
	wire cacti_data, cactiSquare;
	// BACKGROUND
	wire background_data;
	// GAME OVER (SCREEN)
	reg[31:0] gameover_x = 135, gameover_y = 152;
	wire gameover_data, gameoverSquare;
	// OFFSETS
	reg[12:0] offset = 0, cacti_offset = 0;
	reg[12:0] curr_score4_offset = 0, curr_score3_offset = 0, curr_score2_offset = 0, curr_score1_offset = 0, curr_score0_offset = 0;
	reg[12:0] high_score4_offset = 0, high_score3_offset = 0, high_score2_offset = 0, high_score1_offset = 0, high_score0_offset = 0;
	reg[13:0] gameover_offset = 0;
	// GLOBAL GAME
	wire game_on;

	/************ UPDATING VALUES ************/
	// calculate score
	integer i;
	always @(posedge scoreClock or posedge reset) begin
		if (reset) begin
			curr_score <= 17'd0;
			curr_score_copy <= 17'd0;
			mod_score <= 14'd0;
			curr_score0_addr <= 14'd0;
			curr_score1_addr <= 14'd0;
			curr_score2_addr <= 14'd0;
			curr_score3_addr <= 14'd0;
			curr_score4_addr <= 14'd0;
		end
		else begin
			if (~game_over & game_on) begin 
				if (curr_score <= 100000) begin
					curr_score_copy <= curr_score;
					for (i=0; i<5; i=i+1) begin
						mod_score = curr_score_copy%10;
						case(i)
							0 : curr_score0_addr <= mod_score;
							1 : curr_score1_addr <= mod_score;
							2 : curr_score2_addr <= mod_score;
							3 : curr_score3_addr <= mod_score;
							4 : curr_score4_addr <= mod_score;
							default : curr_score0_addr <= mod_score;
						endcase
						curr_score_copy = curr_score_copy/10;
					end
				end
				curr_score <= curr_score + 1;
			end
		end
	end

	// update high score
	always @(posedge game_over) begin
		if (curr_score > high_score) begin
			high_score <= curr_score;
			high_score0_addr <= curr_score0_addr;
			high_score1_addr <= curr_score1_addr;
			high_score2_addr <= curr_score2_addr;
			high_score3_addr <= curr_score3_addr;
			high_score4_addr <= curr_score4_addr;
		end
	end

	// update image offset
	always @(posedge clk25 or posedge reset) begin
		if (reset | screenEnd) begin
			offset <= 13'd0;
			cacti_offset <= 13'd0;
			curr_score0_offset <= 13'd0;
			curr_score1_offset <= 13'd0;
			curr_score2_offset <= 13'd0;
			curr_score3_offset <= 13'd0;
			curr_score4_offset <= 13'd0;
			high_score0_offset <= 13'd0;
			high_score1_offset <= 13'd0;
			high_score2_offset <= 13'd0;
			high_score3_offset <= 13'd0;
			high_score4_offset <= 13'd0;
			gameover_offset <= 14'd0;
		end
		else begin
			if (dinoSquare) begin
				offset <= offset+1;
			end
			if (cactiSquare) begin
				cacti_offset <= cacti_offset+1;
			end
			if (currScore0Square) begin
				curr_score0_offset <= curr_score0_offset+1;
			end
			if (currScore1Square) begin
				curr_score1_offset <= curr_score1_offset+1;
			end
			if (currScore2Square) begin
				curr_score2_offset <= curr_score2_offset+1;
			end
			if (currScore3Square) begin
				curr_score3_offset <= curr_score3_offset+1;
			end
			if (currScore4Square) begin
				curr_score4_offset <= curr_score4_offset+1;
			end
			if (highScore0Square) begin
				high_score0_offset <= high_score0_offset+1;
			end
			if (highScore1Square) begin
				high_score1_offset <= high_score1_offset+1;
			end
			if (highScore2Square) begin
				high_score2_offset <= high_score2_offset+1;
			end
			if (highScore3Square) begin
				high_score3_offset <= high_score3_offset+1;
			end
			if (highScore4Square) begin
				high_score4_offset <= high_score4_offset+1;
			end
			if (gameoverSquare) begin
				gameover_offset <= gameover_offset+1;
			end
		end
	end
	
	// update on screenEnd
	assign cacti_update = (cacti_x < 10) ? 550 : cacti_x-1;
	always @(posedge screenEnd or posedge reset) begin
		// screen divider clock
		screenEndDivider <= screenEndDivider + 1;
		// scroll cactus
		if (reset) begin
			cacti_x <= 550;
		end
		else begin
			if (~game_over & game_on) begin
				cacti_x <= cacti_update;
			end
		end
	end

	/************ RAM FILES ************/
	// DINO
	RAM #(
		.DEPTH(60*60*3), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		       // either 1 or 0
		.ADDRESS_WIDTH(13),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "dino.mem"}))  // Memory initialization
	DinoData(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(13'd0 + offset),					       // Address from the ImageData RAM
		.dataOut(dino_data),				       // 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading
	
	// CACTI
	RAM #(
		.DEPTH(49*80),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(13),
		.MEMFILE({FILES_PATH, "cacti.mem"}))
	CactiData(
		.clk(clk),
		.addr(13'd0 + cacti_offset),
		.dataOut(cacti_data),
		.wEn(1'b0));

	// BACKGROUND
	RAM #(
		.DEPTH(PIXEL_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "background.mem"}))
	ImageData(
		.clk(clk),
		.addr(imgAddress),
		.dataOut(background_data),
		.wEn(1'b0));
	
	// CURR SCORE
	// score[4]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	CurrScore4Data(
		.clk(clk),
		.addr(curr_score4_addr*25*25 + curr_score4_offset),
		.dataOut(curr_score4_data),
		.wEn(1'b0));
	// score[3]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	CurrScore3Data(
		.clk(clk),
		.addr(curr_score3_addr*25*25 + curr_score3_offset),
		.dataOut(curr_score3_data),
		.wEn(1'b0));
	// score[2]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	CurrScore2Data(
		.clk(clk),
		.addr(curr_score2_addr*25*25 + curr_score2_offset),
		.dataOut(curr_score2_data),
		.wEn(1'b0));
	// score[1]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	CurrScore1Data(
		.clk(clk),
		.addr(curr_score1_addr*25*25 + curr_score1_offset),
		.dataOut(curr_score1_data),
		.wEn(1'b0));
	// score[0]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	CurrScore0Data(
		.clk(clk),
		.addr(curr_score0_addr*25*25 + curr_score0_offset),
		.dataOut(curr_score0_data),
		.wEn(1'b0));

	// HIGH SCORE
	// score[4]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	HighScore4Data(
		.clk(clk),
		.addr(high_score4_addr*25*25 + high_score4_offset),
		.dataOut(high_score4_data),
		.wEn(1'b0));
	// score[3]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	HighScore3Data(
		.clk(clk),
		.addr(high_score3_addr*25*25 + high_score3_offset),
		.dataOut(high_score3_data),
		.wEn(1'b0));
	// score[2]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	HighScore2Data(
		.clk(clk),
		.addr(high_score2_addr*25*25 + high_score2_offset),
		.dataOut(high_score2_data),
		.wEn(1'b0));
	// score[1]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	HighScore1Data(
		.clk(clk),
		.addr(high_score1_addr*25*25 + high_score1_offset),
		.dataOut(high_score1_data),
		.wEn(1'b0));
	// score[0]
	RAM #(
		.DEPTH(25*25*10),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "num.mem"}))
	HighScore0Data(
		.clk(clk),
		.addr(high_score0_addr*25*25 + high_score0_offset),
		.dataOut(high_score0_data),
		.wEn(1'b0));

	// GAME OVER
	RAM #(
		.DEPTH(30*370),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(14),
		.MEMFILE({FILES_PATH, "game_over.mem"}))
	GameOverData(
		.clk(clk),
		.addr(14'd0 + gameover_offset),
		.dataOut(gameover_data),
		.wEn(1'b0));

	/************ VGA OUTPUT CODE ************/
	assign dinoSquare = x >= dino_x & x < (dino_x + 60) & y >= dino_y & y < (dino_y + 60);
	assign cactiSquare = x >= cacti_x & x < (cacti_x + 49) & y >= cacti_y & y < (cacti_y + 80);
	assign currScore0Square = x >= curr_score0_x & x < (curr_score0_x + 25) & y >= score_y & y < (score_y + 25);
	assign currScore1Square = x >= curr_score1_x & x < (curr_score1_x + 25) & y >= score_y & y < (score_y + 25);
	assign currScore2Square = x >= curr_score2_x & x < (curr_score2_x + 25) & y >= score_y & y < (score_y + 25);
	assign currScore3Square = x >= curr_score3_x & x < (curr_score3_x + 25) & y >= score_y & y < (score_y + 25);
	assign currScore4Square = x >= curr_score4_x & x < (curr_score4_x + 25) & y >= score_y & y < (score_y + 25);
	assign highScore0Square = x >= high_score0_x & x < (high_score0_x + 25) & y >= score_y & y < (score_y + 25);
	assign highScore1Square = x >= high_score1_x & x < (high_score1_x + 25) & y >= score_y & y < (score_y + 25);
	assign highScore2Square = x >= high_score2_x & x < (high_score2_x + 25) & y >= score_y & y < (score_y + 25);
	assign highScore3Square = x >= high_score3_x & x < (high_score3_x + 25) & y >= score_y & y < (score_y + 25);
	assign highScore4Square = x >= high_score4_x & x < (high_score4_x + 25) & y >= score_y & y < (score_y + 25);
	assign gameoverSquare = game_over & (x >= gameover_x & x < (gameover_x + 370) & y >= gameover_y & y < (gameover_y + 30));

	assign currScoreData = (currScore0Square & curr_score0_data) | (currScore1Square & curr_score1_data) | (currScore2Square & curr_score2_data) | (currScore3Square & curr_score3_data) | (currScore4Square & curr_score4_data);
	assign highScoreData = (highScore0Square & high_score0_data) | (highScore1Square & high_score1_data) | (highScore2Square & high_score2_data) | (highScore3Square & high_score3_data) | (highScore4Square & high_score4_data);
	assign colorData = background_data ? 12'd0 : 12'hfff;
	assign tempColor = (dinoSquare & dino_data) | (cactiSquare & cacti_data) | currScoreData | highScoreData | (gameoverSquare & gameover_data) ? 12'd0 : colorData;
	assign colorOut = active ? tempColor : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;

	/************ START AND END GAME ************/
	dffe_ref STARTGAME(game_on, up, clk, ~game_on, reset);
	dffe_ref COLLISION(game_over, ((dinoSquare & dino_data) & (cactiSquare & cacti_data)), clk, ~game_over, reset);

endmodule
