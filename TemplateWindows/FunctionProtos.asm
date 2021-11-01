;
; Function protos to be used only with Windows SDK libraries.
;

;
; gdi32.lib
;

;
; gdiplus.lib
;

;
; Kernel32.lib
;

; void ExitProcess(UINT uExitCode)
externdef ExitProcess:PROC

externdef GetStdHandle:PROC

; BOOL WINAPI ReadConsole(_In_ HANDLE hConsoleInput, _Out_ LPVOID lpBuffer, _In_ DWORD nNumberOfCharsToRead, _Out_ LPDWORD lpNumberOfCharsRead, _In_opt_ LPVOID pInputControl)
externdef ReadConsoleA:PROC
externdef ReadConsoleW:PROC
  IFDEF __UNICODE__
    ReadConsole equ ReadConsoleW
  ELSE
    ReadConsole equ ReadConsoleA
  ENDIF

; BOOL WINAPI WriteConsole(_In_ HANDLE hConsoleOutput, _In_ const VOID* lpBuffer, _In_ DWORD nNumberOfCharsToWrite, _Out_ LPDWORD lpNumberOfCharsWritten, _Reserved_ LPVOID lpReserved)
externdef WriteConsoleA:PROC
externdef WriteConsoleW:PROC
  IFDEF __UNICODE__
    WriteConsole equ WriteConsoleW
  ELSE
    WriteConsole equ WriteConsoleA
  ENDIF

; Ole32.lib

; shlwapi.lib

; user32.lib
externdef MessageBoxA:PROTO
externdef MessageBoxW:PROTO
  IFDEF __UNICODE__
    MessageBox equ MessageBoxW
  ELSE
    MessageBox equ MessageBoxA
  ENDIF

