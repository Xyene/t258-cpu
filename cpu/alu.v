`include "const.vh"

module ALU(
	input[15:0] a, b,
	input[3:0] alu_op,
	output reg[15:0] alu_out
);

	always @(*)
	begin
		case(alu_op)
			`ALU_OP_INC: 		alu_out 	= a + 15'b1;
			`ALU_OP_DEC: 		alu_out 	= a - 15'b1;
			`ALU_OP_ADD: 		alu_out 	= a + b;
			`ALU_OP_SUB: 		alu_out 	= a - b;
			`ALU_OP_MUL: 		alu_out 	= a * b;
			`ALU_OP_OR:  		alu_out 	= a | b;
			`ALU_OP_AND: 		alu_out 	= a & b;
			`ALU_OP_XOR: 		alu_out 	= a ^ b;
			`ALU_OP_CMP: 		alu_out 	= {15'b0, a == b};
			`ALU_OP_LD:  		alu_out 	= b;
			`ALU_OP_LESSTHAN: 	alu_out	 	= {15'b0, a <= b};
			default:		 	alu_out		= 16'b0;
		endcase
	end
endmodule
