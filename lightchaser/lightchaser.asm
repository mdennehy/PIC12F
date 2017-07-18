	list p=p12f1840
	include <p12f1840.inc>
	__CONFIG _CONFIG1, _FOSC_INTOSC & _MCLRE_OFF
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
  
  ; hack - write a slightly different 24bit value 16 different times, pause,
  ; redo from start
  CONSTANT PIXEL=0x20
  CONSTANT RED=0x21
  CONSTANT BLUE=0x22
  CONSTANT GREEN=0x23
  CONSTANT PIXEL_ONE=0x08
  CONSTANT PIXEL_ZERO=0x02

  movlw 0x00
  movwf RED
  movwf BLUE
  movwf GREEN

PixelLoopSetup
  movlw 0x0F
  movwf PIXEL

PixelLoop
  decfsz  PIXEL,1
  goto Latch

  ; send bits
  CALL SendOne
  CALL SendZero

  incf RED,1
  incf BLUE,1
  incf GREEN,1
  goto PixelLoop

SendOne
  BANKSEL CCPR1L
  MOVLW 0x08
  MOVWF CCPR1L
  BCF   CCP1CON, 4
  BCF   CCP1CON, 5
  RETURN

SendZero
  BANKSEL CCPR1L
  MOVLW 0x02
  MOVWF CCPR1L
  BSF   CCP1CON, 4
  BSF   CCP1CON, 5
  RETURN

Latch
Delay
  ; Set to 100% low
  BANKSEL CCPR1L
  MOVLW 0x00
  MOVWF CCPR1L
  CLRF  CCP1CON

  ; Delay for 15us
	movlw 0xC7     ; 0xC7 = 199
	movwf 0x30     ; set 0x30 to 199
	movwf 0x31     ; set 0x31 to 199
	decfsz 0x31, 1 ; decrement 0x30
	bra $-1        ; if 0x31 != 0 go back 1 instruction
	decfsz 0x30, 1 ; decrement 0x31
	bra $-4        ; if 0x30 != 0 go back 4 instruction
  goto PixelLoopSetup
  END

