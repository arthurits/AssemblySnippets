
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
    and rsp, -10h	; If needed, subtract 8 bits to align the stack to a 16-bit boundary

    ; Get the input and output devices
    call GetStdHandleIn
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdin, rax

    call GetStdHandleOut
    cmp rax, INVALID_HANDLE_VALUE
    je Exit
    mov hStdout, rax

    ; Show the first message
    mov rax, OFFSET msgUnicode
    push rax
    mov rax, OFFSET msgString
    push rax
    call UnicodeString

    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgStringChars
    mov rdx, OFFSET msgUnicode
    mov rcx, hStdout
    call WriteConsole

    ; Show the second message
    push msgStack
    mov rax, OFFSET msgStackByte
    push rax
    call UnicodeString

    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgStackByteChars
    mov rdx, msgStack
    mov rcx, hStdout
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

    mov QWORD PTR [rsp + 4*SIZEOF QWORD], NULL
    mov r9, OFFSET charsWritten
    mov r8d, msgHeapByteChars
    mov rdx, msgHeap
    mov rcx, hStdout
    call WriteConsole

    ; Call wait-key
    mov rdx, hStdout
    mov rcx, hStdin
    call WaitKey

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

    ;invoke CloseHandle,hStdin     ; not required when using GetStdHandle
    ;invoke CloseHandle,hStdout    ; not required when using GetStdHandle
    call FreeConsole

    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP


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
    ret 2*SIZEOF QWORD
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
