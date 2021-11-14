
ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include ..\TemplateConsole\VariableDefinitions.asm
include ..\TemplateConsole\FunctionProtos.asm

; Definitions for Library64.lib
include ..\Library64\Library64.inc

.data
    hStdIn QWORD 0
    hStdOut QWORD 0
    
    charsWritten DWORD	0

    msgString   BYTE    "Implementing the C, PASCAL, STDCALL, and x64 calling conventions.", 13, 10, 0
    msgStringChars equ $-msgString

    msgCDECL        BYTE    "This message was printed using the CDECL calling convention.", 13, 10, 0
    msgCDECLChars equ $-msgCDECL
    
    msgPASCAL  BYTE    "This message was printed using the PASCAL calling convention.", 13, 10, 0
    msgPASCALChars equ $-msgPASCAL

    msgSTDCALL  BYTE    "This message was printed using the STDCALL calling convention.", 13, 10, 0
    msgSTDCALLChars equ $-msgSTDCALL

    msg64       BYTE    "This message was printed using the x64 calling convention.", 13, 10, 0
    msg64Chars equ $-msg64

.code

main PROC
    ; Stack preliminaries
    sub rsp, 8*5	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary

    ; Get the input and output devices
    call GetStdHandleIn
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdIn, rax

    call GetStdHandleOut
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdOut, rax

    ; Show the message
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgStringChars
    mov rdx, OFFSET msgString
    mov rcx, hStdOut
    call WriteConsoleA

    ; CDECL calling convention. Parameters are pushed in reverse order on the stack. Caller cleans the stack.
    mov rax, msgCDECLChars
    push rax
    mov rax, OFFSET msgCDECL
    push rax
    push hStdOut
    call CDECLconv
    add rsp, 2*(TYPE rax) + TYPE hStdOut        ; The caller has to clean the stack parameters

    ; PASCAL calling convention. Parameters are pushed in left-to-right order on the stack. Callee cleans the stack.
    push hStdOut
    mov rax, OFFSET msgPASCAL
    push rax
    mov rax, msgPASCALChars
    push rax
    call PASCALconv    ; The callee has to clean the stack parameters

    ; STDCALL calling convention. Parameters are pushed in reverse order on the stack. Callee cleans the stack.
    mov rax, msgSTDCALLChars
    push rax
    mov rax, OFFSET msgSTDCALL
    push rax
    push hStdOut
    call STDCALLconv    ; The callee has to clean the stack parameters

    ; x64 calling convention. Parameters are passed on the registers.
    mov r8, msg64Chars
    lea rdx, msg64
    mov rcx, hStdOut
    call x64conv

    Exit:
    mov rdx, hStdOut
    mov rcx, hStdIn
    call WaitKey

    call FreeConsole

    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP


CDECLconv PROC hOut:QWORD, strMSG:QWORD, strLength:QWORD
    
    LOCAL chars: DWORD

    ; Stack alignment and shallow space
    sub rsp, 8*5	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary

    ; Show the  message
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    lea r9, chars
    mov r8, strLength
    mov rdx, strMSG
    mov rcx, hOut
    call WriteConsoleA

    ret
CDECLconv ENDP


PASCALconv PROC

    LOCAL chars: DWORD

    ; Stack alignment and shallow space
    sub rsp, 8*5	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary

    ; Show the  message
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    lea r9, chars
    mov r8, [rbp + 10h]
    mov rdx, [rbp + 18h]
    mov rcx, [rbp + 20h]
    call WriteConsoleA
    
    ; Restore rsp, pop rbp, and add 8*3 to rsp
    ret 3*SIZEOF QWORD

PASCALconv ENDP


STDCALLconv PROC hOut:QWORD, strMSG:QWORD, strLength:QWORD

    LOCAL chars: DWORD

    ; Stack alignment and shallow space
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary

    ; Show the  message
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    lea r9, chars
    mov r8, strLength
    mov rdx, strMSG
    mov rcx, hOut
    call WriteConsoleA

    ret TYPE hOut + TYPE strMSG + TYPE strLength

STDCALLconv  ENDP


x64conv PROC

    LOCAL chars: DWORD

    ; Stack alignment and shallow space
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary

    ; Show the  message
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    lea r9, chars
    ;mov r8, strLength
    ;mov rdx, strMSG
    ;mov rcx, hOut
    call WriteConsoleA

    ret

x64conv ENDP

END