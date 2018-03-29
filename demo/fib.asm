PUSH 4
POP r7 ; RED

LD r4, 12 ; how many fib numbers to find

; r0 and r1 contain fib numbers
INC r0
INC r1

LD r5, 160

fib_start:
    LD r2, r1
	ADD r1, r0
	LD r0, r2
	
	XOR r2, r2
	
	draw_fib:
		; Loop counter
		INC r2
		; Loop body
		
		; Draw red in the current cell
		LD (r5), 0b100
		; Increment buffer pos
		INC r5
		; Increment position on this line
		INC r6
		
		; Check if we've reached the boundary (x = 160)
		JEQ r6 160 increment_line
		JMP dont_increment
        
		increment_line:
			; Add 160 to buffer pos (skipping a line)
			ADD r5, 160
			; Zero the line counter
			XOR r6, r6
		dont_increment:
			; Do nothing

		; Loop condition
		JLE r2 r1 draw_fib

	ADD r5, 480
	SUB r5, r6
	XOR r6, r6

	INC r3
	JLE r3 r4 fib_start

	
;;; Ok, now we draw some white ball
; x=r0, y=r1
LD r0, 10
LD r1, 70
LD r3, 0 ; direction, 0 = left, 1 = right

draw_animation:
	; Make r5 hold position of that coordinate in framebuffer
	LD r5, r1
	MUL r5, 160
	ADD r5, r0
	
	; if (direction == left)
	JEQ r3, 0 go_right
	; {
		LD r2, 0b000
		LD (r5), r2
		LD r6, 10
		DEC r0
		DEC r5
		JGE r0, r6 done_go
		LD r3, 0 ; switch direction
		JMP done_go
	; } else
	go_right:
	; {
		LD r2, 0b100
		LD (r5), r2
		LD r6, 70
		INC r0
		INC r5
		JLE r0, r6 done_go
		LD r3, 1
	; }
	done_go:
	
	; Draw white
	LD r2, 0b111
	LD (r5), r2

	LD r6, 300
	XOR r7, r7
	sleep:
		DEC r6
		JEQ r6, r7 done_sleep
		JMP sleep

	done_sleep:

	JMP draw_animation

lp:
JMP lp
