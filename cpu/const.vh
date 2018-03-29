`define ALU_OP_INC		4'd0
`define ALU_OP_DEC		4'd1
`define ALU_OP_ADD		4'd2
`define ALU_OP_SUB		4'd3
`define ALU_OP_MUL		4'd4
`define ALU_OP_OR		4'd5
`define ALU_OP_AND		4'd6
`define ALU_OP_XOR		4'd7
`define ALU_OP_CMP		4'd8
`define ALU_OP_LD		4'd9
`define ALU_OP_LESSTHAN	4'd10

`define MODE_READ 	0
`define MODE_WRITE 	1

`define OP_NOP					8'b0000_0000
`define OP_INC					8'b1000_0001  // 1
`define OP_DEC					8'b1000_0010  // 2
`define OP_ADD					8'b1000_0011  // 3
`define OP_SUB					8'b1000_0101  // 5
`define OP_MUL					8'b1000_0111  // 7
`define OP_OR					8'b1000_1000  // 9
`define OP_AND					8'b1000_1001  // B
`define OP_XOR					8'b1000_1010  // D
`define OP_CMP					8'b1000_1011  // F
`define OP_PUSH_REG				8'b1000_1100  // 008C
`define OP_PUSH_CONST			8'b1000_1101
`define OP_POP_REG				8'b1000_1110
`define OP_POP_CONST			8'b1000_1111
`define OP_JEQ					8'b1001_0000
`define OP_JLE					8'b1001_0001
`define OP_JMP					8'b1001_0010
`define OP_LD_REG_TO_REG		8'b1001_0011
`define OP_LD_MEM_TO_REG		8'b1001_0100
`define OP_LD_REG_TO_MEM		8'b1001_0101
`define OP_LD_CONST_TO_REG		8'b1001_0110

`define STATE_START			4'd1
`define STATE_I_CYCLE_1		4'd2
`define STATE_I_CYCLE_2		4'd3
`define STATE_I_CYCLE_3		4'd4
`define STATE_SP_INC		4'd5
`define STATE_HALT			4'd6


`define STACK_BASE			16'h4C00

`define R0	15:13
`define R1	12:10
`define OP	7:0