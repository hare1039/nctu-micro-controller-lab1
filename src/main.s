	.syntax unified
	.cpu cortex-m4
	.thumb

.data
    .equ RCC_AHB2ENR,  0x4002104C
    .equ GPIOC_MODER,  0x48000800
    .equ GPIOC_OTYPER, 0x48000804
    .equ GPIOC_OSPEEDR,0x48000808
    .equ GPIOC_PUPDR,  0x4800080C
    .equ GPIOC_IDR,    0x48000810
    .equ GPIOC_ODR,    0x48000814

    .equ GPIOB_MODER,  0x48000400
    .equ GPIOB_OTYPER, 0x48000404
    .equ GPIOB_OSPEEDR,0x48000408
    .equ GPIOB_PUPDR,  0x4800040C
	.equ GPIOB_IDR,    0x48000410
    .equ GPIOB_ODR,    0x48000414

    .equ GPIOA_MODER,  0x48000000
    .equ GPIOA_OTYPER, 0x48000004
    .equ GPIOA_OSPEEDR,0x48000008
    .equ GPIOA_PUPDR,  0x4800000C
	.equ GPIOA_IDR,    0x48000010
    .equ GPIOA_ODR,    0x48000014

.text
	.global main

GPIO_INIT:
	PUSH {r0-r2}
	ldr r0, =RCC_AHB2ENR
	mov r1, #0b0111
	str r1, [r0]

	ldr r1, =GPIOC_MODER
	ldr r2, [r1]
	//         15141312111009080706050403020100
	and r2, #0b11110011111111111111111111111111
	str r2, [r1]

	ldr r1, =GPIOB_MODER
	ldr r2, [r1]
	//        15141312111009080706050403020100
	and r2, 0b11111111111111111111111100111111
	orr r2, 0b00000000000000000000000001000000
	str r2, [r1]
	ldr r1, =GPIOB_OSPEEDR
	ldr r2, [r1]
	//        15141312111009080706050403020100
	and r2, 0b11111111111111111111111100111111
	orr r2, 0b00000000000000000000000001000000
	str r2, [r1]

	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
	//         15141312111009080706050403020100
	and r2, #0b11111111111111111101011111111111
//	orr r2, r2, r0
	str r2, [r1]


	POP {r0-r2}
	bx lr

B_SET_ONE_AT: // r0:pos
	PUSH {r0-r2}
	ldr r1, =GPIOB_ODR
	mov r2, #1
	lsl r2, r2, r0
	strh r2, [r1]
	POP {r0-r2}
	bx lr

A_SET_ONE_AT: // r0:pos
	PUSH {r0-r2}
	ldr r1, =GPIOA_ODR
	mov r2, #1
	lsl r2, r2, r0
	strh r2, [r1]
	POP {r0-r2}
	bx lr

C_READ_BUTTON: // r0: result
	PUSH {r1}
	ldr r1, =GPIOC_IDR
	ldr r1, [r1]
	// 0010 0000 0000 0000
	lsr r1, r1, #13
	and r0, r1, #1
	POP {r1}
	bx lr

loop:
	bl C_READ_BUTTON
	cmp r0, #1
	beq IF_OK
	b IF_DONE
	IF_OK:
		mov r0, #3
		bl B_SET_ONE_AT
		mov r0, #6
		bl A_SET_ONE_AT
		mov r0, #7
		bl A_SET_ONE_AT
	IF_DONE:
	b loop

main:
	bl GPIO_INIT
	b loop


