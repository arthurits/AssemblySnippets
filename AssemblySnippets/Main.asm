; Programa de ejemplo en Windows :
; Programa que permite escribir una cadena en consola y verificar si tiene la letra "i", posteriormente mostrar en
; pantalla la respuesta si es así o no, mostrar la cadena y su longitud

ifndef __UNICODE__
__UNICODE__ equ 1
endif

ifdef __UNICODE__
    TCHAR   typedef WORD
else
    TCHAR   typedef BYTE
endif

; Constants and parameters
EXIT_SUCCESS EQU <0>
INVALID_HANDLE_VALUE equ -1;


; BOOL WINAPI ReadConsole(
    ;   _In_     HANDLE  hConsoleInput,
    ;   _Out_    LPVOID  lpBuffer,
    ;   _In_     DWORD   nNumberOfCharsToRead,
    ;   _Out_    LPDWORD lpNumberOfCharsRead,
    ;   _In_opt_ LPVOID  pInputControl
    ; );
;extern ReadConsoleA:PROC; Version ASCII
externdef ReadConsoleA:PROC
externdef ReadConsoleW:PROC
  IFDEF __UNICODE__
    ReadConsole equ ReadConsoleW
  ELSE
    ReadConsole equ ReadConsoleA
  ENDIF

; BOOL WINAPI WriteConsole(
    ;   _In_             HANDLE  hConsoleOutput,
    ;   _In_       const VOID* lpBuffer,
    ;   _In_             DWORD   nNumberOfCharsToWrite,
    ;   _Out_            LPDWORD lpNumberOfCharsWritten,
    ;   _Reserved_       LPVOID  lpReserved
    ; );
;extern WriteConsoleA:PROC; Version ASCII
externdef WriteConsoleA:PROC
externdef WriteConsoleW:PROC
  IFDEF __UNICODE__
    WriteConsole equ ReadConsoleW
  ELSE
    WriteConsole equ ReadConsoleA
  ENDIF

; void ExitProcess(
    ;   UINT uExitCode
    ; );
extern ExitProcess:PROC

extern GetStdHandle : PROC

.data
    hStdin QWORD 0
    hStdout QWORD 0

    charTest BYTE 'i'

    ; Buffers
    charsRead DWORD 0
    charsWritten DWORD 0
    BufferSize_init LABEL BYTE
    buffer BYTE 1024 DUP(0)
    BufferSize equ $-BufferSize_init

    ; Text strings
    msgMatchLength_init LABEL BYTE
    msgMatch BYTE "Match found with character 'i'", 0
    msgMatchLength equ $-msgMatchLength_init
    
    msgNoMatchLength_init LABEL BYTE
    msgNoMatch BYTE "No match found with character 'i'", 0
    msgNoMatchLength equ $-msgNoMatchLength_init
    
    msgErrorInputLength_init LABEL BYTE
    msgErrorInput BYTE "Error retrieving the input handle device", 0
    msgErrorInputLength equ $-msgErrorInputLength_init

    msgErrorOutputLength_init LABEL BYTE
    msgErrorOutput BYTE "Error retrieving the output handle device", 0
    msgErrorOutputLength equ $-msgErrorOutputLength_init
.code

main PROC
    ; Stack preliminaries
    sub rsp, 8*4	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; If neede, add 8 bits to align the stack to a 16-bit boundary

    ; Get the input device (STD_INPUT_HANDLE)
    mov rcx, -10
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ErrorHandleInput
    mov hStdin, rax

    ; Get the output device (STD_OUTPUT_HANDLE)
    mov rcx, -11
    call GetStdHandle
    cmp rax, INVALID_HANDLE_VALUE
    je ErrorHandleOutput
    mov hStdout, rax

    ; Read the user-input text
    mov rcx, hStdin
    mov rdx, OFFSET buffer      ; adds a null value at the end of the buffer
    mov r8d, BufferSize
    mov r9, OFFSET charsRead    ; includes the \n (13) and \r (10)
    call ReadConsoleA

    ; Search any match with charTest
    mov ecx, charsRead
    ;inc rcx     ; uncomment this line in case we want to include in the loop the null character at the end of the string
    LOOP1:
    mov al, BYTE PTR [buffer + rcx - 1]
    cmp al, charTest
    je Yes
    loop LOOP1

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
    mov rcx, EXIT_SUCCESS
    call ExitProcess

main ENDP

END