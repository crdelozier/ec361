		AREA mydata, DATA, READWRITE
count	DCD 0
	
		AREA mycode, CODE, READONLY
		EXPORT __main
__main	PROC
		BL port_config
		BL EINT0_Init
		MOV R4, #0
loop	
		ADD R4, R4, #1
		CMP R4, #0xFF
		BNE loop
		MOV R4, #0
		B loop
		ENDP
			
EINT0_Init PROC
		MOV R3, #1
		; Setup pin 2.10 to be EINT0
		LDR R0, =0x4002C010 ; R0 = PINSEL4
		LDR R1, [R0]
		; PINSEL(21:20) = 01
		ORR R1, R3, LSL #20 ; (R3 << 20) | R1 ==> (0000 0000 0001 0000 0000 0000 0000 0000) | R1
		BIC R1, R3, LSL #21 ; ~(R3 << 21) & R1 ==> ~(0000 0000 0010 0000 0000 0000 0000 0000) & R1 ==> (1111 1111 1101 1111 1111 1111 1111 1111) & R1
		STR R1, [R0]
		
		; Setup Mode in EXTMODE(0) = 1
		LDR R0, =0x400FC148
		LDR R1, [R0]
		ORR R1, R3
		STR R1, [R0]
		
		; Setup Polarity in EXTPOLAR(0) = 1
		LDR R0, =0x400FC14C
		LDR R1, [R0]
		ORR R1, R3
		STR R1, [R0]		
		
		; Enable interrupt in ISER0(18) = 1
		LDR R0, =0xE000E100
		LDR R1, [R0]
		ORR R1, R3, LSL #18
		STR R1, [R0]

		BX LR
		ENDP

; Write a handler for EINT0
		EXPORT EINT0_IRQHandler
EINT0_IRQHandler	PROC
		; Do whatever we want to do with this handler
		MOV R0, R4 ; Setting up the parameter (R0) for LEDs function to take the value from my counter (R4)
		PUSH {LR}
		BL LEDs
		POP {LR}
				
		; Unset the interrupt by setting EXTINT(0) = 1
		LDR R0, =0x400FC140
		MOV R1, #1
		STR R1, [R0]
		DSB
		
		BX LR
		ENDP

; Initializes FIO1DIR and FIO2DIR
port_config PROC
		LDR R0, =0x2009C020 ; FIO1DIR address
		LDR R1, =0xF0000000 ; Bits 31:28
		STR R1, [R0]
		MOVW R1, 0x007C		; Bits 6:2
		STR R1, [R0,#0x20]	; FIO2DIR = FIO1DIR + 0x20
		BX LR
		ENDP

; Show a binary number on the LEDs
; Assumes that R0 holds the number to show
LEDs	PROC
		MOV R3, #0
		AND R1, R0, #0x80
		LSL R1, R1, #21
		ORR R3, R3, R1
		AND R1, R0, #0x40
		LSL R1, R1, #23
		ORR R3, R3, R1
		AND R1, R0, #0x20
		LSL R1, R1, #26
		ORR R3, R3, R1
		LDR R2, =0x2009C034
		STR R3, [R2]
		
		MOV R3, #0
		AND R1, R0, #0x10
		LSR R1, R1, #2
		ORR R3, R3, R1
		AND R1, R0, #0x08
		ORR R3, R3, R1
		AND R1, R0, #0x04
		LSL R1, R1, #2
		ORR R3, R3, R1
		AND R1, R0, #0x02
		LSL R1, R1, #4
		ORR R3, R3, R1
		AND R1, R0, #0x01
		LSL R1, R1, #6
		ORR R3, R3, R1
		STR R3, [R2, #0x20]
		BX LR
		ENDP

		END