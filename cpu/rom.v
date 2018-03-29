module ROM(input[15:0] rom_addr, output[15:0] rom_data);
  reg[15:0] DATA[1023:0];
  assign rom_data = DATA[rom_addr];

  initial
    begin
        DATA[ 1] = 16'h008D;    // 0D
        DATA[ 2] = 16'h0004;    // 04
        DATA[ 3] = 16'hE08E;    // 0E
        DATA[ 4] = 16'h008D;    // 0D
        DATA[ 5] = 16'h000C;    // 0C
        DATA[ 6] = 16'h808E;    // 0E
        DATA[ 7] = 16'h0081;    // 01
        DATA[ 8] = 16'h2081;    // 01
        DATA[ 9] = 16'h008D;    // 0D
        DATA[10] = 16'h00A0;    // 20
        DATA[11] = 16'hA08E;    // 0E
        DATA[12] = 16'h4493;    // 13
        DATA[13] = 16'h2083;    // 03
        DATA[14] = 16'h0893;    // 13
        DATA[15] = 16'h488A;    // 0A
        DATA[16] = 16'h4081;    // 01
        DATA[17] = 16'h4491;    // 11
        DATA[18] = 16'h0019;    // 19
        DATA[19] = 16'h008D;    // 0D
        DATA[20] = 16'h0FFF;    // 3F
        DATA[21] = 16'hE08E;    // 0E
        DATA[22] = 16'hBC95;    // 15
        DATA[23] = 16'h0092;    // 12
        DATA[24] = 16'h001D;    // 1D
        DATA[25] = 16'h008D;    // 0D
        DATA[26] = 16'h0F00;    // 00
        DATA[27] = 16'hE08E;    // 0E
        DATA[28] = 16'hBC95;    // 15
        DATA[29] = 16'hA081;    // 01
        DATA[30] = 16'hC081;    // 01
        DATA[31] = 16'h008D;    // 0D
        DATA[32] = 16'h00A0;    // 20
        DATA[33] = 16'hE08E;    // 0E
        DATA[34] = 16'hDC90;    // 10
        DATA[35] = 16'h0026;    // 26
        DATA[36] = 16'h0092;    // 12
        DATA[37] = 16'h002B;    // 2B
        DATA[38] = 16'h008D;    // 0D
        DATA[39] = 16'h00A0;    // 20
        DATA[40] = 16'hE08E;    // 0E
        DATA[41] = 16'hBC83;    // 03
        DATA[42] = 16'hD88A;    // 0A
        DATA[43] = 16'h4491;    // 11
        DATA[44] = 16'h0010;    // 10
        DATA[45] = 16'h008D;    // 0D
        DATA[46] = 16'h01E0;    // 20
        DATA[47] = 16'hE08E;    // 0E
        DATA[48] = 16'hBC83;    // 03
        DATA[49] = 16'hB885;    // 05
        DATA[50] = 16'hD88A;    // 0A
        DATA[51] = 16'h6081;    // 01
        DATA[52] = 16'h7091;    // 11
        DATA[53] = 16'h000C;    // 0C
        DATA[54] = 16'h008D;    // 0D
        DATA[55] = 16'h000A;    // 0A
        DATA[56] = 16'h008E;    // 0E
        DATA[57] = 16'h008D;    // 0D
        DATA[58] = 16'h0046;    // 06
        DATA[59] = 16'h208E;    // 0E
        DATA[60] = 16'h008D;    // 0D
        DATA[61] = 16'h0000;    // 00
        DATA[62] = 16'h608E;    // 0E
        DATA[63] = 16'hA493;    // 13
        DATA[64] = 16'h008D;    // 0D
        DATA[65] = 16'h00A0;    // 20
        DATA[66] = 16'hE08E;    // 0E
        DATA[67] = 16'hBC87;    // 07
        DATA[68] = 16'hA083;    // 03
        DATA[69] = 16'h008D;    // 0D
        DATA[70] = 16'h0000;    // 00
        DATA[71] = 16'hE08E;    // 0E
        DATA[72] = 16'h7C90;    // 10
        DATA[73] = 16'h005A;    // 1A
        DATA[74] = 16'h008D;    // 0D
        DATA[75] = 16'h0000;    // 00
        DATA[76] = 16'h408E;    // 0E
        DATA[77] = 16'hA895;    // 15
        DATA[78] = 16'h008D;    // 0D
        DATA[79] = 16'h000A;    // 0A
        DATA[80] = 16'hC08E;    // 0E
        DATA[81] = 16'h0082;    // 02
        DATA[82] = 16'hA082;    // 02
        DATA[83] = 16'hC091;    // 11
        DATA[84] = 16'h0068;    // 28
        DATA[85] = 16'h008D;    // 0D
        DATA[86] = 16'h0000;    // 00
        DATA[87] = 16'h608E;    // 0E
        DATA[88] = 16'h0092;    // 12
        DATA[89] = 16'h0068;    // 28
        DATA[90] = 16'h008D;    // 0D
        DATA[91] = 16'h0F00;    // 00
        DATA[92] = 16'h408E;    // 0E
        DATA[93] = 16'hA895;    // 15
        DATA[94] = 16'h008D;    // 0D
        DATA[95] = 16'h0046;    // 06
        DATA[96] = 16'hC08E;    // 0E
        DATA[97] = 16'h0081;    // 01
        DATA[98] = 16'hA081;    // 01
        DATA[99] = 16'h1891;    // 11
        DATA[100] = 16'h0068;   // 28
        DATA[101] = 16'h008D;   // 0D
        DATA[102] = 16'h0001;   // 01
        DATA[103] = 16'h608E;   // 0E
        DATA[104] = 16'h008D;   // 0D
        DATA[105] = 16'h0FFF;   // 3F
        DATA[106] = 16'h408E;   // 0E
        DATA[107] = 16'hA895;   // 15
        DATA[108] = 16'h008D;   // 0D
        DATA[109] = 16'h012C;   // 2C
        DATA[110] = 16'hC08E;   // 0E
        DATA[111] = 16'hFC8A;   // 0A
        DATA[112] = 16'hC082;   // 02
        DATA[113] = 16'hDC90;   // 10
        DATA[114] = 16'h0075;   // 35
        DATA[115] = 16'h0092;   // 12
        DATA[116] = 16'h0070;   // 30
        DATA[117] = 16'h0092;   // 12
        DATA[118] = 16'h003F;   // 3F
        DATA[119] = 16'h0092;   // 12
        DATA[120] = 16'h0077;   // 37
    end
endmodule

/*
INC r0
INC r1
INC r3
INC r3
INC r3
INC r3

fib_start:
	LD (r5), r0
	LD r2, r1
	ADD r1, r0
	LD r0, r2
	INC r4
	JEQ r3 r4 start_stall
	JMP fib_start

start_stall:
INC r7
JMP start_stall
*/