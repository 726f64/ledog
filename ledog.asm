; Author 	Rod
; Date		11th January 2019
; Version	1.0
; File Name	ledog.ASM
; Device	PIC10F200
; Clock		4 MHz Resonator XS
; Instructions	1 us

; Description	entry for Wearable Tech Challenge of Element14 Community	

	TITLE	"ledog.ASM - Light Emitting Dog "

	LIST	p=10F200
	
	__CONFIG  _IntRC_OSC & _WDTE_OFF & _CP_OFF & _MCLRE_OFF 

;---------------------------------------------------------------------------------
;	Register File Allocation		
;---------------------------------------------------------------------------------
	INCLUDE "p10f200.inc"

;---------------------------------------------------------------------------------
;	Physical Port Assignment		
;---------------------------------------------------------------------------------
;DATAP		EQU	GPIO

;---------------------------------------------------------------------------------
;	Physical Bit Assignment		
;---------------------------------------------------------------------------------
; GPIO
MAINLED	    EQU .2
SWITCH	    EQU	.3

;---------------------------------------------------------------------------------
;	Constant Assignment		
;---------------------------------------------------------------------------------
ROMBASE		EQU	0
MEMBAS		EQU	10h


;---------------------------------------------------------------------------------
;	Flag Bit Assignment		
;---------------------------------------------------------------------------------
;OUT_ST		EQU	.0		; Output LED Status eg toggled on / off

;---------------------------------------------------------------------------------
;	Variable Assignment		
;---------------------------------------------------------------------------------
COUNTER		EQU	MEMBAS
;YOUR_REG2	EQU	COUNTER+1
;---------------------------------------------------------------------------------
;	Macros		
;---------------------------------------------------------------------------------
;BANK0	MACRO
;	BCF	STATUS,RP0
;	ENDM

;BANK1	MACRO
;	BSF	STATUS,RP0
;	ENDM

;---------------------------------------------------------------------------------
;	Vectors		
;---------------------------------------------------------------------------------
	ORG	000h
	GOTO	INIT	; Cold Start on power up

	ORG	004h	; no ISR on PIC10F200
	GOTO	ISR

;---------------------------------------------------------------------------------
;	Interrupt Vector Code		
;---------------------------------------------------------------------------------
;	
ISR	NOP
;	BCF	INTCON,GIE		; make sure that the GIE is cleared to
;	BTFSC	INTCON,GIE		; prevent further interrupts
;	GOTO	ISR
;
;	BSF	INTCON,GIE
	RETFIE

;---------------------------------------------------------------------------------
;	Subroutines		
;---------------------------------------------------------------------------------
DELAY2	MOVLW	.251			; delay of about 1ms
	MOVWF	TMR0
LOP	MOVFW	TMR0
	BTFSS	STATUS,Z
	GOTO	LOP
	RETURN

DEBOUNCE	
	MOVLW	.50			; delay of about 50ms
	MOVWF	TMR0
LOP4	MOVFW	TMR0
	BTFSS	STATUS,Z
	GOTO	LOP4
	RETURN
	
	
DELAY3	MOVLW	.100			; delay of about 1ms (incorporates delay2 but stack is only 2x deep so was an issue)
	MOVWF	COUNTER
LOP2	MOVLW	.251			; delay of about 1ms
	MOVWF	TMR0
LOP3	MOVFW	TMR0
	BTFSS	STATUS,Z
	GOTO	LOP3
	DECFSZ	COUNTER,1
	GOTO	LOP2
	RETURN

	
	
FLASH	BCF	GPIO,MAINLED		; Flash LEDs on and OFF
	CALL 	DELAY3
	BSF	GPIO,MAINLED	
	CALL	DELAY3
	RETURN

;---------------------------------------------------------------------------------
;	Cold Start Setup		
;---------------------------------------------------------------------------------
INIT	

	MOVLW	b'00000000'		; DATAP data port
	MOVWF	GPIO

	MOVLW	b'00000111'		; TMR0 1:256 prescale
	OPTION				; w moved to option register
	
	MOVLW	.0
	TRIS	GPIO

END_T	NOP				; end of isr test

;---------------------------------------------------------------------------------
;	MAIN PROGRAM		
;---------------------------------------------------------------------------------
MAIN	
    BSF	    GPIO,MAINLED
    CALL    DELAY3
    BCF	    GPIO,MAINLED
    CALL    DELAY3
    BSF	    GPIO,MAINLED
    CALL    DELAY3
    BCF	    GPIO,MAINLED
    CALL    DELAY3
    
    
    
;Run the Finite State Machine
FSM_0			    ; off, sleep/power save   
    CALL    MODE0   
    BTFSC   GPIO,SWITCH
    GOTO    FSM_0
    CALL    DEBOUNCE
WAIT0
    BTFSS   GPIO,SWITCH
    GOTO    WAIT0

    
    
FSM_1			    ;ON - continuous
    CALL    MODE1
    BTFSC   GPIO,SWITCH
    GOTO    FSM_1
    CALL    DEBOUNCE
WAIT1
    BTFSS   GPIO,SWITCH
    GOTO    WAIT1

    
    
FSM_2			    ;ON - dim
    CALL    MODE2
    BTFSC   GPIO,SWITCH
    GOTO    FSM_2
    CALL    DEBOUNCE
WAIT2
    BTFSS   GPIO,SWITCH
    GOTO    WAIT2

    
    
FSM_3			    ;ON - flash1   
    CALL    MODE3
    BTFSC   GPIO,SWITCH
    GOTO    FSM_3
    CALL    DEBOUNCE
WAIT3
    BTFSS   GPIO,SWITCH
    GOTO    WAIT3

    
FSM_4			    ;ON - flash2    
    CALL    MODE4
    BTFSC   GPIO,SWITCH
    GOTO    FSM_4
    CALL    DEBOUNCE
WAIT4
    BTFSS   GPIO,SWITCH
    GOTO    WAIT4

GOTO	FSM_0    
    
MODE0	;enter power save / sleep mode - wake on change GP3
    ;SLEEP
    BCF	    GPIO,MAINLED 
    RETURN
    
MODE1	;on continous
    BSF	    GPIO,MAINLED  
    RETURN    
    
MODE2	;on but dim 50% PWM?
    BSF	    GPIO,MAINLED
    NOP
    NOP
    NOP
    NOP
    BCF	    GPIO,MAINLED 
    NOP
    NOP
    NOP
    NOP    
    NOP
    NOP
    NOP
    NOP        
    RETURN
    
MODE3	;flash
    BSF	    GPIO,MAINLED
    CALL    DELAY3
    BCF	    GPIO,MAINLED
    CALL    DELAY3
    RETURN
    
MODE4	;flash pattern2
    BSF	    GPIO,MAINLED
    CALL    DELAY3
    CALL    DELAY3
    BCF	    GPIO,MAINLED
    CALL    DELAY3
    CALL    DELAY3
    CALL    DELAY3
    CALL    DELAY3
    CALL    DELAY3
    CALL    DELAY3
    RETURN
    

END



