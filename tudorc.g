program: statement+

statement : if_statement
		  | break_
		  | for_loop
		  | infix_math
          | if_else_statement
          | while_loop
          | "{" statement* "}"
          | assign ";"
          | refs ";"
		  | comment
          | ";"

for_loop : "for" "(" assign ";" compare ";" infix_math ")" statement
while_loop : "while" paren_compare statement
if_statement : "if" paren_compare statement
if_else_statement : "if" paren_compare statement "else" statement

break_ : "break"

paren_compare: "(" compare ")"
paren_expr : "(" expr ")"

refs : ref
     | ref2
     | ref3

ref : "[" expr "]" "=" expr
ref2 : "[" expr "]" "=" "[" expr "]"
ref3 : id "=" "[" expr "]"

assign : id "=" expr

infix_math : inc
           | dec
           | infix_add
           | infix_sub
		   | infix_mul
		   
infix_add : id "+=" expr
infix_sub : id "-=" expr
infix_mul : id "*=" expr

inc : id "++"
dec : id "--"

compare : cmp_gt
        | cmp_lt
        | cmp_ge
        | cmp_le
		| cmp_eq

cmp_gt : expr ">" expr
cmp_lt : expr "<" expr
cmp_ge : expr ">=" expr
cmp_le : expr "<=" expr
cmp_eq : expr "==" expr

expr : term
     | add
	 | sub
	 | or_
	 | xor

term : factor
     | mul
	 | and
	 
add : expr "+" expr
sub : expr "-" expr
and : expr "&" expr
or_ : expr "|" expr
xor : expr "^" expr

mul : term "*" factor

factor : id
       | INT
       | HEXINT
       | paren_expr

id : /[_a-zA-Z]+/

comment: /\/\/[^\n]*/

HEXINT : /0x[a-zA-Z0-9]+/

%import common.INT
%import common.HEXDIGIT
%import common.WS
%ignore WS