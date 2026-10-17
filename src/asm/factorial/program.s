# RISC-V processor program
.data
value:
	.word 0
.text
# Start initialization
factorial:
	lui	t1, 0x10010
        li      a0, 1
        li	t0  1



# Program loop for calculate factorial
loop:   
	mul     a0, a0, t0
        addi    t0, t0, 1
        beqz    zero, loop