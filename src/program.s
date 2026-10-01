.data
value:
	.word 0

.text
linear_modulation:
li a0, 1
li t0, 4

lui  t1, 0x10010
sw t0, 0(t1)
lw t0, 0(t1)
li t6, 1024
li t5, 512

loop:
mul a0, a0, t0
addi t0, t0, 1
addi t6, t6, 32
addi t5, t5, 16
beqz zero, loop
