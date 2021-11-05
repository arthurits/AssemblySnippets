
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
    and rsp, -10h	; If needed, subtract 8 bits to align the stack to a 16-bit boundary

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
    and rsp, -10h	; Subtract 8 bits if needed to align to 16 bits boundary
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
        cmp MOUSE_KEY.EventType, 1  ; KEY_EVENT 0x0001
	jne ReadInput

    ExitWait:
    add rsp, r15	; Restore the stack pointer before the alignment took place
	
    ret ;mov rsp, rbp ; remove locals from stack
        ;pop rbp

WaitKey ENDP

END
