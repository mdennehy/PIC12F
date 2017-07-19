	list p=p12f1840
	include <p12f1840.inc>
	__CONFIG _CONFIG1, _FOSC_INTOSC & _MCLRE_OFF & _WDTE_OFF
	__CONFIG _CONFIG2, _LVP_OFF

  org 0
	;;; Set internal oscillator to 32 MHz
	movlw 0xF0 ; store OSCCON value (=1111 0000=) in W
	movlb 0x01 ; Select page bank 1
	movwf 0x19 ; move value of W to register at OSCCON (address 0x19)

	;;; Define pin 5 (RA2) as output
  BANKSEL PORTA ; select bank 0 (PORTA)
  CLRF    PORTA ; clear PORTA

	BANKSEL LATA ; select bank 2 (LATA)
	CLRF    LATA ; clear LATA

  BANKSEL ANSELA ; select bank 3 (ANSELA)
	CLRF    ANSELA ; clear ANSELA

	BANKSEL TRISA ; select bank 1 (TRISA)
	BCF     TRISA, 2 ; define RA2 as an output port (clear TRISA bit 2)

  BANKSEL T2CON 
  CLRF    T2CON ; Timer2 off, prescale 1:1, postscaler not used in PWM
  MOVLW   0x09
  MOVWF   PR2 ; Set PWM period to 1.25us
  
  BANKSEL CCPR1L
  MOVLW   0x05
  MOVWF   CCPR1L ; Set PWM duty cycle to 50%
  CLRF    CCP1CON
  MOVLW   0x0C
  MOVWF   CCP1CON ; Set up for PWM on pin 5


  BANKSEL T2CON 
  BSF     T2CON, 2 ; Timer2 on
  
  BANKSEL CCPR1L
  ; hack - write a slightly different 24bit value 16 different times, pause,
  ; redo from start
  CONSTANT PIXEL=0x2F0
  CONSTANT RED=0x2F1
  CONSTANT BLUE=0x2F2
  CONSTANT GREEN=0x2F3

  movlw 0x00
  movwf RED
  movwf BLUE
  movwf GREEN

PixelLoopSetup
  BANKSEL CCPR1L
  movlw 0x0F
  movwf PIXEL

PixelLoop
  BANKSEL CCPR1L
  decfsz  PIXEL,1
  bra $+2
  goto Latch

  ; send bits
  BANKSEL CCPR1L
  btfsc GREEN,7
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,7
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,6
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,6
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,5
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,5
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,4
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,4
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,3
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,3
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,2
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,2
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,1
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,1
  CALL SendZero
  BANKSEL CCPR1L
  btfsc GREEN,0
  CALL SendOne
  BANKSEL CCPR1L
  btfss GREEN,0
  CALL SendZero

  BANKSEL CCPR1L
  btfsc RED,7
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,7
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,6
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,6
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,5
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,5
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,4
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,4
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,3
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,3
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,2
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,2
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,1
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,1
  CALL SendZero
  BANKSEL CCPR1L
  btfsc RED,0
  CALL SendOne
  BANKSEL CCPR1L
  btfss RED,0
  CALL SendZero

  BANKSEL CCPR1L
  btfsc BLUE,7
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,7
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,6
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,6
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,5
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,5
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,4
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,4
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,3
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,3
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,2
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,2
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,1
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,1
  CALL SendZero
  BANKSEL CCPR1L
  btfsc BLUE,0
  CALL SendOne
  BANKSEL CCPR1L
  btfss BLUE,0
  CALL SendZero

  BANKSEL CCPR1L
  incf RED,1
  btfsc RED,5
  clrf RED
  incf GREEN,1
  btfsc GREEN,5
  clrf GREEN
  incf BLUE,1
  btfsc BLUE,5
  clrf BLUE
  goto PixelLoop

SendOne
  BANKSEL CCPR1L
  MOVLW 0x08
  MOVWF CCPR1L
  BCF   CCP1CON, 4
  BCF   CCP1CON, 5
  BANKSEL PIR1
  BTFSS PIR1,1
  BRA $-1
  RETURN

SendZero
  BANKSEL CCPR1L
  MOVLW 0x02
  MOVWF CCPR1L
  BSF   CCP1CON, 4
  BSF   CCP1CON, 5
  BANKSEL PIR1
  BTFSS PIR1,1
  BRA $-1
  RETURN

Latch
  ; Set to 100% low
  BANKSEL CCPR1L
  MOVLW 0x00
  MOVWF CCPR1L
  BCF   CCP1CON,4
  BCF   CCP1CON,5

Delay
  ; Delay for 15us / 1/2sec
  movlw 0x20
  movwf 0x2F5
	movlw 0xC7     ; 0xC7 = 199
	movwf 0x2F6     ; set 0x30 to 199
	movwf 0x2F7     ; set 0x31 to 199
	decfsz 0x2F7, 1 ; decrement 0x30
	bra $-1        ; if 0x31 != 0 go back 1 instruction
	decfsz 0x2F6, 1 ; decrement 0x31
	bra $-4        ; if 0x30 != 0 go back 4 instruction
  decfsz 0x2F5, 1
  bra $-7
  goto PixelLoopSetup

  END

