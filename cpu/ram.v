`include "const.vh"

module RAM(input clk, input resetn, input ram_bus_mode, input[15:0] ram_addr,
           input[15:0] ram_write_data, output[15:0] ram_read_data, output reg[7:0] LEDG
);
	// This module is just a nice wrapper around a 1K RAM block so we can display what's
	// being written on the green LEDs
	ram1k block_ram (
		ram_addr[9:0],
		clk,
		ram_write_data,
		ram_bus_mode,
		ram_read_data
	);
	
	always @(negedge clk, negedge resetn)
	begin
		if (!resetn) begin 
			LEDG <= 8'd128;
		end	else if (ram_bus_mode == `MODE_WRITE) begin
			LEDG[7:0] <= ram_write_data[7:0];
		end
	end
endmodule



