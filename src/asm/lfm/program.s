.data
value:
	.word 0

.text
linear_modulation:
li a0, 1
li t0, 32

lui t1, 0x10010	#set start word for memory
sw t0, 0(t1)
lw t0, 0(t1)

loop:
addi t6, t6, 511
sw   t6, 8(t1)
mul  t6, t6, zero
sw   t6, 8(t1)

addi t5, t5, 511
sw   t5, 12(t1)
mul  t5, t5, zero
sw   t5, 12(t1)




beqz zero, loop
