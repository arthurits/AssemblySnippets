; Programa de ejemplo en Windows :
; Programa que permite escribir una cadena en consola y verificar si tiene la letra "i", posteriormente mostrar en
; pantalla la respuesta si es así o no, mostrar la cadena y su longitud
; https://stackoverflow.com/questions/8504097/declaring-variable-sized-arrays-in-assembly

ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm

.data
    hStdin QWORD 0
    hStdout QWORD 0

    charTest BYTE 'i'

    ; Char buffers
    charsRead DWORD 0
    charsWritten DWORD 0

    buffer BYTE 1024 DUP(0)
    BufferSize equ $-buffer

    ; Text strings
    msgInput    BYTE    "Please enter some text (up to 1022 chars): ", 13, 10, 0
    msgInputLength equ $-msgInput

    msgMatch BYTE "Match found with character 'i'", 0
    msgMatchLength equ $-msgMatch
    
    msgNoMatch BYTE "No match found with character 'i'", 0
    msgNoMatchLength equ $-msgNoMatch
    
    msgErrorInput BYTE "Error retrieving the input handle device", 0
    msgErrorInputLength equ $-msgErrorInput

    msgErrorOutput BYTE "Error retrieving the output handle device", 0
    msgErrorOutputLength equ $-msgErrorOutput 
.code

main PROC
    ; Stack preliminaries
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; If needed, add 8 bits to align the stack to a 16-bit boundary

    ; Get the input device
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ErrorHandleInput
    mov hStdin, rax

    ; Get the output device
    mov rcx, -11
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ErrorHandleOutput
    mov hStdout, rax

    ; Request the user to enter some text
    mov rcx, hStdout
    mov rdx, OFFSET msgInput
    mov r8d, msgInputLength
    mov r9, OFFSET charsWritten
    call WriteConsoleA

    ; Read the user-input text
    mov rcx, hStdin
    lea rbx, OFFSET buffer
    mov rdx, rbx      ; adds a null value at the end of the buffer
    mov r8d, BufferSize
    mov r9, OFFSET charsRead    ; includes the \n (13) and \r (10) chars but not the null value at the end
    call ReadConsoleA

    ; Search any match with charTest
    mov ecx, charsRead
    ;inc rcx     ; uncomment this line in case we want to include in the loop the null character at the end of the string
    ;lea rbx, OFFSET buffer ; this addres is already in rbx
    Loop1:        
        mov al, BYTE PTR [rbx + rcx - 1]
        cmp al, charTest
        je Yes
    loop Loop1

    No:     ; No match found
        mov rcx, hStdout
        mov rdx, OFFSET msgNoMatch
        mov r8d, msgNoMatchLength
        mov r9, OFFSET charsWritten
        call WriteConsoleA
        jmp Exit

    Yes:    ; Match found
        mov rcx, hStdout
        mov rdx, OFFSET msgMatch
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
        mov rcx, hStdout
        mov r9, OFFSET charsWritten
        call WriteConsoleA

    ; Exit the application
    Exit:
        push hStdout
        push hStdin
        call WaitKey
        add rsp, 2*8

        call FreeConsole

        mov rcx, EXIT_SUCCESS
        call ExitProcess

main ENDP

WaitKey PROC uses r15 hIn:QWORD, hOut:QWORD

    LOCAL chars: DWORD
    LOCAL MOUSE_KEY: INPUT_RECORD    ; sizeof=0x14, align=0x4 http://masm32.com/board/index.php?topic=7676.0
    LOCAL lpEventsRead: QWORD

    .data
        msgWait     BYTE    13, 10, "(Press any key to exit...)", 0
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
    lea r9, chars
    mov r8d, msgWaitChars
    mov rdx, OFFSET msgWait
    mov rcx, hOut
    call WriteConsoleA

    ; Wait for any key pressed by the user    
    ReadInput:
    lea r9, lpEventsRead
    mov r8, 1
    lea rdx, MOUSE_KEY
    mov rcx, hIn
    call ReadConsoleInput
	cmp	MOUSE_KEY.EventType, 1  ; KEY_EVENT 0x0001
	jne ReadInput

    ExitWait:
    add rsp, r15	; Restore the stack pointer before the alignment took place
	
    ret ;mov rsp, rbp ; remove locals from stack
        ;pop rbp

WaitKey ENDP

END