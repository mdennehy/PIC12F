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
	movlb 0     ; select bank 0 (PORTA)
	clrf 0x0C   ; clear PORTA

	movlb 2     ; select bank 2 (LATA)
	clrf 0x0C   ; clear LATA

	movlb 3     ; select bank 3 (ANSELA)
	clrf 0x0C   ; clear ANSELA

	movlb 1     ; select bank 1 (TRISA)
	bcf 0x0C, 2 ; define RA2 as an output port (clear TRISA bit 2)

	;;; Turn on LED (set pin 5 to 1)
	movlb 0     ; select bank 0 (PORTA)
	bsf 0x0C, 2 ; set the 2nd bit of PORTA (address 0x0C) to 1

	;;; Wait 1 second
	movlw 0x43     ; 0x43 = 67
	movwf 0x20     ; set 0x20 to 67
	movlw 0xC7     ; 0xC7 = 199
	movwf 0x21     ; set 0x21 to 199
	movwf 0x22     ; set 0x22 to 199
	decfsz 0x22, 1 ; decrement 0x22
	bra $-1        ; if 0x22 != 0 go back 1 instruction
	decfsz 0x21, 1 ; decrement 0x21
	bra $-4        ; if 0x21 != 0 go back 4 instruction
	decfsz 0x20, 1 ; decrement 0x20
	bra $-7        ; if 0x20 != 0 go back 7 instructions

	;;; Turn off LED (set pin 5 to 1)
	bcf 0x0C, 2 ; set the 2nd bit of PORTA (address 0x0C) to 1

	;;; Wait 1 second
	movlw 0x43     ; 0x43 = 67
	movwf 0x20     ; set 0x20 to 67
	movlw 0xC7     ; 0xC7 = 199
	movwf 0x21     ; set 0x21 to 199
	movwf 0x22     ; set 0x22 to 199
	decfsz 0x22, 1 ; decrement 0x22
	bra $-1        ; if 0x22 != 0 go back 1 instruction
	decfsz 0x21, 1 ; decrement 0x21
	bra $-4        ; if 0x21 != 0 go back 4 instruction
	decfsz 0x20, 1 ; decrement 0x20
	bra $-7        ; if 0x20 != 0 go back 7 instructions

	;;; Loop
	bra $-24

	end
