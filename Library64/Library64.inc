COMMENT !

Include procedures definitions to use with Library64.lib

Version 1.0.1, 14/11/2021

Bug fixes:

!

externdef GetCharA:PROC
externdef GetCharW:PROC
  IFDEF __UNICODE__
    GetChar equ GetCharW
  ELSE
    GetChar equ GetCharA
  ENDIF

externdef GetStdHandleIn:PROC
externdef GetStdHandleOut:PROC
externdef StructInit:PROC

externdef StrCompareA:PROC
externdef StrCompareW:PROC
  IFDEF __UNICODE__
    StrCompare equ StrCompareW
  ELSE
    StrCompare equ StrCompareA
  ENDIF

externdef StrCopyA:PROC
externdef StrCopyW:PROC
  IFDEF __UNICODE__
    StrCopy equ StrCopyW
  ELSE
    StrCopy equ StrCopyA
  ENDIF

externdef StrLengthA:PROC
externdef StrLengthW:PROC
  IFDEF __UNICODE__
    StrLength equ StrLengthW
  ELSE
    StrLength equ StrLengthA
  ENDIF

externdef WaitKey:PROC
