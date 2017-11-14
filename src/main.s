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

	ldr r0, =GPIOB_MODER
	ldr r1, [r0]
	mov r2, #0xFFFFFEBF
	and r1, r1, r2
	str r1, [r0]

//	mov r0, #0x400
	mov r0, #0b00000000000000000000010000000000
	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
//	and r2, #0xFFFFF3FF
	and r2, #0b11111111111111111111001111111111
	orr r2, r2, r0
	str r2, [r1]


	POP {r0-r2}
	bx lr

B_SET_ONE_AT: // r0:pos
	PUSH {r0-r3}
	ldr r1, =GPIOB_ODR
	mov r3, #1
	lsl r3, r3, r0
	mov r3, #0xFFFFFFFF
	strh r3, [r1]
	POP {r0-r3}
	bx lr

main:
	bl GPIO_INIT
	b loop

loop:
	ldr r1, =GPIOA_ODR
	mov r0, #(1<<5)
	strh r0, [r1]
	b loop



