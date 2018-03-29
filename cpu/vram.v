module VRAM(input plot, input clk, input resetn, input[15:0] buf_pos, input[11:0] colour,
			// The ports below are for the VGA output.  Do not change.
			output			VGA_CLK,   						//	VGA Clock
			output			VGA_HS,							//	VGA H_SYNC
			output			VGA_VS,							//	VGA V_SYNC
			output			VGA_BLANK_N,						//	VGA BLANK
			output			VGA_SYNC_N,						//	VGA SYNC
			output	[9:0]	VGA_R,   						//	VGA Red[9:0]
			output	[9:0]	VGA_G,	 						//	VGA Green[9:0]
			output	[9:0]	VGA_B   						//	VGA Blue[9:0]
);	
		// Create the colour, x, y and writeEn wires that are inputs to the controller.
	//wire [2:0] colour = 3'b100; //3'b101; //ram_write_data[2:0];
	wire writeEn = plot;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(colour),
			.buf_pos(buf_pos),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule
