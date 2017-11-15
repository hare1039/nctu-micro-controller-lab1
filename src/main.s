/******************************************************
 * LED Pattern Displayer
 * -----------------
 * Implement LED Pattern Displayer on bread board by
 * controlling 4 LED (Active Low Mode).
 * -----------------
 * LED is connected to PB3, PB4, PB5, PB6
 ******************************************************/
    .syntax unified
    .cpu cortex-m4
    .thumb

.data
    leds:   .byte 0x1   // Current LED pattern bit mode
    dir:    .byte 0     // Current LED pattern shift direction,
                        // 0: shift right, 1: shift left

.text
    .global main

    .equ RCC_AHB2ENR,  0x4002104C

    .equ GPIOA_MODER,  0x48000000
    .equ GPIOA_OTYPER, 0x48000004
    .equ GPIOA_OSPEEDR,0x48000008
    .equ GPIOA_PUPDR,  0x4800000C
	.equ GPIOA_IDR,    0x48000010
    .equ GPIOA_ODR,    0x48000014

gpio_init:
	mov  r0, 0b00000000000000000000000000000001
	ldr  r1, =RCC_AHB2ENR
	str  r0, [r1]

	ldr  r1, =GPIOA_MODER @ GPIOA_MODER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111110000000011
	orr  r2, 0b00000000000000000000000101010100
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_OTYPER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111111111100000
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_SPEEDER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111110000000011
	orr  r2, 0b00000000000000000000000101010100
	str  r2, [r1]

	bx   lr


main:
    BL      gpio_init
    ldr r0, =GPIOA_ODR
    mov r1, 0xFFFFFFFF
    str r1, [r0]
    b main
    MOVS    %r1, #1     // start form the right most position
    LDR     %r0, =leds
    STRB    %r1, [R0]

loop:
    // Write the display pattern into leds variable
    ldr     %r0, =leds
    ldr     %r1, =dir
    ldrb    %r2, [%r0]
    ldrb    %r3, [%r1]
    cbz     %r3, loop_right

    // shift lighte LED 1 position to left:
    lsls    %r2, %r2, #1
    cmp     %r2, #0x18
    it      eq
    moveq   %r2, #0x08
    cmp     %r2, #0x10
    itt     eq
    moveq   %r2, #0x0C
    moveq   %r3, #0

    // add     %r2, %r2, #1
    // cmp     %r2, #4
    // it      ge
    // movge   %r3, #0
    b       loop_main

    // shift lighted LED 1 position to right
loop_right:
    lsrs    %r2, #1
    itt     eq
    moveq   %r2, #3
    moveq   %r3, #1
    // sub     %r2, %r2, #1
    // cmp     %r2, #0
    // it      le
    // movle   %r3, #1

loop_main:
    strb    %r2, [%r0]
    strb    %r3, [%r1]

    BL      DisplayLED
    BL      delay
    B       loop


    // Display LED Pattern module
DisplayLED:
    // Display Pattern
    //
    // Shift 3 bits left to meet
    // ----_----_----_----_----_----_-***_*---
    ldr     %r0, =leds
    ldrb    %r1, [%r0]

    lsl     %r0, %r1, #1    // shift 3 bit left
    eor     %r0, %r0, #1   // flip all bits

    ldr     %r1, =GPIOA_ODR
    strh    %r0, [%r1]
    BX      %lr

    // Delay (1s) module
delay:
    movs    r5, #0
    movw    r6, #0xc95      // 0xffffffff / 4M * 3 => 0xc95
delay_d:
    adds    r5, r5, r6      // 1 cycle
    bcc     delay_d         // 2 cycles
    BX      %lr
