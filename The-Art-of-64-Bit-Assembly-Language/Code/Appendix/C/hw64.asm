includelib kernel32.lib

	extrn __imp_GetStdHandle:proc
	extrn __imp_WriteFile:proc

	.CODE
hwStr BYTE "Hello World!"
hwLen = $-hwStr

main PROC

; On entry, stack is aligned at 8 mod 16. Setting aside 8
; bytes for "bytesWritten" ensures that calls in main have
; their stack aligned to 16 bytes (8 mod 16 inside function).

	LEA RBX, hwStr
	SUB RSP, 8
	MOV RDI, RSP ; Hold # of bytes written here

; Note: must set aside 32 bytes (20h) for shadow registers for
; parameters (just do this once for all functions).
; Also, WriteFile has a 5th argument (which is NULL),
; so we must set aside 8 bytes to hold that pointer (and
; initialize it to zero). Finally, the stack must always be
; 16-byte-aligned, so reserve another 8 bytes of storage
; to ensure this.

; Shadow storage for args (always 30h bytes).
    SUB RSP, 030h

; Handle = GetStdHandle(-11);
; Single argument passed in ECX.
; Handle returned in RAX.

	MOV RCX, -11 ; STD_OUTPUT
	CALL QWORD ptr __imp_GetStdHandle

; WriteFile(handle, "Hello World!", 12, &bytesWritten, NULL);
; Zero out (set to NULL) "LPOverlapped" argument:

	MOV QWORD ptr [RSP + 4 * 8], 0 ; 5th argument on stack

	MOV R9, RDI ; Address of "bytesWritten" in R9
	MOV R8D, hwLen ; Length of string to write in R8D
	LEA RDX, hwStr ; Ptr to string data in RDX
	MOV RCX, RAX ; File handle passed in RCX
	CALL QWORD ptr __imp_WriteFile
	ADD RSP, 38h
	RET
main ENDP
	END