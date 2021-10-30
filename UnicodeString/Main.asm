
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

    msgString    BYTE    "My first Unicode message", 13, 10, "using 'lodsb' and 'stosw'.", 13, 10, 0
    msgStringLength equ $-msgString
    msgUnicode WORD msgStringLength*2 DUP(0)

    msgStackByte    BYTE    "My second Unicode message", 13, 10, "using the stack to allocate it.", 13, 10, 0
    msgStackByteLength  equ $-msgStackByte
    msgStack    QWORD   0

    msgHeapByte BYTE    "My third Unicode message", 13, 10, "using the heap to allocate it.", 13, 10, 0
    msgHeapByteLength   equ $-msgHeapByte
    msgHeap     QWORD   0

.code

main PROC
    ; Allocate space on the stack for msgStack
    mov msgStack, rsp
    sub rsp, msgStackByteLength*2
    
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
    mov r8d, msgStringLength
    shl r8d, 1
    mov r9, OFFSET charsWritten
    call WriteConsole

    ; Show the second message
    ;mov rax, OFFSET msgStack
    push msgStack
    mov rax, OFFSET msgStackByte
    push rax
    call UnicodeString
    add rsp, 8*2

    mov rcx, hStdout
    mov rdx, msgStack
    mov r8d, msgStackByteLength
    shl r8d, 1
    mov r9, OFFSET charsWritten
    call WriteConsole

    ; Show the third message
    call GetProcessHeap
    mov r8, msgHeapByteLength
    shl r8, 1
    mov rdx, NULL
    mov rcx, rax
    call HeapAlloc
    mov msgHeap, rax

    ; Convert byte string to word string
	mov DWORD PTR [rsp+40], msgHeapByteLength
	mov rax, msgHeap
	mov QWORD PTR [rsp+32], rax
	mov r9, -1			; since lpGlobal is null-terminated this (the size in bytes) can be set to -1
	mov r8, OFFSET msgHeapByte
	mov rdx, NULL
	mov rcx, CP_UTF8
	call MultiByteToWideChar

    mov rcx, hStdout
    mov rdx, msgHeap
    mov r8d, msgHeapByteLength
    shl r8d, 1
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
    call HeapFree	; Arguments: ProcessHeap, NULL, lpMem

    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP


WaitKey PROC    hIn:QWORD, hOut:QWORD

    LOCAL chars: DWORD
    LOCAL inStd: QWORD
    LOCAL outStd: QWORD

    .data
        msgWait     BYTE    13, 10, "(Press enter to exit...)", 0
        msgWaitLength equ $-msgWait

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
    mov outStd, rax

    ; Check whether hStdin is set
    CheckStdin:
    cmp hIn, 0
    jne ShowMsg

    ; Get the input device
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov inStd, rax

    ShowMsg:
    ; Show the key-press message   
    mov rcx, outStd
    mov rdx, OFFSET msgWait
    mov r8d, msgWaitLength
    lea rax, chars
    mov r9, rax
    call WriteConsoleA

    ; Read the user-input text
    mov rcx, inStd
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


; Convert an ansi string into unicode. Sourced from: http://masm32.com/board/index.php?topic=6259.0
UnicodeString PROC  ansiArg: QWORD, ucArg: QWORD
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
