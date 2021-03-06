;
; ************************** win64 equates ********************************
;
TRUE	equ	1
FALSE	equ	0
NULL	equ	0
INFINITE    equ -1  ;0FFFFFFFFh

EXIT_SUCCESS    equ 0
INVALID_HANDLE_VALUE    equ -1

STD_INPUT_HANDLE    equ -10
STD_OUTPUT_HANDLE   equ -11

; MultiByteToWideChar
CP_UTF8				equ 65001	; UTF-8 translation

; Heap allocation
HEAP_ZERO_MEMORY    equ 08h

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
; ************************** String implementation ********************************
; https://www.quora.com/How-does-C++-implement-a-string

STD_STRING_A STRUCT
    UNION
        Stack   BYTE    16 DUP(0)
        Heap    QWORD   0
    ENDS
    Len         QWORD   0       ; Both return the length
    Capacity    QWORD   0       ; Provides the number of characters that can be held in the currently allocated storage
STD_STRING_A ENDS

STD_STRING_W STRUCT
    UNION
        Stack   WORD    8 DUP(0)
        Heap    QWORD   0
    ENDS
    Len         QWORD   0       ; Both return the length
    Capacity    QWORD   0       ; Provides the number of characters that can be held in the currently allocated storage
STD_STRING_W ENDS

IFDEF __UNICODE__
    STRING equ STD_STRING_W
ELSE
    STRING equ STD_STRING_A
ENDIF

;
; ************************** Win64 structs ********************************
;

COORD STRUCT
  x  WORD      ?
  y  WORD      ?
COORD ENDS

KEY_EVENT_RECORD STRUCT
  bKeyDown          DWORD ?
  wRepeatCount      WORD ?
  wVirtualKeyCode   WORD ?
  wVirtualScanCode  WORD ?
  UNION
    UnicodeChar     WORD ?
    AsciiChar       BYTE ?
  ENDS
  dwControlKeyState DWORD ?
KEY_EVENT_RECORD ENDS

MOUSE_EVENT_RECORD STRUCT
  dwMousePosition       COORD <>
  dwButtonState         DWORD      ?
  dwControlKeyState     DWORD      ?
  dwEventFlags          DWORD      ?
MOUSE_EVENT_RECORD ENDS

WINDOW_BUFFER_SIZE_RECORD STRUCT
  dwSize  COORD <>
WINDOW_BUFFER_SIZE_RECORD ENDS

MENU_EVENT_RECORD STRUCT
  dwCommandId  DWORD      ?
MENU_EVENT_RECORD ENDS

FOCUS_EVENT_RECORD STRUCT
  bSetFocus  DWORD      ?
FOCUS_EVENT_RECORD ENDS

INPUT_RECORD STRUCT
  EventType             WORD ?
  two_byte_alignment    WORD ?
  UNION
    KeyEvent                KEY_EVENT_RECORD            <>
    MouseEvent              MOUSE_EVENT_RECORD          <>
    WindowBufferSizeEvent   WINDOW_BUFFER_SIZE_RECORD   <>
    MenuEvent               MENU_EVENT_RECORD           <>
    FocusEvent              FOCUS_EVENT_RECORD          <>
  ENDS
INPUT_RECORD ENDS

