	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	user_stack:  .zero 128
	expr_result: .word   0
	stoi_error:  .word   0

.text
	.global main
	postfix_expr: .asciz "70 0 -1 + 50 + -"
	.align 4

stoi: // func stoi(char *:r1, int& start:r2) -> int:r0
	PUSH {r3-r7}
	mov  r4, #1         // int positive = 1;
	ldrb r5, [r1, r2]   // char r5 = r1[pos]
    cmp  r5, #45        // if (r1[pos] == '-')
    beq IF_0000_TRUE
    b IF_0000_ELSE
	IF_0000_TRUE:
   	    add r2, r2, #1     // pos = pos + 1;
    	    mov r4, #-1        // positive = -1;
    	    b END_IF_0000
    IF_0000_ELSE:
	    cmp r5, #43        // else if(r1[pos] == '+')
        beq IF_0001_TRUE
        b   IF_0001_ELSE
        IF_0001_TRUE:
	        add r2, r2, #1 // pos = pos + 1;
	        b END_IF_0001
        IF_0001_ELSE:
        END_IF_0001:
    END_IF_0000:


	mov r0, #0               // num = 0;
	mov r3, #1               // error = 1
    WHILE_0000:              // while(true)
	    ldrb r5, [r1, r2]    // char x = r1[pos]
    		cmp  r5, #32         // if (x == ' ')
        beq  IF_0003_TRUE
        b    IF_0003_ELSE
        IF_0003_TRUE:
        		add r2, r2, #1
            b END_WHILE_0000 // break;
        IF_0003_ELSE:
        END_IF_0003:

        cmp r5, #0        // if (x == '\0')
        beq IF_0004_TRUE
        b   IF_0004_ELSE
        IF_0004_TRUE:
            b END_WHILE_0000 // break;
        IF_0004_ELSE:
        END_IF_0004:

		mov r3, #0           // error = false
        add r2, r2, #1       // pos = pos + 1
        mov r6, #10          // load r6 as 10
        sub r5, r5, #48      // x = x - '0'
        mla r0, r0, r6, r5   // num = num * 10 + x
        b WHILE_0000
    END_WHILE_0000:

    mul r0, r0, r4
    cmp r0, #0
    beq IF_0002_TRUE
    b   IF_0002_ELSE
    IF_0002_TRUE:
        cmp r3, #1
    		beq IF_0007_TRUE
   		b   IF_0007_ELSE
   		IF_0007_TRUE:
   			mov r0, #254
   			ldr r6, =stoi_error
    	    		str r4, [r6]
   			b END_IF_0007
   		IF_0007_ELSE:
   		END_IF_0007:
    	    b END_IF_0002
    IF_0002_ELSE:
    END_IF_0002:
 	POP {r3-r7}
    BX LR
// end stoi


main:
	ldr	r1, =postfix_expr
	ldr SP, =user_stack
	mov r2, #0
	add SP, SP, 128

	// setup argument done
	bl stoi
	PUSH {r0}
	bl stoi
	PUSH {r0}
	WHILE_LOOP_0001:
		ldr r3, =user_stack
		add r3, r3, #128
		cmp SP, r3
		beq IF_0005_TRUE
		b IF_0005_ELSE
		IF_0005_TRUE:
			b END_WHILE_LOOP_0001
		IF_0005_ELSE:
		END_IF_0005:

		bl stoi

		cmp r0, #254 // 254 == failed
		beq IF_0006_TRUE
		b   IF_0006_ELSE
		IF_0006_TRUE:
			ldr r4, =stoi_error
			ldr r4, [r4]
			POP {r5, r6}
			mul r5, r5, r4
			add r5, r6, r5
			PUSH {r5}
			b END_IF_0006
		IF_0006_ELSE:
			PUSH {r0}
		END_IF_0006:
		b WHILE_LOOP_0001
	END_WHILE_LOOP_0001:

	POP {r5}
	ldr r4, =expr_result
	str r5, [r4]

    b program_end
program_end:
	B		program_end

