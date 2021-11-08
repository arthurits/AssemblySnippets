
;ifndef __UNICODE__
;__UNICODE__ equ 1
;endif
; -----------------------------------------
; 64-bit library (some routines based on Irvine64.asm)
;
; Version 1.0, 4/11/2021
; -----------------------------------------

COMMENT !

Win64 API classifies RAX,RCX,RDX,R8,R9,R10,and R11 as volatile,
so their values are not preserved across API function calls.

Bug fixes:

!

; Public procedures:
; StructInit
; StrlengthA
; StrlengthW
; WaitKey

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm

.data
    

.code

;---------------------------------------------------------
; StructInit
; Initializes a struct with 0.
; Receives: RCX pointer to the struct
;           RDX size of the struct
; Returns:  Nothing
;---------------------------------------------------------
StructInit PROC

StructInit ENDP

;---------------------------------------------------------
; StrLengthA
; Returns the length of a null-terminated string.
; Receives: RCX points to the string
; Returns: RAX = string length
;---------------------------------------------------------
StrLengthA PROC uses rdi
	mov  rdi, rcx
	mov  rax, 0     	             ; character count
    Loop1:
        cmp  BYTE PTR [rdi], 0	     ; end of string?
        je   Exit	                 ; yes: quit
        inc  rdi	                 ; no: point to next
        inc  rax	                 ; add 1 to count
	jmp  Loop1
    Exit:
        ret
StrLengthA ENDP

;---------------------------------------------------------
; StrLengthW
; Returns the length of a null-terminated string.
; Receives: RCX points to the string
; Returns: RAX = string length
;---------------------------------------------------------
StrLengthW PROC uses rdi
	mov  rdi, rcx
	mov  rax, 0     	             ; character count
    Loop1:
        cmp  WORD PTR [rdi], 0	     ; end of string?
        je   Exit	                 ; yes: quit
        add  rdi, 2                  ; no: point to next
        inc  rax	                 ; add 1 to count
	jmp  Loop1
    Exit:
        ret
StrLengthW ENDP

;---------------------------------------------------------
; WaitKey
; Waits for the user to press any key
; Receives: hIn (input handle) and hOut (output handle); they can be null
; Returns: nothing
;---------------------------------------------------------
WaitKey PROC uses r15 hIn:QWORD, hOut:QWORD

    LOCAL chars: DWORD
    LOCAL MOUSE_KEY: INPUT_RECORD    ; sizeof=0x14, align=0x4 http://masm32.com/board/index.php?topic=7676.0
    LOCAL lpEventsRead: QWORD

    .data
        msgWait     BYTE    13, 10, "(Press any key to exit...)", 0
        msgWaitChars equ $-msgWait

    .code

    ; Stack alignment
    ;mov r15, rsp
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16 bits boundary
    ;sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

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
    ;add rsp, r15	; Restore the stack pointer before the alignment took place
	
    ret ;mov rsp, rbp ; remove locals from stack
        ;pop rbp

WaitKey ENDP

END