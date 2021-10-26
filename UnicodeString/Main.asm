
ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm


.data
	hStdout QWORD 0
    
	charsWritten DWORD	0

	msgString    BYTE    "My first message", 13, 10, "on the console.", 13, 10, 0
    msgStringLength equ $-msgString


.code

main PROC
	; Stack preliminaries
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; If needed, add 8 bits to align the stack to a 16-bit boundary

    ; Get the output device (STD_OUTPUT_HANDLE)
    mov rcx, -11
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdout, rax

	; Show some text
    mov rcx, hStdout
    mov rdx, OFFSET msgString
    mov r8d, msgStringLength
    mov r9, OFFSET charsWritten
    call WriteConsoleA

	Exit:
	mov rcx, EXIT_SUCCESS
	call ExitProcess
main ENDP


WaitKey PROC

    LOCAL   msgWait: byte
    
    mov rcx, hStdout
    mov rdx, OFFSET msgString
    mov r8d, msgStringLength
    mov r9, OFFSET charsWritten
    call WriteConsoleA

    ; Read the user-input text
    mov rcx, hStdin
    lea rax, OFFSET buffer
    mov rdx, rax      ; adds a null value at the end of the buffer
    mov r8d, 1
    mov r9, OFFSET charsRead    ; includes the \n (13) and \r (10) chars but not the null value at the end
    call ReadConsoleA

WaitKey ENDP

END