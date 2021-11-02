
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

    msgString    BYTE    "My first Unicode message using the '.data' section to allocate it", 13, 10, "and 'lodsb' and 'stosw' instructions.", 13, 10, 0
    msgStringChars equ $-msgString
    msgUnicode TCHAR msgStringChars*SIZEOF(TCHAR) DUP(0)

    msgStackByte    BYTE    "My second Unicode message using the stack to allocate it", 13, 10, "and 'lodsb' and 'stosw' instructions.", 13, 10, 0
    msgStackByteChars  equ $-msgStackByte
    msgStack    QWORD   0

    msgHeapByte BYTE    "My third Unicode message using the heap to allocate it", 13, 10, "and calling Win32 API 'MultiByteToWideChar' function.", 13, 10, 0
    msgHeapByteChars   equ $-msgHeapByte
    msgHeap     QWORD   0

.code

main PROC
    ; Allocate space on the stack for msgStack
    mov msgStack, rsp
    sub rsp, msgStackByteChars*SIZEOF(TCHAR)
    
    ; Stack preliminaries
    sub rsp, 8*6	; Shallow space for Win32 API x64 calls
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

    ; Show the first message
    mov rax, OFFSET msgUnicode
    push rax
    mov rax, OFFSET msgString
    push rax
    call UnicodeString
    add rsp, 2*8

    mov rcx, hStdout
    mov rdx, OFFSET msgUnicode
    mov r8d, msgStringChars
    mov r9, OFFSET charsWritten
    call WriteConsole

    ; Show the second message
    push msgStack
    mov rax, OFFSET msgStackByte
    push rax
    call UnicodeString
    add rsp, 8*2

    mov rcx, hStdout
    mov rdx, msgStack
    mov r8d, msgStackByteChars
    mov r9, OFFSET charsWritten
    call WriteConsole

    ; Show the third message
    call GetProcessHeap
    mov r8, msgHeapByteChars
    shl r8, SIZEOF(TCHAR)-1
    mov rdx, NULL
    mov rcx, rax
    call HeapAlloc
    mov msgHeap, rax

    ; Convert byte string to word string
	mov DWORD PTR [rsp+40], msgHeapByteChars
	mov rax, msgHeap
	mov QWORD PTR [rsp+32], rax
	mov r9, -1			; since msgHeap is null-terminated this (the size in bytes) can be set to -1
	mov r8, OFFSET msgHeapByte
	mov rdx, NULL
	mov rcx, CP_UTF8
	call MultiByteToWideChar

    mov rcx, hStdout
    mov rdx, msgHeap
    mov r8d, msgHeapByteChars
    mov r9, OFFSET charsWritten
    call WriteConsole

    ; Call wait-key
    push hStdout
    push hStdin
    call WaitKey
    add rsp, 2*8

    Exit:
    ; Deallocate the stack space for msgStack
    mov rsp, msgStack
    ;add rsp, msgStackByteLenth*2 ; alternate way to do the same deallocation
    
    ; Deallocate the heap space for msgHeap
    call GetProcessHeap
    mov r8, msgHeap
    mov rdx, NULL
    mov rcx, rax	; ProcessHeap
    call HeapFree	; Arguments: ProcessHeap, NULL, lpMsg

    ;invoke	CloseHandle,hStdin     ; not required when using GetStdHandle
	;invoke	CloseHandle,hStdout    ; not required when using GetStdHandle
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
    mov rcx, hOut
    mov rdx, OFFSET msgWait
    mov r8d, msgWaitChars
    lea rax, chars
    mov r9, rax
    call WriteConsoleA

    ; Read the user-input text
    ;mov rcx, hIn
    ;lea rax, OFFSET msgWait
    ;mov rdx, rax
    ;mov r8d, 1
    ;lea rax, chars
    ;mov r9, rax
    ;call ReadConsoleA
    
    lea r9, lpEventsRead
    mov r8, 1
    lea rdx, MOUSE_KEY
    mov rcx, hIn
    ReadInput:
    call ReadConsoleInput   ; invoke	ReadConsoleInput,hIn,addr MOUSE_KEY,TRUE,addr Result    ; http://masm32.com/board/index.php?topic=7676.0
	cmp	MOUSE_KEY.EventType, 1  ; KEY_EVENT 0x0001
	jne ReadInput

    ExitWait:
    add rsp, r15	; Restore the stack pointer before the alignment took place
	
    ret ;mov rsp, rbp ; remove locals from stack
        ;pop rbp

WaitKey ENDP


; Convert an ansi string into unicode. Sourced from: http://masm32.com/board/index.php?topic=6259.0
UnicodeString PROC uses rsi rdi ansiArg: QWORD, ucArg: QWORD
    mov rsi, ansiArg
    mov rdi, ucArg
    xor rax, rax
    Loop1:
        lodsb
        stosw
    cmp rax, 0	; we've reached the null end-character in ansiArg
    jne Loop1
    ret
UnicodeString ENDP

END

; http://masm32.com/board/index.php?topic=6259.0
;UnicodeString MACRO ansiArg, ucArg
;  pushad
;  mov esi, ansiArg
;  mov edi, ucArg
;  xor eax, eax
;  .Repeat
;	lodsb
;	stosw
;  .Until !eax
;  popad
;  EXITM <ucArg>
;ENDM
