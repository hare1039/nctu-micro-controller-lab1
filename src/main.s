	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr: .byte 0b01111110, 0b00110000, 0b01101101, 0b01111001, 0b00110011, 0b01011011, 0b01011111, 0b01110000, 0b01111111, 0b01111011, 0b01110111, 0b00011111, 0b01001110, 0b00111101, 0b01001111, 0b01000111
	ONE_SEC: .word 800000
	@ arr: a0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F

.text
	.global main

	.equ RCC_AHB2ENR,  0x4002104C

	.equ DECODE_MODE,  0x09
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT,   0x0B
	.equ INTENSITY,    0x0A
	.equ SHUTDOWN,     0x0C

	.equ MAX7219_DIN,  0x20 @ PA5
	.equ MAX7219_CS,   0x40 @ PA6
	.equ MAX7219_CLK,  0x80 @ PA7

	.equ GPIOA_BASE,   0x48000000
	.equ BSRR_OFFSET,  0x18 @ set bit
	.equ BRR_OFFSET,   0x28 @ clear bit
	.equ ONE_SEC,      4000000

gpio_init:
	mov  r0, 0b00000000000000000000000000000001
	ldr  r1, =RCC_AHB2ENR
	str  r0, [r1]

	ldr  r1, =GPIOA_BASE @ GPIOA_MODER
	ldr  r2, [r1]
	and  r2, 0b11111111111111110000001111111111
	orr  r2, 0b00000000000000000101010000000000
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_OTYPER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111111100011111
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_SPEEDER
	ldr  r2, [r1]
	and  r2, 0b11111111111111110000001111111111
	orr  r2, 0b00000000000000000101010000000000
	str  r2, [r1]

	bx   lr

max7219_init:
	push {r0, r1, r2, lr}

	ldr  r0, =DECODE_MODE
	ldr  r1, =0x0
	bl   max7219_send

	ldr  r0, =DISPLAY_TEST
	ldr  r1, =0x0
	bl   max7219_send

	ldr  r0, =SCAN_LIMIT
	ldr  r1, =0x0
	bl   max7219_send

	ldr  r0, =INTENSITY
	ldr  r1, =0xA
	bl   max7219_send

	ldr  r0, =SHUTDOWN
	ldr  r1, =0x1
	bl   max7219_send

	pop  {r0, r1, r2, pc}



main:
	bl   gpio_init
	bl   max7219_init


	Display0toFLoop:



	b Display0toFLoop

MAX7219Send:
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, lr}
	BX LR

MAX7219_init:
	//TODO: Initialize max7219 registers
	BX LR

delay:
	push {r0}
	ldr r0, =ONE_SEC
	ldr r0, [r0]
	WHILE_LOOP_DELAY:
		cmp r0, #0
		beq END_WHILE_LOOP_DELAY
		sub r0, r0, #1
		b WHILE_LOOP_DELAY
	END_WHILE_LOOP_DELAY:
	pop {r0}
	BX LR

