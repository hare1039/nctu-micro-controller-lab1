  .syntax unified
  .cpu cortex-m4
  .thumb

  .global X
  .data
  .align 2
  .type X, %object
  .size X, 4
X:
  .word 5
  .global Y
  .align 2
  .type Y, %object
  .size Y, 4
Y:
  .word 10
.text
  .global main
main:
	ldr r0, =X
	ldr r0, [r0]
	ldr r1, =Y
	ldr r1, [r1]
	MULS r0, r0, r1
	ADDS r0, r0, r1
	SUBS r2, r1, r0

L:B L
