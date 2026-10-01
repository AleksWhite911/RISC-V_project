# RISC-V processor program

factorial:

        li      a0, 1
        li      t0, 2
        li 	sp, 0
        #li      t6  512
        li      t5  512
        addi	t5, t5, 512
        addi	t5, t5, 512
        addi	t5, t5, 512
        addi	t5, t5, 512
        addi	t5, t5, 512
        addi	t5, t5, 512
        addi	t5, t5, 512
        sw      t5, 0(sp)
        sw	t5  4(sp)  

loop:   mul     a0, a0, t0
        addi    t0, t0, 1
        lw	t5, 0(sp)
        addi 	t5, t5, 64
        sw	t5, 0(sp)
        li      t6  511
        sw	t6, 8(sp)
        li 	t6  0
        sw	t6, 8(sp)
        beqz    zero, loop
