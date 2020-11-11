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
	
	// Lab Memory Files Location
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
	// always @(posedge screenEnd) begin
	// 	screenEndDivider <= screenEndDivider + 1;
	// end

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
		GROUND = 335,
		DINO_HANDW = 60,
		CACTI_HEIGHT = 70,
		CACTI_WIDTH = 42,
		SCORE_HANDW = 14'd35;

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData, tempColor; // 12-bit color data at current pixel

	// SCORE
	reg[16:0] curr_score = 0, curr_score_copy = 0;
	reg[13:0] mod_score = 0, score4_addr = 0, score3_addr = 0, score2_addr = 0, score1_addr = 0, score0_addr = 0;

	wire score4_data, score3_data, score2_data, score1_data, score0_data;

	integer i;
	always @(posedge scoreClock) begin
		if (~game_over) begin 
			if (curr_score <= 100000) begin
				curr_score_copy <= curr_score;
				for (i=0; i<5; i=i+1) begin
					mod_score = curr_score_copy%10;
					case(i)
						0 : score0_addr <= mod_score;
						1 : score1_addr <= mod_score;
						2 : score2_addr <= mod_score;
						3 : score3_addr <= mod_score;
						4 : score4_addr <= mod_score;
						default : score0_addr <= mod_score;
					endcase
					curr_score_copy = curr_score_copy/10;
				end
			end
			curr_score <= curr_score + 1;
		end
	end

	// SPRITES CODE
	wire sprite_data, cacti_data, background_data;

	reg[12:0] offset = 0, cacti_offset = 0, score0_offset = 0;

	reg[31:0] score0_x = 595, score0_y = 10;
	reg[31:0] cacti_x = 550, cacti_y = GROUND-CACTI_HEIGHT;
	wire[31:0] cacti_update;
	wire inSquare, cactiSquare, score0Square;

	// count
	always @(posedge clk25 or posedge reset) begin
		if (reset || screenEnd) begin
			offset <= 13'd0;
			cacti_offset <= 13'd0;
			score0_offset <= 13'd0;
		end
		else begin
			if (inSquare) begin
				offset <= offset+1;
			end
			if (cactiSquare) begin
				cacti_offset <= cacti_offset+1;
			end
			if (score0Square) begin
				score0_offset <= score0_offset+1;
			end
		end
	end
	
	assign cacti_update = (cacti_x < 10) ? 550 : cacti_x-1;
	// move cactus on slower clock
	always @(posedge screenEnd or posedge reset) begin
		screenEndDivider <= screenEndDivider + 1; // screen divider clock
		if (reset) begin
			cacti_x <= 550;
		end
		else begin
			if (~game_over)begin
				cacti_x <= cacti_update;
			end
		end
	end

	// dino
	RAM #(
		.DEPTH(DINO_HANDW*DINO_HANDW*3), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		       // either 1 or 0
		.ADDRESS_WIDTH(13),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "dino.mem"}))  // Memory initialization
	SpritesData(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(13'd0 + offset),					       // Address from the ImageData RAM
		.dataOut(sprite_data),				       // 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading

	// cacti
	RAM #(
		.DEPTH(CACTI_WIDTH*CACTI_HEIGHT), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		       // either 1 or 0
		.ADDRESS_WIDTH(13),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "cacti.mem"}))  // Memory initialization
	CactiData(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(13'd0 + cacti_offset),					// Address from the ImageData RAM
		.dataOut(cacti_data),				// 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading
	
	// background
	RAM #(
		.DEPTH(PIXEL_COUNT), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		           // either 1 or 0
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "background.mem"}))  // Memory initialization
	ImageData(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(imgAddress),					       // Address from the ImageData RAM
		.dataOut(background_data),				       // 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading

	// score[4]
	RAM #(
		.DEPTH(SCORE_HANDW*SCORE_HANDW*10), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		           // either 1 or 0
		.ADDRESS_WIDTH(14),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "num.mem"}))  // Memory initialization
	Score0Data(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(score0_addr*SCORE_HANDW*SCORE_HANDW + score0_offset),					       // Address from the ImageData RAM
		.dataOut(score0_data),				       // 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading
	
	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	wire scoreData;

	assign inSquare = x >= dino_x & x < (dino_x + DINO_HANDW) & y >= dino_y & y < (dino_y + DINO_HANDW);
	assign cactiSquare = x >= cacti_x & x < (cacti_x + CACTI_WIDTH) & y >= cacti_y & y < (cacti_y + CACTI_HEIGHT);
	assign score0Square = x >= score0_x & x < (score0_x + SCORE_HANDW) & y >= score0_y & y < (score0_y + SCORE_HANDW);

	assign scoreData = (score0Square && score0_data); // add 3, 2, 1, 0
	assign colorData = background_data ? 12'd0 : 12'hfff;
	assign tempColor = (inSquare && sprite_data) || (cactiSquare && cacti_data) || scoreData ? 12'd0 : colorData;
	assign colorOut = active ? tempColor : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;

	// dffe_ref COLLISION(game_over, ((inSquare & sprite_data) & (cactiSquare & cacti_data)), clk, ~game_over, 1'b0); //jump works
	dffe_ref COLLISION(game_over, ((inSquare & sprite_data) & (cactiSquare & cacti_data)), clk, ~game_over, reset); //jump doesnt work

endmodule

/*
Sammi
- dino heights
- get score bitmaps
- implement score rams
- get score digit thing

Cathy
- screen shot score and game over pixels
- animate dino run
- detect collisions (test by using led)
- send in game over as a input to processor and regfile to disable dino height on game over (wren = ~gameover)


*/
