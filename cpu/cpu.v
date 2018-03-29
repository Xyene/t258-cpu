module program(input CLOCK_50,
			   input[17:0] SW,
			   input[3:0] KEY,
			   output[7:0] LEDG,
			   output[17:0] LEDR,
			   output[6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
			   output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
			   output[9:0] VGA_R, VGA_G, VGA_B
);
	// Register file controls
	wire reg_bus_mode;
	wire[3:0] reg_sel_1, reg_sel_2, reg_sel_out;
	wire[15:0] reg_data_out_1, reg_data_out_2, reg_write_data;
	
	// ALU controls
	wire[3:0] alu_op;
	wire[15:0] alu_out;

	// RAM/VRAM controls; memory is shared so both modules get this data
	// (and decide themselves what to do with it)
	wire[15:0] ram_addr, ram_write_data, ram_read_data;
	wire ram_bus_mode;
	
	// ROM controls; rom_addr comes from the program counter
	wire[15:0] rom_addr, rom_data;
	
	// Program counter controls
	wire do_jump, pc_inc_enable;
	wire[15:0] jmp_target;

	// Stack pointer controls
	wire[15:0] stack_ptr;	
	wire sp_inc_enable, sp_dec_enable;

	// Unfortunately, the FSM is too slow to run reliably at 50MHz, so here we scale it down to 10MHz...
	// This can cause problems with propagation delays, but it runs fine for now.
	wire clk;
	rate_divide d0(CLOCK_50, KEY[0], clk); 
	//assign clk = KEY[3];

	RAM ram(clk, KEY[0], ram_bus_mode, ram_addr, ram_write_data, ram_read_data, LEDG);

	VRAM vram(
	    ram_bus_mode,
		CLOCK_50, // The VGA has to take the 50MHz clock, not the 10MHz scaled one
		KEY[0],
		ram_addr,
		ram_write_data[11:0], // 12-bit color, take lowest 12 bits
		VGA_CLK,   	
		VGA_HS,		
		VGA_VS,		
		VGA_BLANK_N,
		VGA_SYNC_N,	
		VGA_R,   	
		VGA_G,	 	
		VGA_B   	
	);
	
	ROM rom(rom_addr, rom_data);
	
	registers r0(clk, KEY[0], reg_bus_mode,
	             reg_sel_1, reg_sel_2, reg_sel_out, reg_write_data,
				 reg_data_out_1, reg_data_out_2, LEDR);
	
	stack_pointer sp0(clk, KEY[0], sp_inc_enable, sp_dec_enable, stack_ptr);
	program_counter p0(clk, KEY[0], do_jump, pc_inc_enable, jmp_target, rom_addr);


	ALU alu(reg_data_out_1, reg_data_out_2, alu_op, alu_out);

	control cpu(clk,
			   KEY[0],
			   // Stack controls
			   stack_ptr,
			   sp_inc_enable, sp_dec_enable,
			   // Program counter controls
			   jmp_target,
			   do_jump, pc_inc_enable,
			   // Register file controls
			   reg_data_out_1, reg_data_out_2,
			   reg_sel_1, reg_sel_2, reg_sel_out,
			   reg_write_data,
			   reg_bus_mode,
			   // ALU controls
			   alu_out,
			   alu_op,
			   // ROM controls
			   rom_data, rom_addr,
			   // RAM controls
			   ram_read_data,
			   ram_write_data,
			   ram_addr,
			   ram_bus_mode);
  
	// ROM address
  	hex_decoder h7(rom_addr[7:4], HEX7);
	hex_decoder h6(rom_addr[3:0], HEX6);
	
	// Register selector bits of instruction
	hex_decoder h5(rom_data[15:13], HEX5);	
	hex_decoder h4(rom_data[12:10], HEX4);

	// Full instruction
	hex_decoder h3(rom_data[15:12], HEX3);
	hex_decoder h2(rom_data[11:8], HEX2);
	hex_decoder h1(rom_data[7:4], HEX1);
	hex_decoder h0(rom_data[3:0], HEX0);
endmodule
