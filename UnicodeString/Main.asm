
ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm


.data
	hStdin QWORD 0
    hStdout QWORD 0
    
    charsRead   DWORD   0
	charsWritten DWORD	0

	msgString    BYTE    "My first message", 13, 10, "on the console.", 13, 10, 0
    msgStringLength equ $-msgString

    msgWait     BYTE    13, 10, "(Press any key to exit...)", 0
    msgWaitLength equ $-msgWait

.code

main PROC
	; Stack preliminaries
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; If needed, add 8 bits to align the stack to a 16-bit boundary

    ; Get the input device (STD_INPUT_HANDLE)
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdin, rax

    ; Get the output device (STD_OUTPUT_HANDLE)
    mov rcx, STD_OUTPUT_HANDLE
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

    ; Call wait-key
    call WaitKey

	Exit:
	mov rcx, EXIT_SUCCESS
	call ExitProcess
main ENDP


WaitKey PROC

    LOCAL chars: DWORD
    
    ; Stack alignment
	mov r15, rsp
	sub rsp, 8*4	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    cmp hStdout, 0
    jne ShowMsg
    
    ; Get the output device (STD_OUTPUT_HANDLE)
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov hStdout, rax

    cmp hStdin, 0
    jne ShowMsg

    ; Get the input device (STD_INPUT_HANDLE)
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov hStdin, rax

    ShowMsg:
    ; Show the key-press message   
    mov rcx, hStdout
    mov rdx, OFFSET msgWait
    mov r8d, msgWaitLength
    lea rax, chars
    mov r9, rax
    call WriteConsoleA

    ; Read the user-input text
    mov rcx, hStdin
    lea rax, OFFSET msgWait
    mov rdx, rax
    mov r8d, 1
    lea rax, chars
    mov r9, rax
    call ReadConsoleA

    ;mov rsp, rbp ; remove locals from stack
    ;pop rbp

    ExitWait:
    add rsp, r15	; Restore the stack pointer to point to the return address
	ret

WaitKey ENDP

END