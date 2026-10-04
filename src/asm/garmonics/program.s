Linear modulation:
li a0, 1
li t0, 2
#sw t0, 4(t0)
#1w t0 4(t0)
li t6 1024
li t5 512
loop:
mul a0, a0, t0
addi t0, t0, 1
beqz zero, loop
