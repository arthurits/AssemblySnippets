
ifndef __UNICODE__
__UNICODE__ equ 1
endif

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm

.data
    msgString   BYTE    "My first MessageBox in Windows", 13, 10, "using ANSI text.", 0
    msgCaption   BYTE    "Well done!", 0

.code

main PROC
    ; Stack preliminaries
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; If needed, add 8 bits to align the stack to a 16-bit boundary

    mov r9, MB_ICONERROR
	mov r8, OFFSET msgCaption
	mov rdx, OFFSET msgString
	mov rcx, NULL
	call MessageBoxA

    ; Exit
    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP

END