`include "const.vh"

module control(
	input clock,
	input resetn,
	
	// Stack pointer controls
	input[15:0] stack_pointer,
	output reg sp_inc_enable, sp_dec_enable,
	
	// Program counter controls
	output reg[15:0] jmp_addr,
	output reg do_jump, pc_inc_enable,
	
	// Register file controls
	input[15:0] reg_data_out_1, reg_data_out_2,
	output reg[2:0] reg_sel_1, reg_sel_2, reg_sel_out,
	output reg[15:0] reg_write_data,
	output reg reg_bus_mode,
	
	// ALU controls
	input[15:0] alu_out,
	output reg[3:0] alu_op,
	
	// ROM controls
	input[15:0] rom_data, rom_addr,
	
	// RAM controls
	input[15:0] ram_read_data,
	output reg[15:0] ram_write_data,
	output reg[15:0] ram_addr,
	output reg ram_bus_mode
);
	reg [15:0] opcode_1, opcode_2;
	reg [2:0] current_state, next_state;
	reg is_2_cycle;
	reg take_c_jump;

	always @(*)
	begin
		opcode_1 = rom_data;
		is_2_cycle = (rom_data[`OP] == `OP_JMP) || 
		             (rom_data[`OP] == `OP_JEQ) ||
		             (rom_data[`OP] == `OP_JLE) ||
					 (rom_data[`OP] == `OP_LD_MEM_TO_REG) ||
					 (rom_data[`OP] == `OP_PUSH_REG) ||
					 (rom_data[`OP] == `OP_PUSH_CONST) ||
					 (rom_data[`OP] == `OP_LD_CONST_TO_REG) ||
					 (rom_data[`OP] == `OP_POP_REG) ||
					 (rom_data[`OP] == `OP_LD_REG_TO_MEM)
					 ;
		// Next state
		case (current_state)
			`STATE_START: 		next_state = `STATE_I_CYCLE_1;
			`STATE_I_CYCLE_1:	next_state = is_2_cycle ? `STATE_I_CYCLE_2 : `STATE_I_CYCLE_1;
			`STATE_I_CYCLE_2:	next_state = do_jump ? `STATE_I_CYCLE_3 : `STATE_I_CYCLE_1;
			`STATE_I_CYCLE_3:	next_state = `STATE_I_CYCLE_1;
			`STATE_HALT:		next_state = `STATE_HALT;
		endcase
	end

	// Signals out
	always @(posedge clock, negedge resetn)
	begin
	   // FIXME: generated combinational??
		// ram_bus_mode <= `MODE_READ;
		// reg_bus_mode <= `MODE_READ;
		// ram_addr <= 16'b0;
		// ram_write_data <= 16'b0;
		// reg_write_data <= 16'b0;
		// reg_sel_1 <= 3'b0;
		// reg_sel_2 <= 3'b0;
		// reg_sel_out <= 3'b0;
		// alu_op <= 4'b0;
		case (current_state)
			`STATE_I_CYCLE_1: begin // Top kek there's definitely a cleaner way of handling this		
				ram_bus_mode <= `MODE_READ;
				reg_bus_mode <= `MODE_READ;
				do_jump <= 0;
				pc_inc_enable <= 1;
				opcode_2 <= rom_data;
				reg_sel_1 <= opcode_1[`R0];
				reg_sel_2 <= opcode_1[`R1];
				reg_sel_out <= opcode_1[`R0];
				sp_inc_enable <= 0;
				sp_dec_enable <= 0;
	
				case(opcode_1[`OP])
					`OP_PUSH_REG: begin
						pc_inc_enable <= 0;
						sp_inc_enable <= 1;
					end
					`OP_PUSH_CONST: begin
						pc_inc_enable <= 1;
						sp_inc_enable <= 1;
					end
					`OP_POP_REG: begin
						pc_inc_enable <= 0;
						sp_dec_enable <= 1;
						ram_addr <= stack_pointer; //16'd500; //`STACK_BASE + stack_pointer;
						reg_bus_mode <= `MODE_WRITE;
						reg_sel_out <= opcode_2[`R0];
						reg_write_data <= ram_read_data;
					end
					`OP_INC: begin
						alu_op <= `ALU_OP_INC;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_DEC: begin
						alu_op <= `ALU_OP_DEC;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_ADD: begin
						alu_op <= `ALU_OP_ADD;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_SUB: begin
						alu_op <= `ALU_OP_SUB;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_MUL: begin
						alu_op <= `ALU_OP_MUL;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_OR: begin
						alu_op <= `ALU_OP_OR;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_AND: begin
						alu_op <= `ALU_OP_AND;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_XOR: begin
						alu_op <= `ALU_OP_XOR;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_CMP: begin
						alu_op <= `ALU_OP_CMP;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= alu_out;
					end
					`OP_LD_REG_TO_REG: begin
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= reg_data_out_2;
					end
					// LD r0, (r1)
					`OP_LD_MEM_TO_REG: begin
						ram_addr <= reg_data_out_2;
						pc_inc_enable <= 0;
					end
					// LD (r0), r1
					`OP_LD_REG_TO_MEM: begin
						pc_inc_enable <= 0;
						ram_bus_mode <= `MODE_WRITE;
						ram_addr <= reg_data_out_1;
						ram_write_data <= reg_data_out_2;
						//is_2_cycle <= 1;
					end					
					`OP_JEQ: begin
						alu_op <= `ALU_OP_CMP;
						take_c_jump <= alu_out;
					end
					`OP_JLE: begin
						alu_op <= `ALU_OP_LESSTHAN;
						take_c_jump <= alu_out;
					end
					`OP_NOP: begin
					end
					default: begin
						// All other instructions take a second constant operand
					end
				endcase
			end
			`STATE_I_CYCLE_2: begin
				// Disable RAM and register updates here, otherwise
				// they get trashed for some reason during the jump
				ram_bus_mode <= `MODE_READ;
				reg_bus_mode <= `MODE_READ;
				do_jump <= 0;
				sp_inc_enable <= 0;
				sp_dec_enable <= 0;
						
				is_3_cycle <= 0;
				reg_sel_1 <= opcode_2[`R0];
				reg_sel_2 <= opcode_2[`R1];
				reg_sel_out <= opcode_2[`R0];

				case(opcode_2[`OP])
					`OP_LD_CONST_TO_REG: begin
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= rom_data;
					end
					`OP_PUSH_CONST: begin
						ram_bus_mode <= `MODE_WRITE;
						ram_addr <= stack_pointer;
						ram_write_data <= rom_data;
					end
					`OP_PUSH_REG: begin
						pc_inc_enable <= 1;
						ram_bus_mode <= `MODE_WRITE;
						ram_addr <= stack_pointer;
						ram_write_data <= reg_data_out_1;
					end
					`OP_POP_REG: begin
						pc_inc_enable <= 1;
					end
					`OP_LD_REG_TO_MEM: begin
						pc_inc_enable <= 1;
					end
					`OP_LD_MEM_TO_REG: begin
						pc_inc_enable <= 1;
						reg_bus_mode <= `MODE_WRITE;
						reg_write_data <= ram_read_data;
					end
					`OP_JMP: begin
						do_jump <= 1;
						jmp_addr <= rom_data - 16'd1;
					end
					`OP_JEQ: begin
						if (take_c_jump)
						begin
							do_jump <= 1;
							jmp_addr <= rom_data - 16'd1;
						end
					end
					
					`OP_JLE: begin
						if (take_c_jump)
						begin
							do_jump <= 1;
							jmp_addr <= rom_data - 16'd1;
						end
					end
					default: begin
					end
				endcase
			end			
			`STATE_I_CYCLE_3: begin
				ram_bus_mode <= `MODE_READ;
				reg_bus_mode <= `MODE_READ;
				do_jump <= 0;
				//stack_pointer <= 16'd1;
			end
			
			default: begin
				ram_bus_mode <= `MODE_READ;
				reg_bus_mode <= `MODE_READ;
				do_jump <= 0;
			end
		endcase

		// Change state
		if (!resetn) begin
			current_state <= `STATE_START;
			{reg_write_data, ram_write_data, ram_addr, jmp_addr, opcode_2} <= 16'b0;
			{alu_op, reg_sel_1, reg_sel_2, reg_sel_out} <= 3'b0;
			{ram_bus_mode, reg_bus_mode, do_jump, pc_inc_enable} <= 1'b0;
		end else begin
			current_state <= next_state;
		end
	end
endmodule
