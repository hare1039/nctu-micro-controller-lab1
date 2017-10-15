.data
	result: .word  0
	max_size:  .word  0
.text
	.global main
	m: .word  0xEF0F
	n: .word  0xF123



GCD: // r0 = return value; r1 = int a; r2 = int b; a > b
	cmp r2, #0
	beq IF_TRUE_0002 // r2 == 0
	b IF_FALSE_0002
IF_TRUE_0002:
	mov r0, r1
	ldr r3, =max_size
	mov r6, SP
	sub r4, r7, r6
	str r4, [r3]
	bx LR
IF_FALSE_0002:
IF_END_0002:
	mov r3, r1
	mov r4, r2

WHILE_LOOP:     // a % b
	cmp r3, r4
	bge IF_TRUE_0001 // if r3 >= r4
	b IF_FALSE_0001
IF_TRUE_0001:
	sub r3, r3, r4
	b IF_END_0001
IF_FALSE_0001:
    // fillin arguments
	mov r2, r3
	mov r1, r4
	b WHILE_LOOP_END
IF_END_0001:
	b WHILE_LOOP
WHILE_LOOP_END:

	push {lr}
	bl GCD
	pop {pc}

	bx LR

main:
	// r7 = current SP
	mov r7, SP
	ldr r1, =m
	ldr r1, [r1]
	ldr r3, =n
	ldr r3, [r3]
	cmp r1, r3
	blt IF_TRUE_0000 // if r1 <= r3
	b IF_FALSE_0000
IF_TRUE_0000:
    // fillin arguments
	mov r2, r1 // b = a
	mov r1, r3 // a = c
	b IF_END_0000
IF_FALSE_0000:
    // fillin arguments
	mov r2, r3
	b IF_END_0000
IF_END_0000:
	bl GCD
	ldr r3, =result
	str r0, [r3]

	b INF_LOOP
INF_LOOP: b INF_LOOP


