; Programa de ejemplo en Windows :
; Programa que permite escribir una cadena en consola y verificar si tiene la letra "i", posteriormente mostrar en
; pantalla la respuesta si es así o no, mostrar la cadena y su longitud
; https://stackoverflow.com/questions/8504097/declaring-variable-sized-arrays-in-assembly

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

    ; Char buffers
    charsRead DWORD 0
    charsWritten DWORD 0

    buffer BYTE 1024 DUP(0)
    BufferSize equ $-buffer

    ; Text strings
    msgChar     BYTE    "Please enter the character to look for (press key + enter): ", 0
    msgCharLength equ $-msgChar

    msgInput    BYTE    "Please enter some text (up to 1022 chars): ", 13, 10, 0
    msgInputLength equ $-msgInput

    msgCharInput    BYTE    " ", 13, 10, 0
    msgCharInputLength equ $-msgCharInput

    msgMatch BYTE "Match found with character ' '", 0
    msgMatchLength equ $-msgMatch
    
    msgNoMatch BYTE "No match found with character ' '", 0
    msgNoMatchLength equ $-msgNoMatch
    
    msgErrorInput BYTE "Error retrieving the input handle device", 0
    msgErrorInputLength equ $-msgErrorInput

    msgErrorOutput BYTE "Error retrieving the output handle device", 0
    msgErrorOutputLength equ $-msgErrorOutput 
.code

main PROC
    ; Stack preliminaries
    sub rsp, 8*5	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; If needed, subtract 8 bits to align the stack to a 16-bit boundary

    ; Get the input device
    call GetStdHandleIn
    cmp rax, INVALID_HANDLE_VALUE
    je ErrorHandleInput
    mov hStdin, rax

    ; Get the output device
    call GetStdHandleOut
    cmp rax, INVALID_HANDLE_VALUE
    je ErrorHandleOutput
    mov hStdout, rax

    ; Request the user to enter some text
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgInputLength
    mov rdx, OFFSET msgInput
    mov rcx, hStdout
    call WriteConsoleA

    ; Read the user-input text
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsRead    ; includes the \n (13) and \r (10) chars but not the null value at the end
    mov r8d, BufferSize
    lea rbx, OFFSET buffer
    mov rdx, rbx      ; adds a null value at the end of the buffer
    mov rcx, hStdin
    call ReadConsoleA

    ; Request the user to enter a char to look for
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgCharLength
    mov rdx, OFFSET msgChar
    mov rcx, hStdout
    call WriteConsoleA

    ; Get the char
    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, 1
    lea rdx, OFFSET msgCharInput
    mov rcx, hStdin
    call ReadConsoleA
   
    ; Search any match with charTest
    mov ecx, charsRead
    ;inc rcx     ; uncomment this line in case we want to include in the loop the null character at the end of the string
    ;lea rbx, OFFSET buffer ; this addres is already in rbx
    Loop1:        
        mov al, BYTE PTR [rbx + rcx - 1]
        cmp al, msgCharInput
        je Yes
    loop Loop1

    No:     ; No match found
        mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
        mov rcx, hStdout
        mov rdx, OFFSET msgNoMatch
        mov al, msgCharInput
        mov BYTE PTR [rdx + msgNoMatchLength - 3], al
        mov r8d, msgNoMatchLength
        mov r9, OFFSET charsWritten
        call WriteConsoleA
        jmp Exit

    Yes:    ; Match found
        mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
        mov rcx, hStdout
        mov rdx, OFFSET msgMatch
        mov al, msgCharInput
        mov BYTE PTR [rdx + msgMatchLength - 3], al
        mov r8d, msgMatchLength
        mov r9, OFFSET charsWritten
        call WriteConsoleA
        jmp Exit

    ; Show the error while getting the output handle
    ErrorHandleInput:
        mov rdx, OFFSET msgErrorInput
        mov r8d, msgErrorInputLength
        jmp ErrorHandle
    
    ErrorHandleOutput:
        mov rdx, Offset msgErrorOutput
        mov r8d, msgErrorOutputLength

    ErrorHandle:
        mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
        mov rcx, hStdout
        mov r9, OFFSET charsWritten
        call WriteConsoleA

    ; Exit the application
    Exit:
        mov rdx, hStdout
        mov rcx, hStdin
        call WaitKey

        call FreeConsole

        mov rcx, EXIT_SUCCESS
        call ExitProcess

main ENDP


END
