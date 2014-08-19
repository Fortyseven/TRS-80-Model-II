;SYSRES/ASM - LS-DOS 6.2
	TITLE	<SYSRES - LS-DOS 6.2>
LF	EQU	10
CR	EQU	13
;
;*LIST	OFF			;Xref of Lowcore
*GET	LDOS60/EQU:2
;*LIST	ON
*GET	COPYCOM:3		;Embed copyright notice
;
	SUBTTL	<'System low core assignments>'
;
;	LDOS 6.2 Low Core RAM storage assignments
;	Copyright (C) 1982 by Logical Systems, Inc.
;
START$	EQU	0
	ORG	0+START$
;
;	Page 0 - RST's, data, and buffers
;
@RST00	DI			;IPL Entry for R/S 4-P
	LD	A,00000001B	;Set image in A
	OUT	(9CH),A		;toggle in BOOT/ROM
	DB	0,0,0		;CP/M emulator SVC
@RST08	RET
	DW	0
SVCRET$	DW	0		;Return address from SVC
LSVC$	DB	0		;Last SVC executed
FDDINT$	DI			;NOP or DI (F3H) for
	RET			;  System (Smooth)
@RST10	RET
	DW	0
USTOR$	DS	5		;User storage area
@RST18	RET
	DW	0
PDRV$	DB	1		;Current drive, physical
PHIGH$	DW	0		;Physical HIGH$
LOW$	DW	3000H		;Lowest usable memory
@RST20	RET
	DW	0
LDRV$	DB	0		;Current drive, logical
JDCB$	DW	0		;Saved FCB pointer
JRET$	DW	0		;Saved I/O return address
@RST28	JP	RST28		;System SVC processor
TIMSL$	DB	55H		;Fast=55, slow=FF
TIMER$	DB	0		;RTC counter
TIME$	DC	3,0		;SS:MM:HH storage area
@RST30	JP	@DEBUG		;DEBUG call address
DATE$	DS	5		;YY/DD/MM/packed
@RST38	JP	RST38@		;Interrupt RST
	IF	@BLD631
OSRLS$	DB	01H		;<631>OS Release #
	ELSE
OSRLS$	DB	00H		;OS Release #
	ENDIF
;
;	INTIM$ stores the image read from RDINTSTATUS*
;
INTIM$	DB	0		;Interrupt latch image
;
;	INTMSK$ masks the image read from RDINTSTATUS*
;	LDOS 6.x permits only RS-232 RCV INT, IOBUS INT,
;	and RTC INT to be used by the TASKER off of RST38
;
INTMSK$	DB	2CH		;Mask for INTIM$
;
;	INTVC$ stores the eight vectors associated
;	with the INTIM$ bit assignments
;
INTVC$	DW	RETINST		;Primary interrupts
	DW	RETINST,RTCPROC,RETINST
	DW	RETINST,RETINST,RETINST,RETINST
;
;	TCB$ stores the TCB vectors for task slots 0-11
;
TCB$	DS	24		;Interrupt task vectors
;
;	NMI vector used in disk I/O
;
@NMI	DS	3		;Don't overlay this
;
;	OVRLY$ stores the system's overlay request #
;
OVRLY$	DB	0		;Current overlay resident
;
;	FLGTAB$ stores 26 flags and images. A pointer
;	to this table is obtained from SVC-@FLAGS
;
FLGTAB$	EQU	$
;
;
;	AFLAG$ - Start CYL for Allocation search
;
AFLAG$	DB	01		;AFLAG
	DB	0		;BFLAG
;
;	CFLAG$ assignments:
;	 0 - Cannot change HIGH$ via SVC-100
;	 1 - @CMNDR in execution
;	 2 - @KEYIN request from SYS1
;	 3 - System request for drivers, filters, DCTs
;	 4 - @CMNDR to only execute LIB commands
;	 5 - Sysgen inhibit bit
;	 6 - @ERROR inhibit display
;	 7 - @ERROR to use user (DE) buffer
;
CFLAG$	DB	0		;Condition flag
;
;	DFLAG$ assignments:
;	 0 - SPOOL is active
;	 1 - TYPE ahead is active
;	 2 - VERIFY is on
;	 3 - SMOOTH active
;	 4 - MemDISK active
;	 5 - FORMS active
;	 6 - KSM active
;	 7 - accept GRAPHICS in screen print
;
DFLAG$	DB	00001010B	;DEV Flag (SMOOTH,TYPE)
;
; 	EFLAG$ - Assignments: (sys13 usage)
;	use only bits 4, 5 and 6 to indicate user
; 	entry code to be passed to SYS13. SYS13
; 	will be executed from SYS1 if this byte
;	is NON/0, bit 4, 5 and 6 will be merged into
;	the SYS13 (1000,1111b) overlay request
;
EFLAG$	DB	0		;Flag E
FEMSK$	DB	0		;Port FE mask
	DC	2,0		;Flags G-H
;
; 	IFLAG$ - Assignments: (INTERNATIONAL)
;	 0 - FRENCH
;	 1 - GERMAN
;	 2 - SWISS
;	 3 -
;	 4 - 
;	 5 - 
;	 6 - Special DMP mode ON/OFF
;	 7 - '7' bit mode ON/OFF
;
IFLAG$	EQU	$
	IF	@FRENCH
	DB	01000001B
	ENDIF
	IF	@GERMAN
	DB	01000010B
	ENDIF
	IF	@USA
	DB	0
	ENDIF
	DB	0		;Flag J
;
;	KFLAG$ assignments:
;	 0 - BREAK latch
;	 1 - PAUSE latch
;	 2 - ENTER latch
;	 3 - reserved
;	 4 - reserved
;	 5 - CAPs lock
;	 6 - reserved
;	 7 - character in TYPE ahead
;
KFLAG$	DB	0		;Keyboard flag
;
;	LFLAG$ assignments:
;	 0 - inhibit step rate question in FORMAT
;	 4 - inhibit 8" query in FLOPPY/DCT
;	 5 - inhibit # sides question in FORMAT
;	 6,7 - Reserved for IM 2 hardware
;
LFLAG$	DB	00010001B	;LDOS feature inhibit
;
;	MODOUT$ mask assignments:
;	 0 -
;	 1 - cassette motor on/off
;	 2 - mode select (0 = 80/64, 1 = 40/32)
;	 3 - enable alternate character set
;	 4 - enable external I/O
;	 5 - video wait states (0 = disable, 1 = enable)
;	 6 - clock speed ( 1 = 4 Mhz, 0 = 2 MHz)
;	 7 -
;
	IF	@INTL
MODOUT$	DB	70H		;MODOUT international
	ELSE
MODOUT$	DB	78H		;MODOUT port image (FAST)
	ENDIF
;
;
;	NFLAG$ - Network flag$
;	 0 - Allow setting of file open bit in DIR
;	 1 / 5 - Reserved
;	 6 - Set if in Task Processor
;	 7 - Reserved
;
	DB	0		;Inhibit open bit in DIR
;
;	OPREG$ memory management image port
;	 0 - SEL0 - Select map overlay bit 0
;	 1 - SEL1 - Select map overlay bit 1
;	 2 - 80/64 - 1 = 80 x 24
;	 3 - Inverse video
;	 4 - MBIT0 - memory map bit 0
;	 5 - MBIT1 - memory map bit 1
;	 6 - FXUPMEM - fix upper memory
;	 7 - PAGE - page 1K video RAM (set for 80x24)
;
OPREG$	DB	87H		;Memory management image
;
; 	PFLAG$ - Printer flag
;	7 = Printer spooler is paused
;	0 - 6 = Reserved
;
	DB	0
	DB	0		;QFLAG$
;
;	RFLAG$ - Retry init for FDC driver
;
RFLAG$	DB	08		;FDC retry count >=2
;
;	SFLAG$ assignments:
;	 0 - inhibit file open bit
;	 1 - set to 1 if bit-2 set & EXEC file opened
;	 2 - set by @RUN to permit load of EXEC file
;	 3 - SYSTEM (FAST)
;	 4 - BREAK key disabled
;	 5 - JCL active
;	 6 - force extended error messages
;	 7 - DEBUG to be turned on after load
;
SFLAG$	DB	8		;System flag (FAST)
;
;
;	Machine TYPE assignment:
;	All values are in decimal
;
;	 2 = TRS-80 Model 2
;	 4 = TRS-80 Model 4
;	 5 = TRS-80 MODEL 4P
;	12 = TRS-80 Model 12
; 	16 = TRS-80 Model 16
;
	IF	@MOD4
TFLAG$	DB	04		;Model 4 assignment
	ELSE
	ERR	'Undefined machine TYPE for TFLAG'
	ENDIF
	DB	0		;Flag U
;
;	Video FLAG$ assignments:
;	 0-3 - Set blink rate (1=fastest,7=slowest)
;	 4 - display CLOCK
;	 5 - cursor blink toggle bit
;	 6 - Inhibit blinking cursor (user)
;	 7 - Inhibit blinking cursor (system)
;
VFLAG$	DB	0		;Blink,Slow,No clock
;
;	WRINT$ - interrupt mask register
;	 0 - enable 1500 baud rising edge
;	 1 - enable 1500 baud falling edge
;	 2 - enable real time clock
;	 3 - enable I/O bus interrupts
;	 4 - enable RS-232 transmit interrupts
;	 5 - enable RS-232 receive data interrupts
;	 6 - enable RS-232 error interrupt
;
WRINT$	DB	4		;WRINTMASK port image
	DB	0		;Flag x
;
;	Bits 0-7 indicate new style dating on drives 0-7
;
YFLAG$	DB	0FFH
	DB	0		;Z flag
;
;	Contents are high-order byte of SVC table
;
	DB	SVCTAB$<-8	;MSB of SVC table
;
;	OSVER$ stores the operating system version
;
OSVER$	DB	63H		;OS version #
;
;	Vector for config initialization
;
@ICNFG	RET			;Initialization config
	DW	0
;
;	Chain vector for KI task processor
;
@KITSK	RET			;Keyboard task routine
	DW	0
;
;	System File Control Block for overlays
;
SFCB$	DB	80H,0,0		;System /SYS FCB
	DW	SBUFF$
	DB	0
	DW	0,0,0,-1,0,-1,-1
;
;	32-byte DEBUG save area
;
DBGSV$	DS	32
;
;	Job Control Language File Control Block
;
JFCB$	DC	3,0
	DW	SBUFF$
	DS	27
;
;	System Command Line file control block
;
CFCB$	EQU	$		;Command Interpreter FCB
CFGFCB$	DB	'CONFIG/SYS.CCC:0',3
	DS	15
;
;	Page 1 - System Supervisor Call Table
;
SVCTAB$	EQU	$
	IFNE $,100H
	ERR	'SVCTBL location violation'
	ENDIF
;
;	Initial version
;
MAXCOR$	EQU	2400H+START$
MINCOR$	EQU	3000H+START$
	ORG	@BYTEIO
;
;	file positioning routines - MUST BE FIRST
;
	SUBTTL	'<File positioning subroutines>'
	PAGE	OFF
*GET	FILPOSN:3
	PAGE
CORE$	DEFL	$
	ORG	CRTBGN$+13
	IF	@BLD631
	DB	'LS-DOS 06.03.01'	;<631>
	ELSE
	DB	'LS-DOS 06.03.00'
	ENDIF
	IF	@USA
	DB	' '
	ENDIF
	IF	@GERMAN
	DB	'D'
	ENDIF
	IF	@FRENCH
	DB	'F'
	ENDIF
	IF	@BLD631
	DB	'- Copyright 1986/90 '	;<631>
	DB	'MISOSYS, Inc.    '	;<631>
	ELSE
	DB	'- Copyright 1986 '
	DB	'Logical Systems Inc.'
	ENDIF
	ORG	CRTBGN$+80+14
	DB	'               All Rights Reserved. '
	DB	'               '
;	DB	'Licensed to Tandy Corporation.'
	ORG	CORE$
;
;	get the system loader
;
	SUBTTL	'<System Loader and associated routines>'
	PAGE	OFF
*GET	LOADER:3
	SUBTTL	'<System front end & task processor>'
	PAGE	OFF
*GET	TASKER:3
	IFGT	$,1D00H+START$
	ERR	'SYSRES memory overflow
	ENDIF
CORE$	DEFL	$
	DC	1D00H-CORE$,0
	ORG	CORE$
	ORG	1D00H+START$
SBUFF$	EQU	$
	DS	256		;Page disk I/O buffer
DIRBUF$	EQU	MAXCOR$-256	;Another file buffer
;
;	get the system initialization module
;
OVERLAY	EQU	$
	SUBTTL	'<System initialization routines>'
	PAGE	OFF
*GET	SYSINIT4:3
	SUBTTL	'<Misc. lowcore routines>'
	PAGE	OFF
*GET	SOUND:3
	SUBTTL	'<Sign-on LOGO display>'
*GET	LSILOGO:3
;
	IF	@BLD631
	ORG	DATE$+3			;<631>
	DB	0			;<631>
	ENDIF
	END	OVERLAY

