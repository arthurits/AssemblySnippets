
ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm

.data
    hStdin QWORD 0
    hStdout QWORD 0
    
    charsWritten DWORD	0

    msgString    BYTE    "Template console project", 13, 10, 0
    msgStringChars equ $-msgString

.code

main PROC
    ; Stack preliminaries
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; If needed, add 8 bits to align the stack to a 16-bit boundary

    ; Get the input and output devices
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdin, rax

    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdout, rax

    ; Show the message
    mov rcx, hStdout
    mov rdx, OFFSET msgString
    mov r8d, msgStringChars
    mov r9, OFFSET charsWritten
    call WriteConsoleA

    Exit:
    push hStdout
    push hStdin
    call WaitKey
    add rsp, 2*8

    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP

WaitKey PROC uses r15 hIn:QWORD, hOut:QWORD

    LOCAL chars: DWORD

    .data
        msgWait     BYTE    13, 10, "(Press enter to exit...)", 0
        msgWaitChars equ $-msgWait

    .code

    ; Stack alignment
    mov r15, rsp
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
    sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    ; Check whether hStdout is set
    cmp hOut, 0
    jne CheckStdin
    
    ; Get the output device
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov hOut, rax

    ; Check whether hStdin is set
    CheckStdin:
    cmp hIn, 0
    jne ShowMsg

    ; Get the input device
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov hIn, rax

    ShowMsg:
    ; Show the key-press message   
    mov rcx, hOut
    mov rdx, OFFSET msgWait
    mov r8d, msgWaitChars
    lea rax, chars
    mov r9, rax
    call WriteConsoleA

    ; Read the user-input text
    mov rcx, hIn
    lea rax, OFFSET msgWait
    mov rdx, rax
    mov r8d, 1
    lea rax, chars
    mov r9, rax
    call ReadConsoleA

    ExitWait:
    add rsp, r15	; Restore the stack pointer before the alignment took place
	
    ret ;mov rsp, rbp ; remove locals from stack
        ;pop rbp

WaitKey ENDP

END