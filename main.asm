; Archibald Latham
; 12/11/2019
; Final Project
; This program runs a game on the OLED screen called SPACE where the user drives a spaceship through an endless onlaught of asteroids

.cseg
.org			0x0000
				rjmp	setup
.org			0x0100

; define constants
.equ			OLED_WIDTH = 128
.equ			OLED_HEIGHT = 64

; set names for general purpose registers
.def			xpos = r16
.def			ypos = r17
.def			one = r22
.def			circ = r23
.def			circpos = r24

;import relevent libraries
.include		"lib_delay.asm"
.include		"lib_SSD1306_OLED.asm"
.include		"lib_GFX.asm"

;setup for hardware
setup:
				ldi		r16, 0					; set direction of port C for input
				sts		PORTC_DIR, r16

				rcall	OLED_initialize			; initilaize OLED screen
				rcall	GFX_clear_array
				rcall	GFX_refresh_screen

				ldi		xpos, 0					; load starting values into general purpose registers
				ldi		ypos, 0
				ldi		one, 1
				ldi		circ, 15
				ldi		circpos, 3

				ldi		r18, 1					; draw first row of startup screen block letters
				ldi		r19, 3
				rcall	GFX_set_array_pos
				ldi		r20, 0xDA
				st		X+, r20
				ldi		r20, 0xC2
				st		X+, r20
				ldi		r20, 0xBF
				st		X+, r20
				ldi		r20, 0xDA
				st		X+, r20
				ldi		r20, 0xC4
				st		X+, r20
				ldi		r20, 0xBF
				st		X+, r20
				ldi		r20, 0xC4
				st		X+, r20
				ldi		r20, 0xC2
				st		X+, r20
				ldi		r20, 0xBF
				st		X+, r20
				ldi		r20, 0xC4
				st		X+, r20
				ldi		r20, 0xC2
				st		X+, r20
				ldi		r20, 0xBF
				st		X+, r20
				ldi		r20, 0xB3
				st		X+, r20
				ldi		r20, 0xDA
				st		X+, r20
				ldi		r20, 0xBF
				st		X, r20

				ldi		r18, 1					; draw second row of startup screen block letters		
				ldi		r19, 4
				rcall	GFX_set_array_pos
				ldi		r20, 0xB3
				st		X+, r20
				ldi		r20, 0xB3
				st		X+, r20
				ldi		r20, 0xB3
				st		X+, r20
				ldi		r20, 0xB3
				st		X+, r20
				ldi		r20, 0x00
				st		X+, r20
				ldi		r20, 0xB3
				st		X+, r20
				ldi		r20, 0xC4
				st		X+, r20
				ldi		r20, 0xC1
				st		X+, r20
				ldi		r20, 0xD9
				st		X+, r20
				ldi		r20, 0x00
				st		X+, r20
				ldi		r20, 0xC0
				st		X+, r20
				ldi		r20, 0xD9
				st		X+, r20
				ldi		r20, 0xC0
				st		X+, r20
				ldi		r20, 0xD9
				st		X+, r20
				ldi		r20, 0xB3
				st		X, r20

				rcall	GFX_refresh_screen		; refresh OLED and delay 
				rcall	delay_1s
				rcall	GFX_clear_array
				rcall	GFX_refresh_screen

; main loop for carrying our function of program
loop:
				rcall	waterfall				; call waterfall interation of asteroids

				mov		r18, xpos				; set ship position to given value
				mov		r19, ypos
				rcall	GFX_set_array_pos
				ldi		r20, 0x10
				st		X, r20

				lds		r21, PORTC_IN			; compare button input for direction
				andi	r21, 0b00000011
				cpi		r21, 0b00000001
				breq	move_right
				cpi		r21, 0b00000010
				breq	move_left

				rjmp	loop					

; move the ship one positon right
move_right:
				mov		r18, xpos
				mov		r19, ypos
				rcall	GFX_set_array_pos
				ldi		r20, 0x00
				st		X, r20
				add		ypos, one
				rjmp	loop

; move the ship one positon left
move_left:
				mov		r18, xpos
				mov		r19, ypos
				rcall	GFX_set_array_pos
				ldi		r20, 0x00
				st		X, r20
				sub		ypos, one
				rjmp	loop

; iteration of asteroid waterfall
waterfall:
				mov		r18, circ				; set asteroids in current position to empty sprites
				ldi		r19, 0
				rcall	GFX_set_array_pos
				ldi		r20, 0x00
				st		X, r20

				mov		r18, circ				
				mov		r19, circpos
				rcall	GFX_set_array_pos
				ldi		r20, 0x00
				st		X, r20

				mov		r18, circ				
				ldi		r19, 7
				rcall	GFX_set_array_pos
				ldi		r20, 0x00
				st		X, r20

				cpi		circ, 0					; check if asteroids have reached bottom of screen, if so reset, if not move asteroid positions down one
				breq	reset
				sub		circ, one

				mov		r18, circ				; set new asteroid postion to circle sprite
				ldi		r19, 0
				rcall	GFX_set_array_pos
				ldi		r20, 0x09
				st		X, r20

				mov		r18, circ
				mov		r19, circpos
				rcall	GFX_set_array_pos
				ldi		r20, 0x09
				st		X, r20

				mov		r18, circ
				ldi		r19, 7
				rcall	GFX_set_array_pos
				ldi		r20, 0x09
				st		X, r20

				rcall	GFX_refresh_screen		; refresh screen
				ret

;reset loop for next itertion of asteroids and death check
reset:
				cpi		ypos, 0					; check if ship has has hit asteroid or reached out of bounds
				brge	gameover
				cpi		ypos, -6
				brlt	gameover

				push	r16						; stack needed general purpose registers
				ldi		r16, 7
				mov		r25, circpos
				sub		r25, r16
				pop		r16

				cp		ypos, r25				; check if ship has hit asteroid
				breq	gameover

				cpi		circpos, 6				; change position of asteroids
				brge	circreset
				cpi		circpos, 5
				brge	circreset2
				ldi		r25, 2
				add		circpos, r25
				ldi		circ, 15

				ret

; reset loop for asteroid position
circreset:
				ldi		circpos, 1
				ret

; another reset loop for asteroid position
circreset2:
				ldi		circpos, 0
				ret

; game over loop clears screen and game resets
gameover:
				rcall	GFX_clear_array
				rcall	GFX_refresh_screen
