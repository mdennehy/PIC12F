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





// Output pin initially blocked
NEOPIXEL_TRIS = 1;

/* Initialize PWM module */
PR2 = 0x09; // 1.25us @ 32MHz
CCP1CONbits.P1M = 0b00;     // Single output, P1A modulated only
CCP1CONbits.CCP1M = 0b1100; // PWM mode, P1A active-high, P1B active-high

// Idle the output till width is specified
CCPR1L = 0x00;
CCP1CONbits.DC1B = 0b00;

/* Initialize Timer 2 */
PIR1bits.TMR2IF = 0;        // Clear the interrupt flag for Timer 2
T2CONbits.T2CKPS = 0b00;    // Set a prescaler of 1:1
T2CONbits.TMR2ON = 1;       // Enable the timer

// Wait for the timer to overflow before enabling output
while (!PIR1bits.TMR2IF);
NEOPIXEL_TRIS = 0;




void NeoPixel_Write_One(uint8_t value) {
    // Enable timer and wait for it to overflow
    T2CONbits.TMR2ON = 1;
    while (!PIR1bits.TMR2IF);

    // Set pulse width for bit 7
    if (value & 0x80) {
        CCPR1L = NEOPIXEL_LOGIC_1; // ~800ns high, ~450ns low (logic 1)
    } else {
        CCPR1L = NEOPIXEL_LOGIC_0; // ~400ns high, ~850ns low (logic 0)
    }
    while (!PIR1bits.TMR2IF);

    // Set pulse width for bit 6
    if (value & 0x40) {
        CCPR1L = NEOPIXEL_LOGIC_1; // ~800ns high, ~450ns low (logic 1)
    } else {
        CCPR1L = NEOPIXEL_LOGIC_0; // ~400ns high, ~850ns low (logic 0)
    }
    while (!PIR1bits.TMR2IF);

    ...

    // Set pulse width for bit 0
    if (value & 0x01) {
        CCPR1L = NEOPIXEL_LOGIC_1; // ~800ns high, ~450ns low (logic 1)
    } else {
        CCPR1L = NEOPIXEL_LOGIC_0; // ~400ns high, ~850ns low (logic 0)
    }

    // Idle line low
    while (!PIR1bits.TMR2IF);
    asm("NOP");
    asm("NOP");
    asm("NOP");
    asm("NOP");
    asm("NOP");
    CCPR1L = 0b00000000;

    // Disable and reset timer
    while (!PIR1bits.TMR2IF);
    asm("NOP");
    asm("NOP");
    T2CONbits.TMR2ON = 0;
    TMR2 = 0x0;
}
