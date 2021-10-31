
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
    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP

END