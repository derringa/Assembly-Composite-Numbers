TITLE Composite Number Generator     (Project4_Andrew_Derringer.asm)

; Author: Andrew Derringer
; Last Modified: 2/17/2019
; OSU email address: derringa@oregonstate.edu
; Course number/section: CS 271 - 400
; Project Number: 4                Due Date: 2/17/2019
; Description: Program uses seperate procedures but with global variables to introduce the program
; ask the user for their name, request and validate an integer input  n within a range, and determine
; n number of composite numbers starting from 1.

INCLUDE Irvine32.inc

;---------------------------------------;
; Constants                             ;
;---------------------------------------;

MAXRANGE EQU <400>									;constant for highest integer input accepted from user
MINRANGE EQU <1>									;constant for lowest integer input accepted from user
OUTPUTLINES EQU <10>								;passed into ebx and decremented



.data

;---------------------------------------;
; User input data                       ;
;---------------------------------------;

userInput				DWORD		?				;holds integer input for number of composites to print
userName				BYTE		33	DUP(0)		;string variable holding user input when prompted for their name



;---------------------------------------;
; Title page output, greeting, farewell ;
;---------------------------------------;

programTitle			BYTE		"Composite Number Generator with MASM", 0
programAuthor			BYTE		"by: Andrew Derringer", 0
extraCredit				BYTE		"*****Extra Credit Attempted: Output Formatting*****", 0

greeting				BYTE		"Welcome and thank you for using the Composite Number Generator.", 0
requestName				BYTE		"Please enter your name: ", 0
hello					BYTE		"Hello ", 0
goodbye					BYTE		"And there you have it. Have a good day ", 0



;---------------------------------------;
; Request input and data validation     ;
;---------------------------------------;

outputTransition		BYTE		"Lets get started.", 0
requestInput			BYTE		"Please enter the number of composite numbers to generate between 1 and 400: ", 0

maxError				BYTE		"Your number was too big. Try again:", 0
minError				BYTE		"Your number was too small. Try again:", 0



;---------------------------------------;
; Output formatting                     ;
;---------------------------------------;

compositesMessage		BYTE		"Total Composites printed: ", 0
singleSpace				BYTE		"     ", 0
doubleSpace				BYTE		"    ", 0
tripleSpace				BYTE		"   ", 0
exclamation				BYTE		"!", 0



.code

;---------------------------------------------------------------------;
; Procedure: Main                                                     ;
; Description: Handles all process by calls to other procedures and   ;
; use of global variables.                                            ;
;---------------------------------------------------------------------;

main PROC

	call	introduction
	call	getUserData
	call	showComposites
	call	farewell
	

	exit	; exit to operating system
main ENDP



;---------------------------------------------------------------------;
; Procedure: introduction                                             ;
; Description: Title and auther, greetings, extra credit method, and  ;
; request and storage of user's name.                                 ;
;---------------------------------------------------------------------;

introduction PROC
	mov		edx, OFFSET programTitle		; print program title
	call	WriteString
	call	CrLf
	mov		edx, OFFSET programAuthor		; print program author
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET extraCredit			; print extra credit statement
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET greeting			; print welcome to the program
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET requestName			; print request for name
	call	WriteString
	mov		edx, OFFSET userName			; prepare userName variable to read string
	mov		ecx, 32
	call	ReadString						; store user's name in userName
	call	CrLf
	mov		edx, OFFSET hello				; print hello followed by..
	call	WriteString
	mov		edx, OFFSET userName			; user's name followed by..
	call	WriteString
	mov		edx, OFFSET exclamation			;exclamation mark
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP



;---------------------------------------------------------------------;
; Procedure: getUserData                                              ;
; Description: request and store user's desired number of compsite    ;
; numbers in a range of 1 to 400. Nested call for data validation     ;
; called until acceptable input.                                      ;
;---------------------------------------------------------------------;

getUserData PROC
	mov		edx, OFFSET outputTransition	; print transition to requesting input
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET requestInput		; print request for integer input
	call	WriteString
	call	integerValidation				; call to integer validation which is prepared to ReadInt
	mov		userInput, eax					; valid input in eax upon return, stored in userInput
	ret
getUserData ENDP



;---------------------------------------------------------------------;
; Procedure: integerValidation                                        ;
; Description: Checks if user input is above or equal to min, is      ;
; below or equal to max, and then leaves valid input in eax. If input ;
; is out of range then jump back to beginning of procedure.           ;
;---------------------------------------------------------------------;

integerValidation PROC

CheckMin:
	call	ReadInt
	call	CrLf
	cmp		eax, MINRANGE					; compares input to minimum of range <1
	jge		short CheckMax					; jumps to checking max if above min range
	mov		edx, OFFSET minError			; prints error message if out of range
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		short CheckMin					; returns to beginning and requests new input

CheckMax:
	cmp		eax, MAXRANGE					; compares input to max range >400
	jle		short InputDone					; jumps to end if within range, no change or additional requests
	mov		edx, OFFSET maxError			; prints error message if out of range
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		short CheckMin					; returns to beginning and requests new input

InputDone:
	ret										; user input in eax upon return

integerValidation ENDP



;---------------------------------------------------------------------;
; Procedure: showComposites                                           ;
; Description: Checks if user input is above or equal to min, is      ;
; below or equal to max, and then leaves valid input in eax. If input ;
; is out of range then jump back to beginning of procedure.           ;
;---------------------------------------------------------------------;

showComposites PROC
	mov		eax, MINRANGE					; eax used as accumulator beginning at min range = 1
	mov		ecx, userInput					; ecx used as loop counter equal to number of desired number output
	mov		edx, 0							; holds count of numbers printed to determine when a newline is applied
PrintLoop:
	push	ecx								; preserve loop counter on stack for ecx use in isComposite procedure call
	push	edx								; preserve numbers printed counter on stack for ecx use in isComposite procedure call
	call	isComposite						; call to isComposite procedure - if eax is composite then ebx = 1 on return, otherwise 0
	pop		edx								; restore edx to printed number counter
	pop		ecx								; restore ecx to loop counter
	cmp		ebx, 0							
	je		NoIncrement						; if ebx = 0 then eax does not hold a composite number - jump to NoComposite
	add		edx, ebx						; if ebx = 1 then increment edx as the printed numbers counter
	cmp		edx, OUTPUTLINES
	jl		NextLoop						; while edx print count is less than constant for outputs per line jump to next loop
	call	CrLf
	mov		edx, 0							; if edx print count = number of desired input per line, print newline and jump to next loop
	jmp		NextLoop
NoIncrement:
	inc		ecx								; if not composite then ecx is increment to counter its decrement by loop, not counting loops that don't result in a composite number
NextLoop:
	inc		eax								; all logic paths reach here - eax incremented and loop back to top
	loop	PrintLoop

	ret
showComposites ENDP



;---------------------------------------------------------------------;
; Procedure: isComposite                                              ;
; Description: Checks number of interest placed in eax during loop    ;
; within showComposite procedure for characteristics of a composite   ;
; number. Return 1 for true and 0 for false.                          ;
; citation: adapted from c++ function at geeksforgeeks.org/           ;
; composite-number/                                                   ;
;---------------------------------------------------------------------;
	
isComposite PROC
	cmp		eax, 3							; first condition - n <=3 is not composite - jump to nope
	jle		short Nope
	push	eax								; preserve n in eax for after upcoming DIV
	mov		ebx, 2
	mov		edx, 0							; clear edx for DIV remainder
	div		ebx								; n / 2 quotient in eax and remainder in edx
	pop		eax								; restore eax to original n
	cmp		edx, 0							; if n % 2 == 0 then is composite - jump to yup
	je		short Yup
	mov		edx, 0							; clear edx for DIV remainder
	push	eax								; preserve n in eax for after upcoming DIV
	mov		ebx, 3
	div		ebx								; n / 3 quotient in eax and remainder in edx
	pop		eax								; restore eax to original n
	cmp		edx, 0							; if n % 3 == 0 then is composite - jump to yup
	je		short Yup
	mov		edx, 0
	mov		ebx, 5							; enter for loop of conditions for n >= 25 where i = 5
OtherComposites:
	push	eax								; preserve n in eax for after upcoming MUL
	mov		eax, ebx						; move i into eax from ebx
	mul		ebx								; multiply i * i
	mov		edx, eax						; store i * i in edx
	pop		eax								; restore eax to original n
	cmp		edx, eax						; only run for loop if n >= i * i - else jump to nope
	jge		short Nope
	push	eax								; preserve n in eax for after upcoming DIV
	mov		edx, 0							; clear edx for DIV remainder
	div		ebx								; n / i quotient in eax and remainder in edx
	pop		eax								; restore eax to original n
	cmp		edx, 0							; if n % i == 0 then is composite - jump to yup
	je		short Yup
	mov		edx, 0							; clear edx for DIV remainder
	push	ebx								; preserve ebx value of i for this for loop iteration
	push	eax								; preserve n in eax for after upcoming DIV
	add		ebx, 2							; i + 2
	div		ebx								; n / i + 2 quotient in eax and remainder in edx
	pop		eax								; restore eax to original n
	cmp		edx, 0							; if n % i + 2 == 0 then is composite - jump to yup
	pop		ebx	pop							; restore ebx to current i
	je		short Yup
	add		ebx, 6							; if no yup jumps then i += 6 for next loop - return to top
	jmp		short OtherComposites
Nope:
	mov		ebx, 0							; return 0 or false in ebx
	jmp		short Done
Yup:
	call	WriteDec						; if true print n within eax
	call	whiteSpace						; call whiteSpace prodecure to place correct alignment whitespace in edx and print
	mov		ebx, 1							; return 1 or true in ebx
Done:

	ret
isComposite ENDP



;---------------------------------------------------------------------;
; Procedure: whiteSpace                                               ;
; Description: depending on the size or number of digits for an       ;
; integer about to be printed from isComposite, either 3, 4, or 5     ;
; spaces are printed to properly left align all outputs in columns.   ;
;---------------------------------------------------------------------;

whiteSpace PROC
	cmp		eax, 100						; if n is three digits jump to ThreeDigits
	jge		ThreeDigits
	cmp		eax, 10							; else if n is two digits jump to DoubleDigits
	jge		DoubleDigits
	mov		edx, OFFSET singleSpace			; else print 5 spaces after a single digit number
	call	WriteString
	jmp		EndConditions
DoubleDigits:
	mov		edx, OFFSET doubleSpace			; print 4 spaces after a double digit number
	call	WriteString
	jmp		EndConditions
ThreeDigits:
	mov		edx, OFFSET tripleSpace			; print 3 spaces after a double digit number
	call	WriteString
EndConditions:

	ret
whiteSpace ENDP



;---------------------------------------------------------------------;
; Procedure: farewell                                                 ;
; Description: print a farewell statement using the name provided by  ;
; the user at the beginning of the program.                           ;
;---------------------------------------------------------------------;

farewell PROC
	call	CrLf
	mov		edx, OFFSET goodbye				; print goodbye followed by..
	call	WriteString
	mov		edx, OFFSET userName			; print name followed by..
	call	WriteString
	mov		edx, OFFSET exclamation			; print exclamation mark
	call	WriteString
	call	CrLf
	call	CrLf
	ret
farewell ENDP



END main
