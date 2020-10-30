`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data,
	input left, right, up, down);
	
	// Lab Memory Files Location
	localparam FILES_PATH = "Z:/cpu/ECE350_Dino/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
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
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData, tempColor; // 12-bit color data at current pixel

	// SPRITES CODE
	wire sprite_data, background_data;

	reg[12:0] offset = 0;

	reg[31:0] sx = 320, sy = 240;
	wire inSquare;

	// count
	always @(posedge clk25 or posedge reset) begin
		if (reset || screenEnd) begin
			offset <= 13'd0;
		end
		else if (inSquare) begin
			offset <= offset+1;
		end
	end
	
	// dino
	RAM #(
		.DEPTH(75*75), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		       // either 1 or 0
		.ADDRESS_WIDTH(13),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "dino.mem"}))  // Memory initialization
	SpritesData(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(0 + offset),					       // Address from the ImageData RAM
		.dataOut(sprite_data),				       // 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading
	
	// background
	RAM #(
		.DEPTH(PIXEL_COUNT), 		       // sprite mem file size		
		.DATA_WIDTH(1), 		       // either 1 or 0
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "background.mem"}))  // Memory initialization
	ImageData(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(imgAddress),					       // Address from the ImageData RAM
		.dataOut(background_data),				       // 1 or 0 at current address
		.wEn(1'b0)); 						       // We're always reading
	

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 

	// input left, right, up, down;
	always @(posedge clk) begin
		if (screenEnd) begin
			if (left) begin
				sx <= sx - 1;
			end
			else if (right) begin
				sx <= sx + 1;
			end
			if (up) begin
				sy <= sy - 1;
			end
			else if (down) begin
				sy <= sy + 1;
			end
		end
	end
    
	assign inSquare = x >= sx & x < (sx + 75) & y >= sy & y < (sy + 75);
	assign colorData = background_data ? 12'd0 : 12'hfff;
	assign tempColor = (inSquare && sprite_data) ? 12'd0 : colorData;
		assign colorOut = active ? tempColor : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule
