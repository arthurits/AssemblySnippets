
;IFDEF WIN32
;   STRUCT_ALIGN   equ 4
;ELSE
;   STRUCT_ALIGN   equ 8
;ENDIF

;
; ************************** win64 equates ********************************
;
TRUE	equ	1
FALSE	equ	0
NULL	equ	0
INFINITE    equ -1  ;0FFFFFFFFh

EXIT_SUCCESS equ 0
INVALID_HANDLE_VALUE equ -1

STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11

;
; ************************** win64 types ********************************
;
IFDEF __UNICODE__
    TCHAR   typedef WORD
ELSE
    TCHAR   typedef BYTE
ENDIF

ATOM        TYPEDEF WORD

PPROC       typedef PTR PROC
DebugEventProc  TYPEDEF PTR

HRESULT     TYPEDEF DWORD
COLORREF    TYPEDEF	DWORD
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
HMODULE     typedef	QWORD
HINSTANCE   TYPEDEF QWORD
HBITMAP     TYPEDEF QWORD
HBRUSH      TYPEDEF QWORD
HCURSOR     TYPEDEF QWORD
HMONITOR    TYPEDEF QWORD
HICON       TYPEDEF QWORD
LPHANDLE    TYPEDEF QWORD
LPVOID      TYPEDEF QWORD
PVOID       TYPEDEF QWORD
LPSTR       typedef QWORD
LPCSTR      typedef	QWORD
LPCWSTR     typedef	QWORD
LPCTSTR     typedef QWORD
LPTSTR      typedef QWORD
LPBYTE      typedef QWORD

;
; ************************** Win64 structs ********************************
;
