; Programa de ejemplo en Windows :
; Programa que permite escribir una cadena en consola y verificar si tiene la letra "i", posteriormente mostrar en
; pantalla la respuesta si es así o no, mostrar la cadena y su longitud

ifndef __UNICODE__
__UNICODE__ equ 1
endif


; EXIT_SUCESS
EXIT_SUCCESS EQU <0>

; BOOL WINAPI ReadConsole(
    ;   _In_     HANDLE  hConsoleInput,
    ;   _Out_    LPVOID  lpBuffer,
    ;   _In_     DWORD   nNumberOfCharsToRead,
    ;   _Out_    LPDWORD lpNumberOfCharsRead,
    ;   _In_opt_ LPVOID  pInputControl
    ; );
extern ReadConsoleA:PROC; Version ASCII

; BOOL WINAPI WriteConsole(
    ;   _In_             HANDLE  hConsoleOutput,
    ;   _In_       const VOID* lpBuffer,
    ;   _In_             DWORD   nNumberOfCharsToWrite,
    ;   _Out_            LPDWORD lpNumberOfCharsWritten,
    ;   _Reserved_       LPVOID  lpReserved
    ; );
extern WriteConsoleA:PROC; Version ASCII

; void ExitProcess(
    ;   UINT uExitCode
    ; );
extern ExitProcess:PROC

extern GetStdHandle : PROC

.DATA
buffer BYTE 1024 DUP(0)
bufferSize DWORD 1024
bufferRead DWORD 0
tmp DWORD 0

hStdin DWORD 0
hStdout DWORD 0

msgBuffer1 DB "Hay vocales de tipo i", 0
msgBuffer2 DB "No hay vocales de tipo i", 0

.CODE
main PROC
mov rcx, -10
call GetStdHandle
mov hStdin, eax

mov rcx, -11
call GetStdHandle
mov hStdout, eax

; Leemos el mensaje.
mov ecx, hStdin
mov rdx, OFFSET buffer
mov r8d, 1024
mov r9, OFFSET bufferRead
call ReadConsoleA

; Buscamos coincidencia de 'i'
mov ecx, bufferRead
dec rcx
LOOP1 :
cmp[buffer + rcx], 'i'
je YES
loop LOOP1

NO :
mov ecx, hStdout
mov rdx, OFFSET msgBuffer2
mov r8d, 25
mov r9, OFFSET tmp
call WriteConsoleA
jmp EXIT

YES : ; Hay coincidencia
; Mostramos el mensaje por la pantalla.
mov ecx, hStdout
mov rdx, OFFSET msgBuffer1
mov r8d, 22
mov r9, OFFSET tmp
call WriteConsoleA

EXIT :
mov rcx, EXIT_SUCCESS
call ExitProcess
main ENDP
END