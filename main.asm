; Archibald Latham
; LAB12
; 11/19/2019

.cseg

.org 0x0000
rjmp setup
.org 0x0100

.equ OLED_WIDTH = 128
.equ OLED_HEIGHT = 64

.def XPOS = r16
.def YPOS = r17
.def ONE = r22
.def circ = r23

.include	"lib_delay.asm"
.include	"lib_SSD1306_OLED.asm"
.include	"lib_GFX.asm"

setup:
ldi r16, 0
sts PORTC_DIR, r16

rcall OLED_initialize
rcall GFX_clear_array
rcall GFX_refresh_screen

ldi XPOS, 0
ldi YPOS, 4
ldi ONE, 1
ldi circ, 15

loop:
mov r18, XPOS
mov r19, YPOS
rcall GFX_set_array_pos
ldi r20, 0x10
st X, r20
rcall GFX_refresh_screen

rcall waterfall

lds r21, PORTC_IN
andi r21, 0b00000011
cpi r21, 0b00000001
breq move_right
cpi r21, 0b00000010
breq move_left

rjmp loop

move_right:
add YPOS, ONE
rcall GFX_clear_array
rjmp loop

move_left:
sub YPOS, ONE
rcall GFX_clear_array
rjmp loop

waterfall:
mov r18, circ
ldi r19, 0
rcall GFX_set_array_pos
ldi r20, 0x00
st X, r20

mov r18, circ
ldi r19, 4
rcall GFX_set_array_pos
ldi r20, 0x00
st X, r20

mov r18, circ
ldi r19, 7
rcall GFX_set_array_pos
ldi r20, 0x00
st X, r20

cpi circ, 0
breq reset
sub circ, ONE

mov r18, circ
ldi r19, 0
rcall GFX_set_array_pos
ldi r20, 0xEA
st X, r20

mov r18, circ
ldi r19, 4
rcall GFX_set_array_pos
ldi r20, 0x09
st X, r20

mov r18, circ
ldi r19, 7
rcall GFX_set_array_pos
ldi r20, 0xEC
st X, r20

rcall GFX_refresh_screen
ret

reset:
ldi circ, 15
ret