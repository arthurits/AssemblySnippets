;
; ************************** win64 equates ********************************
;
TRUE	equ	1
FALSE	equ	0
NULL	equ	0
INFINITE    equ -1  ;0FFFFFFFFh

MB_OK               equ 0h
MB_OKCANCEL         equ 1h
MB_ABORTRETRYIGNORE	equ	2h
MB_YESNOCANCEL	    equ	3h
MB_YESNO	        equ	4h
MB_RETRYCANCEL	    equ	5h
MB_CANCELTRYCONTINUE    equ	6h
MB_HELP	            equ	4000h

MB_ICONEXCLAMATION	equ	30h
MB_ICONWARNING  	equ	30h
MB_ICONINFORMATION	equ	40h
MB_ICONASTERISK 	equ	40h
MB_ICONQUESTION 	equ	20h
MB_ICONSTOP     	equ	10h
MB_ICONERROR    	equ	10h
MB_ICONHAND     	equ	10h

EXIT_SUCCESS    equ 0
INVALID_HANDLE_VALUE    equ -1

STD_INPUT_HANDLE    equ -10
STD_OUTPUT_HANDLE   equ -11

;
; ************************** win64 types ********************************
;
IFDEF __UNICODE__
    TCHAR   typedef WORD
ELSE
    TCHAR   typedef BYTE
ENDIF

ATOM        TYPEDEF WORD

PPROC       TYPEDEF PTR PROC
DebugEventProc  TYPEDEF PTR

HRESULT     TYPEDEF DWORD
COLORREF    TYPEDEF DWORD
BOOL        TYPEDEF DWORD
DWORD32     TYPEDEF DWORD
INT32       TYPEDEF DWORD
UINT32      TYPEDEF DWORD
LONG        TYPEDEF DWORD

LPARAM      TYPEDEF QWORD
HWND        TYPEDEF QWORD
WPARAM      TYPEDEF QWORD
HANDLE      TYPEDEF QWORD
HDC         TYPEDEF QWORD
HMODULE     TYPEDEF QWORD
HINSTANCE   TYPEDEF QWORD
HBITMAP     TYPEDEF QWORD
HBRUSH      TYPEDEF QWORD
HCURSOR     TYPEDEF QWORD
HMONITOR    TYPEDEF QWORD
HICON       TYPEDEF QWORD
LPHANDLE    TYPEDEF QWORD
LPVOID      TYPEDEF QWORD
PVOID       TYPEDEF QWORD
LPSTR       TYPEDEF QWORD
LPCSTR      TYPEDEF QWORD
LPCWSTR     TYPEDEF QWORD
LPCTSTR     TYPEDEF QWORD
LPTSTR      TYPEDEF QWORD
LPBYTE      TYPEDEF QWORD

;
; ************************** Win64 structs ********************************
;
