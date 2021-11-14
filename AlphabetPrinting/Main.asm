
ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include ..\TemplateConsole\VariableDefinitions.asm
include ..\TemplateConsole\FunctionProtos.asm

; Definitions for Library64.lib
include ..\Library64\Library64.inc

.data
    hStdin QWORD 0
    hStdout QWORD 0
    
    charsWritten DWORD	0

    msgString    BYTE    "Printing the alphabet on the console:", 13, 10, 0
    msgStringChars equ $-msgString

.code

main PROC

    LOCAL charLetter:QWORD
    LOCAL addrLetter:QWORD

    ; Stack preliminaries
    sub rsp, 8*5	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; If needed, subtract the necessary bits to align the stack to a 16-bit boundary

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
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgStringChars
    mov rdx, OFFSET msgString
    mov rcx, hStdout
    call WriteConsoleA

    ; Loop through the alphabet and write each letter on the console
    mov rbx, "a"
    Loop1:
        cmp rbx, "z"
        je NoSpace
            mov charLetter, " "
            shl charLetter, 8
            or charLetter, rbx
            mov r8d, 2
            jmp Write
        NoSpace:
            mov charLetter, rbx
            mov r8d, 1

        Write:
        mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
        mov r9, OFFSET charsWritten
        ;mov r8d, 2
        lea rdx, charLetter
        mov rcx, hStdout
        call WriteConsoleA
        
        inc rbx
    cmp rbx, "z"
    jbe Loop1

    Exit:
    mov rdx, hStdout
    mov rcx, hStdin
    call WaitKey

    call FreeConsole

    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP

END