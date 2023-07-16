Rexe           = "R-Portable-Win\bin\Rscript.exe"
Ropts          = "--no-save --no-environ --no-init-file --no-restore --no-Rconsole"
RScriptFile    = "runShinyApp.R"
Outfile        = "ShinyApp.log" 
strCommand     = Rexe & " " & Ropts & " " & RScriptFile & " 1> " & Outfile & " 2>&1"

intWindowStyle = 0     ' Hide the window and activate another window.'
bWaitOnReturn  = False ' continue running script after launching R   '

' the following is a Sub call, so no parentheses around arguments'
CreateObject("Wscript.Shell").Run strCommand, intWindowStyle, bWaitOnReturn