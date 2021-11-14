
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
; GetCharA          Retrieves the keyboard pressed by the user
; GetCharW          Retrieves the keyboard pressed by the user
; GetStdHandleIn    Retrieves the handle to the standard input device
; GetStdHandleOut   Retrieves the handle to the standard output device
; StructInit        Initializes a struct with 0
; StrCompareA       Compares two 1-byte strings
; StrCompareW       Compares two 2-byte strings
; StrCopyA          Copies a 1-byte string (ANSI)
; StrCopyW          Copies a 2-byte string (UNICODE)
; StrLengthA        Computes the length of a 1-byte null-terminated string
; StrLengthW        Computes the length of a 2-byte null-terminated string
; WaitKey           Waits for the user to press any key

; Includes
include VariableDefinitions.asm
include FunctionProtos.asm

.data
    

.code

;---------------------------------------------------------
; GetCharA
; Retrieves the keyboard pressed by the user.
; Receives: RCX the hStdInput
; Returns:  the ascii 1-byte code
;---------------------------------------------------------
GetCharA PROC uses rbx rcx rdx r8 r9 r15

    LOCAL MOUSE_KEY: INPUT_RECORD    ; sizeof=0x14, align=0x4 http://masm32.com/board/index.php?topic=7676.0
    LOCAL lpEventsRead: QWORD
    
    ; Stack alignment
    mov r15, rsp
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary
    sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    ; If no StdIn was passed, then get it
    mov rbx, rcx    ; save for the loop
    cmp rbx, NULL
    jne ReadInput
    call GetStdHandleIn
    mov rbx, rax

    ; Wait for any key pressed by the user    
    ReadInput:
        lea r9, lpEventsRead
        mov r8, 1
        lea rdx, MOUSE_KEY
        mov rcx, rbx
        call ReadConsoleInputA
	    cmp	MOUSE_KEY.EventType, 1  ; KEY_EVENT 0x0001
	jne ReadInput

    xor rax, rax
    mov al, MOUSE_KEY.KeyEvent.AsciiChar

    ; Restore the stack pointer before the alignment took place. This is needed because of the "uses" directive.
    add rsp, r15

    ret

GetCharA ENDP

;---------------------------------------------------------
; GetCharW
; Retrieves the keyboard pressed by the user.
; Receives: RCX the hStdInput
; Returns:  The unicode 2-byte code
;---------------------------------------------------------
GetCharW PROC uses rbx rdx r8 r9 r15

    LOCAL MOUSE_KEY: INPUT_RECORD    ; sizeof=0x14, align=0x4 http://masm32.com/board/index.php?topic=7676.0
    LOCAL lpEventsRead: QWORD

    ; Stack alignment
    mov r15, rsp
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary
    sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    mov r14, rcx    ; hStdIn

    ; If no StdIn was passed, then get it
    mov rbx, rcx    ; save for the loop
    cmp rbx, NULL
    jne ReadInput
    call GetStdHandleIn
    mov rbx, rax

    ; Wait for any key pressed by the user    
    ReadInput:
        lea r9, lpEventsRead
        mov r8, 1
        lea rdx, MOUSE_KEY
        mov rcx, rbx
        call ReadConsoleInputW
	    cmp	MOUSE_KEY.EventType, 1  ; KEY_EVENT 0x0001
	jne ReadInput

    xor rax, rax
    mov ax, MOUSE_KEY.KeyEvent.UnicodeChar
    
    ; Restore the stack pointer before the alignment took place. This is needed because of the "uses" directive.
    add rsp, r15
    ret

GetCharW ENDP

;---------------------------------------------------------
; GetStdHandleIn
; Retrieves the handle to the standard input device.
; Receives: nothing
; Returns:  RAX handle
;---------------------------------------------------------
GetStdHandleIn PROC uses rcx

    ; Stack alignment
    mov r15, rsp
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary
    sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    ; Get the input device
    mov rcx, -10    ; STD_INPUT_HANDLE
    call GetStdHandle

    ; Restore the stack pointer before the alignment took place. This is needed because of the "uses" directive.
    add rsp, r15

    ret

GetStdHandleIn ENDP

;---------------------------------------------------------
; GetStdHandleOut
; Retrieves the handle to the standard output device.
; Receives: nothing
; Returns:  RAX handle
;---------------------------------------------------------
GetStdHandleOut PROC uses rcx

    ; Stack alignment
    mov r15, rsp
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary
    sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    ; Get the input device
    mov rcx, -11    ; STD_OUTPUT_HANDLE
    call GetStdHandle

    ; Restore the stack pointer before the alignment took place. This is needed because of the "uses" directive.
    add rsp, r15

    ret

GetStdHandleOut ENDP

;---------------------------------------------------------
; StructInit
; Initializes a struct with 0.
; Receives: RCX pointer to the struct
;           RDX size of the struct
; Returns:  Nothing
;---------------------------------------------------------
StructInit PROC uses rax rcx rdx rdi

    mov     rdi, rcx
    mov     rcx, rdx
    xor     rax, rax    ; initializaton value equal to 0
    rep stosb

    ret

StructInit ENDP


; -----------------------------------------------------
; StrCompareA
; Compares two 1-byte strings
; Receives: RSI points to the source string
;           RDI points to the target string
; Returns:  Sets ZF if the strings are equal
;		    Sets CF if RSI string < RDI string
;------------------------------------------------------
StrCompareA proc uses rax rdx rsi rdi
L1: mov  al, [rsi]
    mov  dl, [rdi]
    cmp  al, 0    		; end of string1?
    jne  L2      		; no
    cmp  dl, 0    		; yes: end of string2?
    jne  L2      		; no
    jmp  L3      		; yes, exit with ZF = 1

L2: inc  rsi      		; point to next
    inc  rdi
    cmp  al, dl   		; chars equal?
    je   L1      		; yes: continue loop
                 		; no: exit with flags set
L3: ret
StrCompareA endp

; -----------------------------------------------------
; StrCompareW
; Compares two 2-byte strings
; Receives: RSI points to the source string
;           RDI points to the target string
; Returns:  Sets ZF if the strings are equal
;		    Sets CF if RSI string < RDI string
;------------------------------------------------------
StrCompareW proc uses rax rdx rsi rdi
L1: mov  ax, [rsi]
    mov  dx, [rdi]
    cmp  ax, 0    		; end of string1?
    jne  L2      		; no
    cmp  dx, 0    		; yes: end of string2?
    jne  L2      		; no
    jmp  L3      		; yes, exit with ZF = 1

L2: add  rsi, 2    		; point to next
    add  rdi, 2
    cmp  ax, dx   		; chars equal?
    je   L1      		; yes: continue loop
                 		; no: exit with flags set
L3: ret
StrCompareW endp

;-------------------------------------------------
; StrCopyA
; Copies a 1-byte string
; Receives: RCX points to the source string
;           RDX points to the target string
; Returns:  nothing, the string is copied into RDX
;-------------------------------------------------
StrCopyA proc uses rax rcx rsi rdi
 
    ; mov rcx, rcx
	call StrLengthA ; get length of source string

    mov rsi, rcx
    mov rdi, rdx
	mov rcx, rax	; repeat count
	inc rcx         ; add 1 for null byte
	cld             ; direction = up
	rep movsb      	; copy the string
    
	ret
StrCopyA endp

;-------------------------------------------------
; StrCopyW
; Copies a 2-byte string (Unicode)
; Receives: RCX points to the source string
;           RDX points to the target string
; Returns:  nothing, the string is copied into RDX
;-------------------------------------------------
StrCopyW proc uses rax rcx rsi rdi
 
    ; mov rcx, rcx
	call StrLengthW ; get length of source string

    mov rsi, rcx
    mov rdi, rdx
	mov rcx, rax	; repeat count
	add rcx, 2      ; add 1 for null byte
	cld             ; direction = up
	rep movsw      	; copy the string
    
	ret
StrCopyW endp

;---------------------------------------------------------
; StrLengthA
; Computes the length of a 1-byte null-terminated string.
; Receives: RCX points to the string
; Returns: RAX = string length (not including the null character)
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
; Computes the length of a 2-byte null-terminated string.
; Receives: RCX points to the string
; Returns: RAX = string length (not including the null character)
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
; Receives: RCX hIn (input handle) or NULL
;           RDX hOut (output handle) or NULL
; Returns: nothing
;---------------------------------------------------------
WaitKey PROC uses rax rcx rdx r8 r9 r14 r15

    LOCAL chars: DWORD
    LOCAL MOUSE_KEY: INPUT_RECORD    ; sizeof=0x14, align=0x4 http://masm32.com/board/index.php?topic=7676.0
    LOCAL lpEventsRead: QWORD

    .data
        msgWait     BYTE    13, 10, "(Press any key to exit...)", 0
        msgWaitChars equ $-msgWait

    .code

    ; Stack alignment
    mov r15, rsp
    sub rsp, 8*5	; Shallow space for Win32 API x64 calls
    and rsp, -10h	; Subtract the needed bits to align to 16-bit boundary
    sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

    mov r14, rcx    ; hStdIn
    mov r15, rdx    ; hStdOut

    ; Check whether hStdout is set
    cmp r15, NULL
    jne CheckStdin
    
    ; Get the output device
    call GetStdHandleOut
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov r15, rax

    ; Check whether hStdin is set
    CheckStdin:
    cmp r14, NULL
    jne ShowMsg

    ; Get the input device
    call GetStdHandleIn
    cmp rax, INVALID_HANDLE_VALUE
    je ExitWait
    mov r14, rax

    ShowMsg:
    ; Show the key-press message
    mov	 qword ptr [rsp + 4 * SIZEOF QWORD], NULL	; (reserved parameter, set to 0)
    lea r9, chars
    mov r8d, msgWaitChars
    mov rdx, OFFSET msgWait
    mov rcx, r15
    call WriteConsoleA

    ; Wait for any key pressed by the user
    mov rcx, r14
    call GetCharW

    ExitWait:
    add rsp, r15	; Restore the stack pointer before the alignment took place. This is needed because of the "uses" directive.
	
    ret

WaitKey ENDP

END