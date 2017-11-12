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
	PUSH {r0, r1}
	ldr r0, =RCC_AHB2ENR
	mov r1, #0b0110
	str r1, [r0]

	ldr r0, =GPIOB_MODER
	mov r1, #0b00000000000000000000000001010101
	str r1, [r0]

	POP {r0, r1}
	bx lr

SET_VAL_A: // PB3 -> 1
	PUSH {r0-r3}
	ldr r2, =GPIOB_ODR
	mov r3, #0xFFFFFFF
	str r3, [r2]

	POP {r0-r3}
	bx lr

main:
	bl GPIO_INIT
	bl SET_VAL_A

loop:
	bl SET_VAL_A
	b loop



