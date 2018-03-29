import sys
from functools import partial

from lark import *
from lark.tree import *


class TreeToASM(Transformer):
    def __init__(self):
        self.add = partial(self.alu_op, 'ADD')
        self.sub = partial(self.alu_op, 'SUB')
        self.mul = partial(self.alu_op, 'MUL')
        self.xor = partial(self.alu_op, 'XOR')
        self.or_ = partial(self.alu_op, 'OR')

        self.cmp_gt = partial(self.cmp_op, 'JLE')
        self.cmp_lt = partial(self.cmp_op, 'JLE', swap=True)
        self.cmp_ge = partial(self.cmp_op, 'JLE', swap=True)
        self.cmp_le = partial(self.cmp_op, 'JLE')
        self.cmp_eq = partial(self.cmp_op, 'JEQ')

        self.compare = self.nop
        self.paren_compare = self.nop
        self.refs = self.nop
        self.infix_math = self.nop

        self.frame = []
        self.label_count = 0
        self.stackmap = set()

    def program(self, data):
        return 'STACKMAP ' + ','.join(self.stackmap) + '\n' + '\n'.join(sum(data, []))

    def cmp_op(self, name, (left, right), swap=False):
        return (left +
                right +
                ['POP r0',
                 'POP r1',
                 name + ' ' + ('r0 r1' if not swap else 'r1 r0') + ' {label}'])

    def nop(self, (val, )):
        return val

    # ref : "[" expr "]" "=" expr
    def ref(self, (dst, src)):
        return (src +
                dst +
                ['POP r0',
                 'POP r1',
                 'LD (r0), r1'])

    # ref2 : "[" expr "]" "=" "[" expr "]"
    def ref2(self, (dst, src)):
        return (src +
                dst +
                ['POP r0',
                 'POP r1',
                 'LD r2, (r1)',
                 'LD (r0), r2'])

    # ref3 : id "=" "[" expr "]"
    def ref3(self, (dst, src)):
        return (src +
                ['POP r0',
                 'LD r1, (r0)',
                 'PUSH r1',
                 'POP ' + dst[0]])

    def for_loop(self, (assign, compare, loop, body)):
        start = 'for_start_label_' + str(self.label_count)
        base = 'for_base_label_' + str(self.label_count)
        end = 'for_end_label_' + str(self.label_count)
        self.label_count += 1

        return (assign +
                [start + ':'] +
                [op.format(label=base) for op in compare] +
                ['JMP ' + end] +
                [base + ':'] +
                loop +
                [op.format(loop_end_label=end) for op in body] +
                ['JMP ' + start,
                 end + ':'])

    def while_loop(self, (comparison, body)):
        start = 'while_start_label_' + str(self.label_count)
        end = 'while_end_label_' + str(self.label_count)
        self.label_count += 1

        return ([start + ':'] +
                [op.format(label=end) for op in comparison] +
                [op.format(loop_end_label=end) for op in body] +
                ['JMP ' + start, end + ':'])

    def break_(self, _):
        return ['JMP {loop_end_label}']

    def if_statement(self, (comparison, body)):
        start = 'if_label_' + str(self.label_count)
        end = 'if_end_label_' + str(self.label_count)
        self.label_count += 1

        return ([op.format(label=start) for op in comparison] +
                ['JMP ' + end, start + ':'] +
                body +
                [end + ':'])

    def if_else_statement(self, (comparison, if_body, else_body)):
        start = 'if_label_' + str(self.label_count)
        end = 'if_end_label_' + str(self.label_count)
        self.label_count += 1

        return ([op.format(label=start) for op in comparison] +
                else_body +
                ['JMP ' + end + ':'] +
                [start + ':'] +
                if_body +
                [end + ':'])

    def inc(self, (val, )):
        return ['PUSH ' + val[0],
                'POP r0',
                'INC r0',
                'PUSH r0',
                'POP ' + val[0]]

    def dec(self, (val, )):
        return ['PUSH ' + val[0],
                'POP r0',
                'DEC r0',
                'PUSH r0',
                'POP ' + val[0]]

    def infix_add(self, (lhs, rhs)):
        return (['PUSH ' + lhs[0]] +
                rhs +
                ['POP r0',
                 'POP r1',
                 'ADD r0, r1',
                 'POP ' + lhs[0]])

    def infix_sub(self, (lhs, rhs)):
        return (['PUSH ' + lhs[0]] +
                rhs +
                ['POP r0',
                 'POP r1',
                 'SUB r0, r1',
                 'POP ' + lhs[0]])

    def infix_mul(self, (lhs, rhs)):
        return (['PUSH ' + lhs[0]] +
                rhs +
                ['POP r0',
                 'POP r1',
                 'MUL r0, r1',
                 'POP ' + lhs[0]])

    def statement(self, sub):
        return sum(sub, [])

    def expr(self, data):
        return sum(data, [])

    def comment(self, data):
        return []

    def term(self, (val, )):
        return val

    def factor(self, (val, )):
        if isinstance(val, list):
            val = val[0]
        return ['PUSH {val}'.format(val=val)]

    def id(self, (val, )):
        self.stackmap.add(val)
        return ['[{val}]'.format(val=val)]

    def assign(self, (left, right)):
        return (right +
                ['POP ' + left[0]])

    def alu_op(self, name, (left, right)):
        return (left +
                right +
                ['POP r0',
                 'POP r1',
                 '{name} r0, r1'.format(name=name),
                 'PUSH r0'])


if __name__ == '__main__':
    with open('tudorc.g') as f:
        grammar = Lark(f.read(), start='program', parser='lalr')

    parsed = grammar.parse(open(sys.argv[1]).read())
#    print parsed.pretty()

    print TreeToASM().transform(parsed)
