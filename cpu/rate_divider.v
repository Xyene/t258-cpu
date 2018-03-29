module rate_divide(
	input clk,
	input resetn,
	output reg out_clk
);
	reg[31:0] rate;

	always @(posedge clk, negedge resetn) begin
		if (!resetn)
			rate <= 32'd0;
		else if (rate == 32'd500) begin
			rate <= 32'd0;
			out_clk <= 1'd1;
		end else begin
			rate <= rate + 32'd1;
			out_clk <= 1'd0;
		end
	end
endmodule
