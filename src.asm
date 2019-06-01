.definelabel	FREE_SPACE,0x87FF814

.gba
.open ROM_IN,ROM_OUT,0x8000000

.org 0x8000324
	dw	ExtraFunctions|1


.org 0x800164C
	ldr	r0,=ResetRngIndex|1b
	bx	r0
	.pool

.org 0x8001658
	ldr	r0,=UpdateRngIndex|1
	mov	r14,r15
	bx	r0
	b	0x8001666
	.pool

.org 0x800166E
	ldr	r0,=UpdateRngIndex|1
	mov	r14,r15
	bx	r0
	b	0x800167C
	.pool

.org 0x8001688
	ldr	r0,=UpdateRngIndex|1
	mov	r14,r15
	bx	r0
	b	0x8001696
	.pool

.org 0x800169E
	ldr	r0,=UpdateRngIndex|1
	mov	r14,r15
	bx	r0
	b	0x80016AC
	.pool


.org 0x867A180
.area 0x800
	.import	"_temp\font.img.bin"
.endarea


.org FREE_SPACE


.align 2
ResetRngIndex:
	ldr	r1,=0x2009800
	mov	r0,0x0
	str	r0,[r1,0x4]
	ldr	r0,=0xA338244F
	str	r0,[r1]

	mov	r15,r14


.align 2
UpdateRngIndex:
	ldr	r0,[r7,0x4]
	add	r0,0x1
	str	r0,[r7,0x4]

	// Normal RNG function
	ldr	r0,[r7]
	ldr	r1,=0x873CA9E5
	lsl	r2,r0,0x1
	lsr	r3,r0,0x1F
	add	r0,r2,r3
	add	r0,0x1
	eor	r0,r1

	mov	r15,r14

	.pool


.align 2
ExtraFunctions:
	push	r14

	ldr	r0,=HudStrings
	bl	DrawHudStrings

@@end:
	ldr	r0,=0x3006824|1
	mov	r14,r15
	bx	r0

	pop	r15


.align 2
DrawHudStrings:
// r0 = string pointer
	push	r4-r6,r14
	mov	r4,r0

@@drawHudString:
	ldrb	r0,[r4]		// Get X
	cmp	r0,0xFF
	beq	@@end

	ldrb	r1,[r4,0x1]	// Get Y
	lsl	r1,r1,0x6
	lsl	r0,r0,0x1
	add	r0,r0,r1	// X+Y

	// Get pointer to BG0 tilemap
	mov	r5,r10
	ldr	r5,[r5,0x5C]	// Base pointer
	add	r5,r5,r0	// Add X+Y offset
	mov	r6,r5		// Set current line pointer

	add	r4,0x2		// Go to string

@@drawHudStringLoop:
	ldrb	r0,[r4]
	add	r4,0x1


@@checkCmd0:
	// Next string
	cmp	r0,0x00
	beq	@@drawHudString


@@checkCmd1:
	cmp	r0,Cmd_NewLine
	bne	@@checkCmd2

	// Go to next line
	add	r5,0x40
	// Reset line
	mov	r6,r5

	b	@@drawHudStringLoop


@@checkCmd2:
	cmp	r0,Cmd_PrintMemHex32
	bne	@@checkCmd3

	// Load value
	bl	LoadParam32
	ldr	r0,[r0]

	// Print value
	mov	r1,0x8
	bl	PrintHex

	b	@@drawHudStringLoop


@@checkCmd3:
	cmp	r0,Cmd_PrintMemHex16
	bne	@@checkCmd4

	// Load value
	bl	LoadParam32
	ldrh	r0,[r0]

	// Print value
	mov	r1,0x4
	bl	PrintHex

	b	@@drawHudStringLoop


@@checkCmd4:
	cmp	r0,Cmd_PrintMemHex8
	bne	@@checkCmd5

	// Load value
	bl	LoadParam32
	ldrb	r0,[r0]

	// Print value
	mov	r1,0x2
	bl	PrintHex

	b	@@drawHudStringLoop


@@checkCmd5:
	cmp	r0,Cmd_PrintMemDec32
	bne	@@checkCmd6

	// Load value
	bl	LoadParam32
	ldr	r0,[r0]

	// Print value
	bl	PrintDec

	b	@@drawHudStringLoop


@@checkCmd6:
	cmp	r0,Cmd_PrintMemDec16
	bne	@@checkCmd7

	// Load value
	bl	LoadParam32
	ldrh	r0,[r0]

	// Print value
	bl	PrintDec

	b	@@drawHudStringLoop


@@checkCmd7:
	cmp	r0,Cmd_PrintMemDec8
	bne	@@checkCmd8

	// Load value
	bl	LoadParam32
	ldrb	r0,[r0]

	// Print value
	bl	PrintDec

	b	@@drawHudStringLoop


@@checkCmd8:
	cmp	r0,Cmd_PrintMemDecS16
	bne	@@checkCmd9

	// Load value
	bl	LoadParam32
	mov	r1,0x0
	ldsh	r0,[r0,r1]

	// Print value
	bl	PrintDec

	b	@@drawHudStringLoop


@@checkCmd9:
	cmp	r0,Cmd_PrintMemDecS8
	bne	@@checkCmd10

	// Load value
	bl	LoadParam32
	mov	r1,0x0
	ldsb	r0,[r0,r1]

	// Print value
	bl	PrintDec

	b	@@drawHudStringLoop


@@checkCmd10:
	cmp	r0,Cmd_PrintEnum8
	bne	@@checkCmd11

	// Load enum names
	bl	LoadParam32
	mov	r1,r0

	// Load value
	bl	LoadParam32
	ldrb	r2,[r0]

	// Load maximum
	bl	LoadParam8
	cmp	r2,r0
	bgt	@@drawHudStringLoop

@@enumLoop:
	ldrb	r0,[r1]
	add	r1,0x1

	// Go to next enum val if needed
	cmp	r0,0x0
	bne	@@enumCheckPrint
	sub	r2,0x1
	bmi	@@drawHudStringLoop
	b	@@enumLoop

@@enumCheckPrint:
	// Print if enum val is 0
	cmp	r2,0x0
	bne	@@enumLoop

	// Print enum char
	bl	PrintChar

	b	@@enumLoop


@@checkCmd11:
	cmp	r0,Cmd_Func
	bne	@@checkCmd12

	// Call function
	bl	LoadParam32
	mov	r14,r15
	bx	r0

	b	@@drawHudStringLoop


@@checkCmd12:


@@printChar:
	bl	PrintChar

	b	@@drawHudStringLoop

@@end:
	pop	r4-r6,r15


.align 2
PrintHex:
// r0 = value
// r1 = hex characters
	push	r14
	mov	r2,r0
	mov	r3,r1

@@loop:
	// Decrement counter
	sub	r3,0x1
	bmi	@@end
	// Get next part
	lsl	r1,r3,0x2
	mov	r0,r2
	lsr	r0,r1
	lsl	r0,r0,0x1C
	lsr	r0,r0,0x1C

	// Convert to hex character
	cmp	r0,0xA
	blt	@@printChar
	add	r0,0x7

@@printChar:
	add	r0,0x30
	bl	PrintChar
	b	@@loop

@@end:
	pop	r15


.align 2
PrintDec:
// r0 = value
	push	r4-r5,r14
	mov	r4,r0
	mov	r5,0x0		// Skip initial zeros

	cmp	r4,0h
	beq	@@printZero

	// Check negative
	lsl	r0,r4,0x1
	bcc	@@start

	// Convert to positive
	mvn	r4,r4
	add	r4,0x1

	// Print minus
	mov	r0,0x2D
	bl	PrintChar
@@start:
	ldr	r2,=MultiplesOf10

@@loop:
	ldr	r1,[r2]
	add	r2,0x4
	cmp	r1,0x0
	beq	@@checkZero

	// Get next digit
	mov	r0,r4
	swi	0x6

	// Store remainder
	mov	r4,r1

	// Check if we should print 0
	cmp	r5,0x0
	bne	@@printDigit

	// Check if this is 0
	cmp	r3,0x0
	beq	@@loop

	// First digit, start printing
	mov	r5,0x1

@@printDigit:
	mov	r0,0x30
	add	r0,r0,r3
	bl	PrintChar

	b	@@loop

@@checkZero:
	// Check if we printed anything
	cmp	r5,0x0
	bne	@@end

@@printZero:
	// Print a zero
	mov	r0,0x30
	bl	PrintChar

@@end:
	pop	r4-r5,r15

	.pool


.align 2
LoadParam32:
	push	r1,r14

	ldrb	r0,[r4]
	ldrb	r1,[r4,0x1]
	lsl	r1,r1,0x8
	orr	r0,r1
	ldrb	r1,[r4,0x2]
	lsl	r1,r1,0x10
	orr	r0,r1
	ldrb	r1,[r4,0x3]
	lsl	r1,r1,0x18
	orr	r0,r1

	add	r4,0x4
	pop	r1,r15


.align 2
LoadParam16:
	push	r1,r14

	ldrb	r0,[r4]
	ldrb	r1,[r4,0x1]
	lsl	r1,r1,0x8
	orr	r0,r1

	add	r4,0x2
	pop	r1,r15


.align 2
LoadParam8:
	ldrb	r0,[r4]
	add	r4,0x1
	mov	r15,r14


.align 2
PrintChar:
	push	r1,r14

	ldr	r1,=0xF200	// Base tilemap entry

	// Make uppercase
	cmp	r0,0x61
	blt	@@doPrintChar
	cmp	r0,0x7E
	bgt	@@doPrintChar
	sub	r0,0x20

@@checkRange:
	cmp	r0,0x20
	blt	@@end
	cmp	r0,0x5B
	bgt	@@end

@@doPrintChar:
	sub	r0,0x20
	add	r1,r1,r0

@@end:
	strh	r1,[r6]
	add	r6,0x2

	pop	r1,r15


	.pool


.align 4
MultiplesOf10:
	.dw	1000000000
	.dw	100000000
	.dw	10000000
	.dw	1000000
	.dw	100000
	.dw	10000
	.dw	1000
	.dw	100
	.dw	10
	.dw	1
	.dw	0


.definelabel	Cmd_PrintMemHex32,	0x01
.definelabel	Cmd_PrintMemHex16,	0x02
.definelabel	Cmd_PrintMemHex8,	0x03
.definelabel	Cmd_PrintMemDec32,	0x04
.definelabel	Cmd_PrintMemDec16,	0x05
.definelabel	Cmd_PrintMemDec8,	0x06
.definelabel	Cmd_PrintMemDecS16,	0x07
.definelabel	Cmd_PrintMemDecS8,	0x08
.definelabel	Cmd_PrintEnum8,		0x09
.definelabel	Cmd_NewLine,		0x0A
.definelabel	Cmd_Func,		0x0B


StyleElemNames:
	.ascii	"Norm",0x00
	.ascii	"Elec",0x00
	.ascii	"Heat",0x00
	.ascii	"Aqua",0x00
	.ascii	"Wood",0x00


.align 2
PrintNextEncounterStep:
	push	r14

	// Get last encounter check step counter
	ldr	r0,=0x2001DE0
	ldr	r0,[r0]
	// Add 64
	add	r0,0x40

	// Print it
	bl	PrintDec

	pop	r15

	.pool


HudStrings:
	.db	0, 0	// X, Y
	.ascii	"RNG1val:"
	.db	Cmd_PrintMemHex32	:: .dw	0x2009730
	.db	Cmd_NewLine
	.ascii	"RNG1idx:"
	.db	Cmd_PrintMemDec32	:: .dw	0x2009734
	.db	Cmd_NewLine
	.ascii	"RNG2val:"
	.db	Cmd_PrintMemHex32	:: .dw	0x2009800
	.db	Cmd_NewLine
	.ascii	"RNG2idx:"
	.db	Cmd_PrintMemDec32	:: .dw	0x2009804
	.db	0

	.db	21, 0	// X, Y
	.ascii	"Elem:"
	.db	Cmd_PrintEnum8		:: .dw	StyleElemNames	:: .dw	0x2001DBB	:: .db	4
	.db	0

	.db	0, 16	// X, Y
	.ascii	"X="
	.db	Cmd_PrintMemDecS16	:: .dw	0x2008F54
	.db	Cmd_NewLine
	.ascii	"Y="
	.db	Cmd_PrintMemDecS16	:: .dw	0x2008F56
	.db	Cmd_NewLine
	.ascii	"Step:"
	.db	Cmd_PrintMemDec32	:: .dw	0x2001DDC
	.db	Cmd_NewLine
	.ascii	"Next:"
	.db	Cmd_Func		:: .dw	PrintNextEncounterStep|1
	.db	0

// To add:
// gambleWin = 0x02009DB2
// folderSlot = 0x02034040

	.db	-1	// Terminator

.close
