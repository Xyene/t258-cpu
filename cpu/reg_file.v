`include "const.vh"

module registers(
	input clk, resetn, reg_bus_mode,
	input[2:0] reg_sel_1, reg_sel_2, rel_sel_out,
	input[15:0] reg_write_data,
	output[15:0] reg_data_1, reg_data_2,
	output reg[17:0] LEDR
);
	// The internal registers of the register file
	reg[15:0] register [7:0];

	integer i;

	always @(negedge clk, negedge resetn)
	begin
		// Clear each register
		if (!resetn) begin 
			LEDR <= 18'd0;
			for (i = 0; i < 8; i = i + 1) 
				begin
					register[i] <= 16'd0;
				end
		end else if (reg_bus_mode == `MODE_WRITE) begin
			register[rel_sel_out] <= reg_write_data;
			// DON'T TAKE THIS OUT, FOR SOME REASON REMOVING THIS
			// CAUSES THE JUMP INSTRUCTION TO NOT EXECUTE THE INSTRUCTION IT JUMPS TO
			// (SO YOU HAVE TO JUMP TO ADDR - 1)
			//
			// Timing is probably wrong somewhere :'(
			LEDR[10:0] <= reg_write_data[10:0];
			LEDR[17:14] <= rel_sel_out;
		end
	end
	// If not writing, have the output registers update
	assign reg_data_1 = register[reg_sel_1];
	assign reg_data_2 = register[reg_sel_2];
endmodule
