module program_counter(
	input clk, resetn, do_jump, pc_inc_enable,
	input[15:0] jump_target_address,
	output reg[15:0] out_pc
);
	always @(posedge clk, negedge resetn)
	begin
		if(!resetn)
			out_pc <= 16'b0;
		else begin 
			if (do_jump)
				out_pc <= jump_target_address;
			else if (pc_inc_enable)
				out_pc <= out_pc + 16'd1;
		end
	end
endmodule
