;outfile attrib.exe
;name attrib
 
; Attrib
;
; Script to quickly set the FileAttribute
; of many files in a dir.
;
; Usage:
; Push "Dir"
; Call Attrib
;
; Notice that SetFileAttributes cannot take
; variables as "Attribute" so edit the script
; if you want some other attribute(s) to be
; assigned to the files.
;
; This might be a handy script when copying
; files from CD that need to be edited later.
;
; By: Hendri Adriaens
;     HendriAdriaens@hotmail.com
 
;Section
; The demo zip includes two text-files.
; Check that they are "read-only" and
; then compile and run the script.
;Push $EXEDIR\prob
;Call Attrib
;Sectionend
 
Function Attrib
  Exch $1 ; Dir
  Push $2
  Push $3
  FindFirst $2 $3 "$1\*.*"
  StrCmp $3 "" exitloop
  loop:
  StrCmp $3 "" exitloop
  StrCmp $3 "." next
  StrCmp $3 ".." next
  IfFileExists "$1\$3\*.*" next
  ; SetFileAttributes does not accept variables as attribute,
  ; so manually set this to the necessary value.
  SetFileAttributes "$1\$3" 0
  next:
  FindNext $2 $3
  Goto loop
  exitloop:
  FindClose $2
  Pop $3
  Pop $2
  Pop $1
FunctionEnd