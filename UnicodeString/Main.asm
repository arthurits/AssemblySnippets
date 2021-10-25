; http://masm32.com/board/index.php?topic=6259.0

ifndef __UNICODE__
__UNICODE__ equ 1
endif

ifdef __UNICODE__
    TCHAR   typedef WORD
else
    TCHAR   typedef BYTE
endif

externdef ExitProcess:PROC

.data

.code

main PROC
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
	mov rcx, 0
	call ExitProcess
main ENDP

END