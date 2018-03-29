module stack_pointer(
	input clk, resetn, increment, decrement, output[15:0] out_sp
);
	reg[15:0] stack_ptr;

	always @(posedge clk, negedge resetn)
	begin
		if (!resetn) 
			stack_ptr = 16'd0;
		else if (increment) 
			stack_ptr <= stack_ptr + 16'd1;
		else if (decrement)
			stack_ptr <= stack_ptr - 16'd1;
	end
	assign out_sp = stack_ptr;
endmodule
