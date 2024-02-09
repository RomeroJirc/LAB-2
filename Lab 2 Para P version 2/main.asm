//******************************************************************************
//Universidad del Valle de Guatemala
//IE2023 Programación de microcontroladores
//Autor :
//Proyecto: Codigo de Ejemplo
//Idescripción
//Hardware: ATMega328P
//Created: JOSE ROMERO 22171
;**************************
; ENCABEZADO
;**************************

.include "M328PDEF.inc" ; RECONOCER REGISTROS
.cseg
.org 0x00
;**************************
//Configuración de la pila
;**************************
	LDI	R16, LOW(RAMEND)
	OUT	SPL, R16 
	LDI	R16, HIGH(RAMEND)
	OUT	SPL, R16
;******************************************************************************
;CONFIGURACIONES
;******************************************************************************
Setup:
	LDI R16, (1 << CLKPCE);COLOCAR BIT CLKPCE COMO 1
	STS CLKPR, R16 ;HABILITAR EL PRESCALER
	LDI R16, 0b0000_0011 ;INGRESAR VALOR A R16
	STS CLKPR, R16 ;FRECUENCIA DE 2MHz

;BOTONES
	CBI DDRC, PC2 ;PONIENDO PORTC COMO E0DA EN EL BIT PC2/A2
	LDI R16, (1 << PC2) ;Configurando el pin PC2 o A2 como "pullup activado"
	OUT PORTC, R16 ;CARGANDO EL 1 AL PORTC EN EL BIT NO. PC2

	CBI DDRC, PC3 ;PONIENDO PORTC COMO ENTRADA EN EL BIT PC3/A3
	LDI R16, (1 << PC3) ;Configurando el pin PC3 o A3 como "pullup activado"
	OUT PORTC, R16 ;CARGANDO EL 1 AL PORTC EN EL BIT NO. PC3

;LEDS
	LDI R16, 0b1111_1111 ;INGRESAR VALOR A R16
	OUT DDRD, R16 ;DEFINIR CÓMO SALIDA LOS PUERTOS D
	LDI R16, 0b1111_1111 ;INGRESAR VALOR A R16
	OUT DDRB, R16 ;DEFINIR CÓMO SALIDAS LOS PUERTOS B 
;******************************************************************************
MAIN:
	LDI R17, 0
	LDI ZH, HIGH(TABLA<<1)
	LDI ZL, LOW(TABLA<<1)	
	//ADD ZL, R17
	LPM R17, Z
	OUT	PORTD, R17
	CLR R16
	STS UCSR0B, R16

LOOP:
;LEER BOTON 
	SBIS PINC, PC2; PORTC BOTON A2
	CALL INCREMENTO; LLAMAR SUBRUTINA

	SBIS PINC, PC3 ; PORTC BOTON A3
	CALL DECREMENTO; LLAMAR SUBRUTINA

	RJMP LOOP; VOLVER AL LOOP

;**************************
; SUBRUTINAS
;**************************

DELAY:
	LDI R16, 100; VALOR DE DELAY EN EL REGISTRO R16

LOOP_DELAY:
	DEC R16; DECREMENTAR
	CPI R16, 0; COMPARAR SI ES 0
	BRNE LOOP_DELAY; REGRESAR A LOOP_DELAY SI NO ES 0
	RET

INCREMENTO:
	CALL DELAY
	SBIS PINC, PC2 ;SKIP SI EL PC2 ESTÁ ENCENDIDO
	RJMP INCREMENTO ; REGRESO A LA FUNCIÓN 
	INC R18 ; INCREMENTO EL VALOR DE R18
	SBRC R18, 4 ; SI EL BIT "4" DE R18 ESTÁ APAGADO SALTAR
	SET R18 ;LIMPIAR R18
	CALL OPERACION_TABLA
	RET

DECREMENTO:
	CALL DELAY
	SBIS PINC, PC3 ;SKIP SI EL PC3 ESTÁ ENCENDIDO
	RJMP DECREMENTO ; REGRESO A LA FUNCIÓN
	DEC R18 ; DECREMENTO EL VALOR DE R18
	SBRS R18, 4 ; SI EL BIT "4" DE R18 ESTÁ APAGADO SALTAR
	LDI R18, 0b1111_0000 ;INGRESAR VALOR EN R18
	CALL OPERACION_TABLA
	RET


//TABLA: .DB 0x7E, 0x0E, 0xB7, 0x9F, 0xCE, 0xDB, 0xFB, 0x0F, 0xFF, 0xCF, 0xEF, 0xFA, 0x73, 0xBE, 0xF3, 0xE3
TABLA: .DB 0x81, 0xF3, 0x49, 0x61, 0x33, 0x25, 0x05, 0xF1, 0x01, 0x31, 0x11, 0x07, 0x8D, 0x43, 0x0D, 0x1D
OPERACION_TABLA:
	LDI ZH, HIGH(TABLA<<1)
	LDI ZL, LOW(TABLA<<1)
	ADD	ZL, R18
	LPM	R17, Z
	OUT	PORTD, R17 
	RET


