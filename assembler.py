import sys
from collections import defaultdict

'''	
1		INC r0				r0++
2		DEC r0				r0--
3		ADD r0, r1			r0 += r1
5		SUB r0, r1			r0 -= r1
7		MUL r0, r1			r0 *= r1
9		OR r0, r1			r0 |= r1
B		AND r0, r1			r0 &= r1
D		XOR r0, r1			r0 ^= r1
F		CMP r0, r1			cmp(r0, r1)
11		PUSH r0				sp++; ram[0x9000 + sp] = r0
12		PUSH @const		 	sp++; ram[0x9000 + sp] = @const
13		POP r0				r0 = ram[0x9000 + sp]; sp--;
14		POP @const			r0 = ram[0x9000 + sp]; sp--;
15		JEQ @const			pc = Z ? @const : pc
16		JLE @const			pc = N ? pc : @const
17		JMP @const			pc = @const
18		LD r0, r1			r0 = r1
19		LD r0, (r1)		r	r0 = ram[r1]
1B		LD (r0), r1			ram[r0] = r1
'''

OP_INC				=	0b10000001 
OP_DEC				=	0b10000010 
OP_ADD				=	0b10000011 
OP_SUB				=	0b10000101 
OP_MUL				=	0b10000111 
OP_OR				=	0b10001000 
OP_AND				=	0b10001001 
OP_XOR				=	0b10001010 
OP_CMP				=	0b10001011 
OP_PUSH_REG			=	0b10001100
OP_PUSH_CONST		=	0b10001101
OP_POP_REG			=	0b10001110
OP_POP_CONST		=	0b10001111
OP_JEQ				=	0b10010000
OP_JLE				=	0b10010001
OP_JMP				=	0b10010010
OP_LD_REG_TO_REG	=	0b10010011
OP_LD_MEM_TO_REG	=	0b10010100
OP_LD_REG_TO_MEM	=	0b10010101
OP_LD_CONST_TO_REG  = 	0b10010110


class Compiler(object):
	def __init__(self, src):
		self.src = src
		self.prog = []
		self.label_map = {}
		self.label_to_offsets = defaultdict(list)

		self.emit_dispatch = {
			'INC': ([OP_INC], self.emit_unary),
			'DEC': ([OP_DEC], self.emit_unary),
			'ADD': ([OP_ADD], self.emit_alu),
			'SUB': ([OP_SUB], self.emit_alu),
			'MUL': ([OP_MUL], self.emit_alu),
			'OR': ([OP_OR], self.emit_alu),
			'AND': ([OP_AND], self.emit_alu),
			'XOR': ([OP_XOR], self.emit_alu),
			'CMP': ([OP_CMP], self.emit_alu),
			'PUSH': ([OP_PUSH_REG, OP_PUSH_CONST], self.emit_push),
			'POP': ([OP_POP_REG, OP_POP_CONST], self.emit_pop),
			'JEQ': ([OP_JEQ], self.emit_c_jump),
			'JLE': ([OP_JLE], self.emit_c_jump),
			'JGE': ([OP_JLE], self.emit_jge),
			'JMP': ([OP_JMP], self.emit_jump),
			'LD': ([OP_LD_REG_TO_REG, OP_LD_MEM_TO_REG, OP_LD_REG_TO_MEM, OP_LD_CONST_TO_REG], self.emit_load),
			'STACKMAP': ([-1], self.stackmap)
		}

	def parse_line(self, line):
		if ';' in line:
			line = line[:line.index(';')]
		line = line.strip()
		if not line:
			return
		# print line
		tokens = filter(None, (token.strip() for token in line.replace(',', ' ').split(' ')))

		first = tokens[0]

		if first[-1] == ':':
			self.label_map[first[:-1]] = len(self.prog)
		else:
			codes, handler = self.emit_dispatch[first]
			handler(min(codes), *tokens[1:])

	def stackmap(self, base, *args):
		for arg in args:
			# stack frame is zeroed
			self.parse_line('PUSH 0')
		self.stackmap = args

	def emit_push(self, base, op):
		if op[0] == '[':
			# pushing off the stack
			op = op[1:-1]
			pos = self.stackmap.index(op)
			self.parse_line('PUSH ' + str(pos + 0))
			self.parse_line('POP r6')
			self.parse_line('LD r7, (r6)')
			self.parse_line('PUSH r7')
		else:
			if Compiler.is_reg(op):
				self.emit_unary(base, op)
			else:
				self.emit(base + 1)
				self.emit(int(op))

	def emit_pop(self, base, op):
		if op[0] == '[':
			# popping off the stack
			op = op[1:-1]
			pos = self.stackmap.index(op)
			self.parse_line('POP r7')
			self.parse_line('PUSH ' + str(pos + 0))
			self.parse_line('POP r6')
			self.parse_line('LD (r6), r7')
		else:
			if Compiler.is_reg(op):
				self.emit_unary(base, op)
			else:
				self.emit(base + 1)
				self.emit(int(op))

	def emit_load(self, base, a, b):
		if Compiler.is_reg(a):
			if Compiler.is_reg(b):
				self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin(b) << 10) | OP_LD_REG_TO_REG)
			else:
				if b[0] == '(':
					b = b[1:-1]
					self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin(b) << 10) | OP_LD_MEM_TO_REG)
				else:
					self.parse_line('PUSH ' + str(eval(b)))
					self.parse_line('POP ' + a)
		elif a[0] == '(':
			a = a[1:-1]
			if Compiler.is_reg(a):
				if Compiler.is_reg(b):
					self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin(b) << 10) | OP_LD_REG_TO_MEM)
				else:
					self.parse_line('LD r7, ' + str(eval(b)))
					self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin('r7') << 10) | OP_LD_REG_TO_MEM)
			else:
				self.emit((Compiler.reg2bin(b) << 13) | (base + 4))
				self.emit(eval(a))

	def emit_c_jump(self, base, a, b, label):
		if Compiler.is_reg(b):
			self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin(b) << 10) | base)
		else:
			self.parse_line('LD r7, ' + str(eval(b)))
			self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin('r7') << 10) | base)
		self.emit(0x1337)  # temporary, until all labels are resolved
		self.label_to_offsets[label].append(len(self.prog) - 1)
		
	def emit_jge(self, base, a, b, label):
		if Compiler.is_reg(b):
			self.emit((Compiler.reg2bin(b) << 13) | (Compiler.reg2bin(a) << 10) | base)
		else:
			self.parse_line('LD r7, ' + str(eval(b)))
			self.emit((Compiler.reg2bin('r7') << 13) | (Compiler.reg2bin(a) << 10) | base)
		self.emit(0x1337)  # temporary, until all labels are resolved
		self.label_to_offsets[label].append(len(self.prog) - 1)

	def emit_jump(self, base, label):
		self.emit(base)
		self.emit(0x1337)  # temporary, until all labels are resolved
		self.label_to_offsets[label].append(len(self.prog) - 1)

	def emit_unary(self, base, r):
		self.emit((Compiler.reg2bin(r) << 13) | base)

	def emit_alu(self, base, a, b):
		if Compiler.is_reg(b):
			self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin(b) << 10) | base)
		else:
			self.parse_line('LD r7, ' + str(eval(b)))
			self.emit((Compiler.reg2bin(a) << 13) | (Compiler.reg2bin('r7') << 10) | base)
			#self.emit(int(b))

	@classmethod
	def reg2bin(cls, r):
		num = int(r[1])
		assert 0 <= num <= 7
		return num

	@classmethod
	def is_reg(cls, r):
		return r[0] == 'r'

	def emit(self, opcode):
		self.prog.append(opcode)

	def fix_labels(self):
		for label, pos in self.label_map.iteritems():
			for fix in self.label_to_offsets[label]:
				self.prog[fix] = pos + 1

	def to_bin(self, n):
		x = ''.join(str(1 & int(n) >> i) for i in range(16)[::-1])
		return x[0:4] + '_' + x[4:8] + '_' + x[8:12] + '_' + x[12:16]
				
	def compile(self):
		for line in self.src.split('\n'):
			self.parse_line(line)
		self.fix_labels()
		cmp = 'reg[%s:0] DATA[15:0];\n' % (len(c.prog) - 1)
		for i, a in enumerate(c.prog):
			cmp += "\tDATA[%2s] = 16'h%04X;\t// %02X\n" % (i+1, a, a & 0b111111)
		return cmp


template = '''module ROM(input[15:0] rom_addr, output[15:0] rom_data);
  reg[15:0] DATA[1023:0];
  assign rom_data = DATA[rom_addr];

  initial
    begin
%s    end
endmodule'''
		
if __name__ == '__main__':
	program = open(sys.argv[1]).read()

	c = Compiler(program)
	print template % c.compile()
