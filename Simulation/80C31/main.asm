			ORG 0000H
			
			AJMP MAIN
			
			ORG 0003H
			CJNE R0,#9,CON0			;R=9 is max speed 
			JMP NO0					;jump to reti if max speed and don't increase it
	CON0:	INC R0					;R0 is our speed counter - min = 0 , max = 9
			MOV P0,R0				;display the speed on p0
			SETB P1.0				; stop the motor for a moment
			ACALL DELAY				; delay for bouncing
	NO0:	RETI
			
			ORG 0013H
			CJNE R0,#0FFH,CON1    ;R0 is min speed
			JMP NO1				  ; jump to reti if speed is minimum
	CON1:	DEC R0
			MOV P0,R0
			SETB P1.0
			ACALL DELAY
	NO1:	RETI
			
			
			MAIN:
SETUP:		
			MOV P0,#0FFH		;display ...=R0
			MOV P1,#0FFH		;Optocoupler
			MOV P2,#0FFH		;Emergency switch
			MOV R0,#0FFH		; Speed Counter
			MOV A,R0
			SETB TCON.0			;Edge triggered inturrepts
			SETB TCON.2
			MOV TMOD ,#01H		;Activiating timer T0
			MOV IE,#85H			; Activating external interrupts
	HERE:	JNB P2.0,STOP		;Emergency swtich connected to p2.0 , stops the motor if switch is close
			CJNE R0,#0FFH,GO	;if R0 is not FF jump to rotate the motor otherwise the motor is not rotating
			MOV P1,#0FFH		; stop the motor
			JMP HERE			; check r0 again
	GO:		ACALL LOOP			
			JMP HERE
	STOP:	MOV P1,#0FFH		; stop the motor if the emergency switch is closed
			JB P2.0,HERE		;if the switch is open operate the motor noramlly
			JMP STOP
			
			
	LOOP :
			MOV A ,R0			;Moving the counter to Acc to use the Acc to access ROM below
			CLR P1.0			
			ACALL ON			; the delay of the ON duty cycle
			MOV A,R0			
			SETB P1.0			
			ACALL OFF			; the delay of the OFF duty cycle
			RET
			
			
			ON:
			MOV DPTR,#500H		; the ON duty cycele High bits of the timer stored at 500H
			MOVC A,@A+DPTR		
			MOV TH0,A			
			MOV A,R0
			MOV DPTR,#550H		;The lower bits of the ON cycle timer stored at 550H
			MOVC A,@A+DPTR
			MOV TL0,A
			SETB TR0
			HERE1:JNB TF0,HERE1
			CLR TR0
			CLR TF0
			RET
			
			
			
			
			OFF:
			MOV DPTR,#600H		;The OFF duty cycle timer high bits stored at 600H
			MOVC A,@A+DPTR
			MOV TH0,A
			MOV A,R0
			MOV DPTR,#650H		;	Lower bits at 650H
			MOVC A,@A+DPTR
			MOV TL0,A
			SETB TR0
			HERE2:JNB TF0,HERE2
			CLR TR0
			CLR TF0
			RET
	
			DELAY:				;Delay for bouncing
			MOV R1,#250
		D11:
			MOV R2,#250
		D12:
			MOV R3,#8
		D13:
			DJNZ R3,D13
			DJNZ R2,D12
			DJNZ R1,D11
			RET
			
								; Cycles data...
								ORG 0500H							
	ONV1 :   DB 0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	
			ORG 0550H
	ONV2 :	 DB 0E7H,0CEH,0B5H,09CH,083H,06AH,051H,038H,01FH,06H
	
	
			ORG 0600H
	OFFV1:	DB 0FEH,0FEH,0FEH,0FEH,0FEH,0FEH,0FEH,0FEH,0FEH,0FFH
	
	
			ORG 0650H
	OFFV2:	DB 025H,03EH,057H,070H,089H,0A2H,0BBH,0D4H,0EDH,06H
	
			END