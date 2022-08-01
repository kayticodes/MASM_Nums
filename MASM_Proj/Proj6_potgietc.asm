TITLE Designing low-level I/O procedures    (potgietc.asm)

; Author: Catherine Potgieter
; Last Modified: 12/02/2021
; Due Date: 12/05/2021
; Description: This file contains a program that requests 10 signed integers that can fit in a 32 bit reg and returns 
;			   the integers, their sum, and their truncated average;             

INCLUDE Irvine32.inc

mGetString MACRO out_int, prompt_str, error_message, try_again, user_input

	LOCAL _intLoop
	LOCAL _make_num
	LOCAL _num_loop
	LOCAL _not_num
	LOCAL _num_too_big
	LOCAL _first_char
	LOCAL _neg_num
	LOCAL _pos_num
	LOCAL _check_sign
	LOCAL _make_neg
	LOCAL _exit


	.data 
	int_array			DWORD 20 Dup(?) 	
	user_input_array	DWORD 10 Dup(?)			
	sLen				DWORD ? 
	integer				DWORD 0
	sign_flag			DWORD ? 


	.code 
	PUSH	EDX									; Preserve Registers 
	PUSH	ECX 
	PUSH	EAX 
	PUSH	EBX 
	PUSH	ESI 
	PUSH	EDI 

	; get the user input 
	mov		EDX, prompt_str 
	call	WriteString							; prompts the user for an input 
	mov		EDX, user_input
	mov		ECX, 20
	call	ReadString							; recieves the input as a string 
	mov		sLen, EAX 

	; validates that the input fits into a 32bit reg 
	PUSH	EAX 
	mov     EDX, user_input
	mov     ECX, sLen 
	call    ParseInteger32
	JO      _num_too_big
	POP		EAX

	; validate that the input is not and empty string 


	; Set up loop counter and indexes 
	 CLD
	 mov    ECX, sLen
	 mov    ESI, user_input
	 mov    EDI, int_array
	 mov    EBX, 0 

	; Establish and save the integer value of the ASCII code input 
	_intLoop:
	LODSB										; Puts byte in AL
    cmp     ECX, sLen							; check if we're looking at the first character
    JE      _first_char 												 
    cmp    AL, 48								; Verify input represents a digit on the ASCII chart 
    JL     _not_num
    cmp    AL, 57
    JG     _not_num
    sub    AL, 48								; establish the integer 
    MOV     int_array[EBX], EAX					; add integer to int_array
    ADD     EBX, 4
    LOOP   _intLoop 
    JMP    _make_num

	_first_char: 
    cmp     AL, 45								; Checks for a negative sign 
    JE      _neg_num 
    cmp     AL, 43
    JE      _pos_num							; Checks for a positive sign 
    cmp    AL, 48								; Goes through the regular number check 
    JL     _not_num
    cmp    AL, 57
    JG     _not_num
    sub    AL, 48								; Establishes integer representation of ASCII character 
    MOV     EBX, 0 
    MOV     int_array[EBX], EAX					; Add to the int_array to be processed later
    ADD     EBX, 4
    LOOP   _intLoop
	JMP		_make_num

	_neg_num: 
    mov    sign_flag, 1							; set sign flag to 1 
    mov     AL, 0 
    SUB     sLen, 1								; decrement sLen to account for the sign symbol 			
    LOOP   _intLoop

	_pos_num: 
    mov     AL, 0 
    SUB     sLen, 1								; decrement sLen to account for the sign symbol 
    LOOP   _intLoop


	; If invalid input is given: display error message, gather new input, re-set loop counter and indexes 
	_not_num: 
	mov		sign_flag, 0						; reset sign flag 
	mov    EDX, error_message
	call   WriteString							; displays error message to the user 
	call   CrLf
	mov    EDX, try_again
	call   WriteString							; asks the user to try again 
	mov    EDX, user_input
	mov    ECX, 20
	call   ReadString							; saves the user input as a string 
	mov    sLen, EAX
	call   CrLf

	; validates that the input fits into a 32bit reg 
	PUSH	EAX 
	mov     EDX, user_input
	mov     ECX, sLen 
	call    ParseInteger32
	JO      _num_too_big
	POP		EAX

	; Reset the string prim loop 
	CLD										
	mov    ECX, sLen
	mov    ESI, user_input
	mov    EDI, int_array
	mov    EBX, 0 
	JMP   _intLoop

	; If invalid input is given: display error message, gather new input, re-set loop counter and indexes 
	_num_too_big: 
	POP	   EAX
	mov		sign_flag, 0						; reset sign flag 
	mov    EDX, error_message
	call   WriteString							; displays error message to the user 
	call   CrLf
	mov    EDX, try_again
	call   WriteString							; asks the user to try again 
	mov    EDX, user_input
	mov    ECX, 20
	call   ReadString							; saves the user input as a string 
	mov    sLen, EAX
	call   CrLf

	; validates that the input fits into a 32bit reg 
	PUSH	EBX 
	mov     EDX, user_input
	mov     ECX, sLen 
	call    ParseInteger32
	JO      _num_too_big
	POP		EAX

	CLD											; Resets the string prim loop 
	mov    ECX, sLen
	mov    ESI, user_input
	mov    EDI, int_array
	mov    EBX, 0 
	JMP   _intLoop

	; Bulid the integer up with the int_array values 
	_make_num:						
	mov		EBX, 0 
	mov		EDX, 0 
	mov		ECX, sLen		
	mov		integer, 0 

	_num_loop: 
    mov     EAX, int_array[EBX]				
    mov     EDX, integer				
    IMUL    EDX, 10							; Create a 10's position for the most recently indexed value
    mov     integer, EDX
    ADD     integer, EAX					; Add the most recently indexed value in the 10's spot and store the integer in the memory variable out_int
   
	; PRINT OPTION TO SEE WHAT THE HECK IS GOING ON 
	; mov		EAX, integer
	; call	WriteDec  
	; call	CrLf

	ADD     EBX, 4 
    loop    _num_loop
	JMP     _check_sign 

	_check_sign: 
    cmp       sign_flag, 1					; check is sign flag is set 
    JE        _make_neg 
    JMP       _exit						

	_make_neg:								; calls NEG instruction to convert the integer representation of the user input to be the two's complement 
    mov     EAX, integer
    NEG     EAX 
    mov     integer, EAX					; two's complement value of integer saved in integer 
	mov		EAX, integer
;	call	WriteInt   
;	call	CrLf

	_exit:
	mov		EDI, [out_int]
	mov		EAX, integer
	mov		[EDI],EAX						; return the integer representation of the user input
	mov		sign_flag, 0					; reset the sign flag 

	; restore the pushed registers 
	POP		EDI
	POP		ESI 
	POP		EBX
	POP		EAX 
	POP		ECX
	POP		EDX 

ENDM

mDisplayString MACRO string 
	PUSH EDX 

	mov		EDX, string 
	CALL	WriteString

	POP EDX 
ENDM 

mEmptyString MACRO string_used, string_empty
  
  MOV   ESI, string_empty
  MOV   EDI, string_used
  MOV   ECX, 20
  
  REP   MOVSB				; Copies the empty string into the used string 

ENDM 

.data

intro_1				BYTE "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ", 0 
intro_2				BYTE "Written by: Catherine Potgieter", 0 
rules_1				BYTE "Please provide 10 signed decimal integers.", 0 
rules_2				BYTE "Each number needs to be small enough to fit inside a 32 bit register.",13,10 
					BYTE "After you have finished inputting the raw numbers I will display a list of the integers,",13, 10 
					BYTE "their sum, and their average value.",0

prompt_str			BYTE "Please enter a signed number: ",0
error_message		BYTE "ERROR: You did not enter a signed number or your number was too big.",0 
try_again			BYTE "Please try again: ",0  
user_input			BYTE 20 Dup(?)
user_out			BYTE 20 Dup(?) 
outString			BYTE 20 Dup(?) 
string_empty		BYTE 20 Dup(?) 

input_result		BYTE "You entered the following numbers: ",0 
sum_result			BYTE "The sum of these numbers is: ",0 
ave_result			BYTE "The truncated average is: ", 0 
bye					BYTE "This is the last project of the term and therefore the last game we will play together.",13,10
					BYTE "Farewell and all the best on your future endevors!",13,10,0 

user_int_array		SDWORD	10 DUP(?) 
out_int				SDWORD	?
user_sums			SDWORD	? 
ave_nums			SDWORD	? 
array_len 			DWORD	LengthOf user_int_array
ave_len 			DWORD	1
sum_len 			DWORD	1 

.code
main PROC

; introduce the program, programmer, and program description
	PUSH	OFFSET intro_1 
	PUSH	OFFSET intro_2 
	PUSH	OFFSET rules_1 
	PUSH	OFFSET rules_2 
	CALL	introduction 

; Get the inputs from the user 
	; ReadVal will be called within a loop in main to get the 10 integers and validate the inputs  
	; Stores these numeric values in an array
	mov		EBX, 0 
	mov		EDI, OFFSET user_int_array
	mov		ECX, 10 
	PUSH	EBX
_get_inputs: 
	PUSH	OFFSET user_input
	PUSH	OFFSET try_again
	PUSH	OFFSET error_message
	PUSH	OFFSET prompt_str
	PUSH	OFFSET out_int
	CALL	ReadVal 

	mov		EAX, out_int
	POP		EBX
	mov		user_int_array[EBX], EAX  
	ADD		EBX, 4 
	PUSH	EBX 
	ADD		user_sums, EAX 
	mov		out_int, 0 
	LOOP	_get_inputs
	POP		EBX											; Clear the stack 

;	Calculate the average of the user inputs 		
	PUSH	user_sums 
	PUSH	OFFSET ave_nums 
	CALL	AveNums 

;	Display the results 
;	Sum of Nums (sum_result)
	PUSH	OFFSET string_empty							; used to reset the string 
	PUSH	OFFSET outString							; the string that will be printed from 
	PUSH	OFFSET user_out 
	PUSH	sum_len
	PUSH	OFFSET user_sums
	PUSH	OFFSET sum_result
	CALL	WriteVal


;	Average of nums (ave_result)
	PUSH	OFFSET string_empty							; used to reset the string 
	PUSH	OFFSET outString							; the string that will be printed from 
	PUSH	OFFSET user_out 
	PUSH	ave_len
	PUSH	OFFSET ave_nums
	PUSH	OFFSET ave_result
	CALL	WriteVal
	
;	Array of nums (input_result) - index the array to get individual value and push to the stack 
	PUSH	OFFSET outString
	PUSH	OFFSET user_out 
	PUSH	array_len
	PUSH	OFFSET sum_len								;user_input_array
	PUSH	OFFSET input_result
	CALL	WriteVal

  
;	Say goodbye to the user 
	PUSH	OFFSET bye 
	CALL	farewell 


	Invoke ExitProcess,0								; exit to operating system
main ENDP

;--------------------------------------------------------------------------------- 
; Name: introduction - introduces the program and the program rules to the user 
; Preconditions: intro_1 ([EBP+20]), intro_2 ([EBP+16]), rules_1 ([EBP+12]) , and  rules_2 ([EBP+8]), are pushed to the stack in the described order 
; Postconditions: EDX changed 
; Receives: NA
; Returns: NA 
; --------------------------------------------------------------------------------- 
introduction PROC 
  PUSH  EBP						; Preserve EBP
  mov   EBP, ESP				; Assign static stack-frame pointer

  mov	EDX, [EBP+20] 
  call	WriteString				; introduce the program name 
  call	CrLf  
  mov	EDX, [EBP+16]
  call	WriteString				; introduce the programmer 
  call	CrLf 
  call	CrLf
  mov	EDX, [EBP+12]
  call	WriteString				; tell the user you're going to ask them for 10 integers 
  call	CrLf 
  mov	EDX, [EBP+8] 
  call	WriteString				; introduce the rules of the integer inputs and the return results 
  call	CrLf
  call	CrLf  

  POP	EBP 
  RET	16 
introduction ENDP

;--------------------------------------------------------------------------------- 
; Name: ReadVal - Invokes the mGetString macro get user input in the form of a string of digits.
; It then converts (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), 
; validating the user’s input is a valid number (no letters, symbols, etc). Stores this one value in a memory 
; variable (output parameter, by reference).
;
; Preconditions: out_int [EBP+8] , prompt_str [EBP+12], error_message [EBP+16], try_again [EBP+20], user_input [EBP+24] have been 
; pushed to the stack in the described order 
; Postconditions: out_int carries the integer representation of the user input 
; Receives: a string of digits given by the user 
; Returns: the numeric value representation (SDWORD) of the user input held in the identifier out_int
; ---------------------------------------------------------------------------------
ReadVal Proc 
  PUSH  EBP						; Preserve EBP
  mov   EBP, ESP				; Assign static stack-frame pointer
  
  mGetString [EBP+8], [EBP+12], [EBP+16], [EBP+20], [EBP+24]           
  
  POP	EBP 	
  RET	20
ReadVal ENDP 

;--------------------------------------------------------------------------------- 
; Name: AveNums - Takes in an integer representing the sum of the inputed integers, calculates and stores the avaerage in ave_nums
; Preconditions: user_sums [EBP+12] and ave_nums [EBP+8] have been created and pushed to the stack in the 
; described order 
;
; Postconditions: EAX, EBX, EDX, EDI changed 
; Receives: N/A 
; Returns: the avaerage in ave_nums
; ---------------------------------------------------------------------------------
AveNums Proc 
	PUSH  EBP						; Preserve EBP
	mov   EBP, ESP					; Assign static stack-frame pointer

	mov		EAX, [EBP+12]			; Check if the sum total is a neg number 
	cmp		EAX, 0 
	JS		_neg_num				
	JMP		_find_ave 

	_neg_num: 
	mov		EAX, [EBP+12]			; Convert to a non-neg number
	NEG		EAX
	mov		EDX, 0 
	mov		EBX, 10
	IDIV	EBX						; Divide by 10 to get the average of the 10 nums 
	NEG		EAX						; Convert back to a neg num 
	mov		EDI, [EBP+8]		
	mov		[EDI], EAX				; store result in ave_nums
;	call	WriteInt   
;	call	CrLf
	JMP		_exit

	_find_ave: 
	mov		EAX, [EBP+12]			
	mov		EDX, 0 
	mov		EBX, 10
	IDIV	EBX						; Divide by 10 to get the average of the 10 nums 
	mov		EDI, [EBP+8]
	mov		[EDI], EAX				; store result in ave_nums
	  

	_exit:	
	POP	EBP 	
	RET	8
AveNums ENDP 

;--------------------------------------------------------------------------------- 
; Name: WriteVal - Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits. 
; It then invokes the mDisplayString macro to print the ascii representation of the SDWORD value to the output.
;
; Preconditions: the mDisplayString macro has been writen and is available to be called, the sring used to display a message to the user [EBP+8]
; the array offset [EBX+16]
; and the SDWORD value that needs to be converted [EBP+12] has been pushed to the stack 
; 
; Postconditions: 
; Receives: N/A 
; Returns: a string of ascii digits
; ---------------------------------------------------------------------------------
WriteVal Proc 
  PUSH  EBP						; Preserve EBP
  mov   EBP, ESP				; Assign static stack-frame pointer
  
  ; display a message to the user 
  CALL		CrLf 
  CALL		CrLf 
  mov		EDX, [EBP+8] 
  CALL		WriteString 
  CALL		CrLf


; convert the number to a string of ascii digits 
; check if the value is and array 
	mov		EAX, [EBP+16] 
	cmp		EAX, 1 	
	JE		_single_value

_array: 
;NEED TO INDEX TO EACH VALUE AND CONVERT TO AN ASCII CHAR


_single_value: 
;Check for negative values
	mov		EBX, [EBP+12]	
	mov		EAX, [EBX]								; Check if the sum total is a neg number  
	cmp		EAX, 0 
	JS		_neg_num				
	JMP		_make_string 

_neg_num: 
	mov		EDI, [EBP+12]							; USER INTEGER INPUT 
	mov		EAX, [EDI]
	neg		EAX
	mov		EDI, [EBP+20]							; STRING TO BUILD INTO 
	mov		ECX, 0 


	_neg_string_loop: 
	cmp		EAX, 0 
	JE		_neg_sign
	mov		EDX, 0 
	mov		EBX, 10
	IDIV	EBX	
	ADD		EDX, 48 
	mov		[EDI], EDX 
	ADD		EDI, 1
	ADD		ECX, 1 
	JMP		_neg_string_loop

	_neg_sign: 
	mov		EDX, 45									; add a negative sign as the first character 
	mov		[EDI], EDX 
	ADD		ECX, 1 
	JMP		_neg_rev_string

  ; Reverse the string
  ;   Set up loop counter and indexes (indices?)
_neg_rev_string: 
  mov    ESI, [EBP+20]								; STRING THAT WAS BUILD INTO (BACKWARDS) 
  add    ESI, ECX
  dec    ESI
  mov    EDI, [EBP+24]								; String to build correct format 					
  
  ;   Reverse string
_revLoopNeg:
    STD
    LODSB
    CLD
    STOSB
  LOOP   _revLoopNeg
  JMP	_print_string

_make_string:
	mov		EDI, [EBP+12]							; USER INTEGER INPUT 
	mov		EAX, [EDI]
	mov		EDI, [EBP+20]							; STRING TO BUILD INTO 
	mov		ECX, 0 

	_string_loop: 
	cmp		EAX, 0 
	JE		_rev_string
	mov		EDX, 0 
	mov		EBX, 10
	IDIV	EBX	
	ADD		EDX, 48 
	mov		[EDI], EDX 
	ADD		EDI, 1
	ADD		ECX, 1 
	JMP		_string_loop

  ; Reverse the string
  ;  Set up loop counter and indexes (indices?)
_rev_string: 
  mov    ESI, [EBP+20]								; STRING THAT WAS BUILD INTO (BACKWARDS) 
  add    ESI, ECX
  dec    ESI
  mov    EDI, [EBP+24]								; String to build correct format 					
  
  ;   Reverse string
_revLoop:
    STD
    LODSB
    CLD
    STOSB
  LOOP   _revLoop


_print_string:

	mDisplayString [EBP+24]

	mEmptyString [EBP+24], [EBP+28]
  
 
  POP	EBP 
  RET	24
WriteVal ENDP 


;--------------------------------------------------------------------------------- 
; Name: farewell - dispLays a final good bye message to the user 
; Preconditions:  bye [EBP+8] has been created and pushed to the stack 
; Postconditions: EDX has been changed 
; Receives:N/A
; Returns: N/A 
; --------------------------------------------------------------------------------- 
farewell PROC
  PUSH  EBP         ; Step 1) Preserve EBP
  mov   EBP, ESP    ; Step 2) Assign static stack-frame pointer
  CALL	CrLf 
  CALL	CrLf
  
  mov	EDX, [EBP+8]			 
  CALL	WriteString				; Says goodbye to user
  CALL	CrLf 
  CALL	CrLf

  POP	EBP 
  RET	4 
farewell ENDP

END main