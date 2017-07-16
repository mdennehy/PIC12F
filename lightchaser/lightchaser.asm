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
  
  END


;   void NeoPixel_Write_One(uint8_t value) {
;       // Enable timer and wait for it to overflow
;       T2CONbits.TMR2ON = 1;
;       while (!PIR1bits.TMR2IF);
;   
;       // Set pulse width for bit 7
;       if (value & 0x80) {
;           CCPR1L = NEOPIXEL_LOGIC_1; // ~800ns high, ~450ns low (logic 1)
;       } else {
;           CCPR1L = NEOPIXEL_LOGIC_0; // ~400ns high, ~850ns low (logic 0)
;       }
;       while (!PIR1bits.TMR2IF);
;   
;       // Set pulse width for bit 6
;       if (value & 0x40) {
;           CCPR1L = NEOPIXEL_LOGIC_1; // ~800ns high, ~450ns low (logic 1)
;       } else {
;           CCPR1L = NEOPIXEL_LOGIC_0; // ~400ns high, ~850ns low (logic 0)
;       }
;       while (!PIR1bits.TMR2IF);
;   
;       ...
;   
;       // Set pulse width for bit 0
;       if (value & 0x01) {
;           CCPR1L = NEOPIXEL_LOGIC_1; // ~800ns high, ~450ns low (logic 1)
;       } else {
;           CCPR1L = NEOPIXEL_LOGIC_0; // ~400ns high, ~850ns low (logic 0)
;       }
;   
;       // Idle line low
;       while (!PIR1bits.TMR2IF);
;       asm("NOP");
;       asm("NOP");
;       asm("NOP");
;       asm("NOP");
;       asm("NOP");
;       CCPR1L = 0b00000000;
;   
;       // Disable and reset timer
;       while (!PIR1bits.TMR2IF);
;       asm("NOP");
;       asm("NOP");
;       T2CONbits.TMR2ON = 0;
;       TMR2 = 0x0;
;   }
