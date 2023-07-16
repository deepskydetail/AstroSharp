;Copyright 2004-2016 John T. Haller
;Copyright 2008-2010 Dan Bugglin

;Website: http://portableapps.com/apps/internet/google_chrome_portable

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!define PORTABLEAPPNAME "Google Chrome Portable"
!define APPNAME "Google Chrome"
!define NAME "GoogleChromePortable"
!define VER "2.3.6.11"
!define WEBSITE "portableapps.com/apps/internet/google_chrome_portable"
!define DEFAULTEXE "chrome.exe"
!define DEFAULTAPPDIR "Chrome-bin"
!define LAUNCHERLANGUAGE "English"
!define CLSID {8A69D345-D564-463c-AFF1-A69D9E530F96}
!define CLSIDSXS {4ea16ac7-fd5a-47c3-875b-dbf4a2008c20}

; Comment out the following line to disable the splash screen.
;!define USEDEVSPLASH

;!define CHROMESXSMODE

;=== Program Details
Name "${PORTABLEAPPNAME}"
OutFile "..\..\${NAME}.exe"
Caption "${PORTABLEAPPNAME} | PortableApps.com"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey Comments "Allows ${APPNAME} to be run from a removable drive.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "Dan Bugglin, John T. Haller"
VIAddVersionKey FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey LegalTrademarks "Google Chrome is a product of Google, Inc.  Google is a trademark of Google, Inc."
VIAddVersionKey OriginalFilename "${NAME}.exe"

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user
XPStyle on
Unicode false
ManifestDPIAware true

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Include
;!include "MUI.nsh"
!include "Attrib.nsh"
!include "Registry.nsh"
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "TextFunc.nsh"
!insertmacro GetParameters
!include "WordFunc.nsh"
!insertmacro GetParent
!addplugindir .
!include "dialogs.nsh"
!addplugindir ChromePasswords\Release

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;;=== Icon & Stye ===
;!define MUI_ICON "..\..\App\AppInfo\appicon.ico"
;BrandingText "PortableApps.com - Your Digital Life, Anywhere®"
;MiscButtonText "" "" "" "$(LauncherNextButton)"
;InstallButtonText "$(LauncherNextButton)"

;=== Pages
;Page custom ShowLauncherOptions LeaveLauncherOptions "" 
;!insertmacro MUI_PAGE_INSTFILES

;=== Languages
LoadLanguageFile "${NSISDIR}\Contrib\Language files\${LAUNCHERLANGUAGE}.nlf"
!include PortableApps.comLauncherLANG_${LAUNCHERLANGUAGE}.nsh

;=== Variables
Var PROGRAMDIRECTORY
Var PROFILEDIRECTORY
Var SETTINGSDIRECTORY
Var ADDITIONALPARAMETERS
Var URI
Var EXECSTRING
Var PROGRAMEXECUTABLE
!ifdef USEDEVSPLASH
Var DISABLESPLASHSCREEN
!endif
;Var DISABLEINTELLIGENTSTART
Var CACHEINTEMP
Var IMPORTJAVA
Var RUNLOCALLY
Var WAITFORPROGRAM
Var SECONDARYLAUNCH
Var MISSINGFILEORPATH
Var ChromeVer
Var OldChromeVer
!ifdef CHROMESXSMODE
Var OldChromeVer2
Var bolCLSIDSXSExists
!endif
Var TempProfileDir
Var ReadOnlyMedia
Var OldChromeAssociation
Var PortableAppsPath
Var UsePAMLanguage
Var PortablePasswords
Var MasterPassword
Var EncryptPortablePasswords
Var bolCLSIDExists
Var bolMozillaPluginsHKLMExists
Var bolMozillaPluginsHKCUExists
Var bolGoogleChromeCrashRegistryExists
Var bolGoogleChromeBeaconRegistryExists
Var bolGoogleChromeBLFinchListRegistryExists
Var bolGoogleChromeStabilityMetricsRegistryExists
Var bolSwiftShaderExists
Var bolBrowserExitCodesExists
Var bolSoftwareRemovalToolExists
Var bolCrashpadExists
Var bolRegistryExtensionsExists
Var bolRegistryPreReadFieldTrialExists

;Var /global JavaVer
;Var /global FixJava
;Var /global OldJavaVer
;Var /global OldJavaPath
;Var /global OldJavaPath2

; Load default settings
Function INIDefaults
        StrCpy $ReadOnlyMedia "false"

	; The default exe can be in one of two places, find it.

	${If} ${FileExists} "$EXEDIR\App\${DEFAULTAPPDIR}\${DEFAULTEXE}"
		StrCpy $PROGRAMDIRECTORY "$EXEDIR\App\${DEFAULTAPPDIR}"
	${Else}
		${If} ${FileExists} "$EXEDIR\${NAME}\App\${DEFAULTAPPDIR}\${DEFAULTEXE}"
			StrCpy $PROGRAMDIRECTORY "$EXEDIR\${NAME}\App\${DEFAULTAPPDIR}"
		${EndIf}
	${EndIf}
	; If we fail, wait until we load the INI before erroring out.  We might still find it.

	StrCpy $ADDITIONALPARAMETERS ""
	StrCpy $WAITFORPROGRAM "true"
	StrCpy $PROGRAMEXECUTABLE "${DEFAULTEXE}"
	StrCpy $RUNLOCALLY "false"
!ifdef USEDEVSPLASH
	StrCpy $DISABLESPLASHSCREEN "false"
!endif
;	StrCpy $DISABLEINTELLIGENTSTART "false"
	StrCpy $PROFILEDIRECTORY "$EXEDIR\Data\profile"
	StrCpy $SETTINGSDIRECTORY "$EXEDIR\Data\settings"
        StrCpy $CACHEINTEMP "true"
        StrCpy $IMPORTJAVA "false"
        StrCpy $UsePAMLanguage "true"
	StrCpy $PortablePasswords "false"
	StrCpy $EncryptPortablePasswords "true"
FunctionEnd

; Read in INI settings
Function ReadINI
	; Prepopulate with default values
	Call INIDefaults

	${IfNot} ${FileExists} "$EXEDIR\${NAME}.ini"
		; No INI
		Return
	${EndIf}
	
	; Only read in present values
	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "${APPNAME}Directory"
	${If} $0 != ""
		StrCpy $PROGRAMDIRECTORY "$EXEDIR\$0"
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "ProfileDirectory"
	${If} $0 != ""
		StrCpy $PROFILEDIRECTORY "$EXEDIR\$0"
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "SettingsDirectory"
	${If} $0 != ""
		StrCpy $SETTINGSDIRECTORY "$EXEDIR\$0"
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "AdditionalParameters"
	${If} $0 != ""
		StrCpy $ADDITIONALPARAMETERS $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "${APPNAME}Executable"
	${If} $0 != ""
		StrCpy $PROGRAMEXECUTABLE $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "WaitForProgram"
	${If} $0 != ""
		StrCpy $WAITFORPROGRAM $0
	${EndIf}

!ifdef USEDEVSPLASH
	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "DisableSplashScreen"
	${If} $0 != ""
		StrCpy $DISABLESPLASHSCREEN $0
	${EndIf}
!endif

;	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "DisableIntelligentStart"
;	${If} $0 != ""
;		StrCpy $DISABLEINTELLIGENTSTART $0
;	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "RunLocally"
	${If} $0 != ""
		StrCpy $RUNLOCALLY $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "CacheInTemp"
	${If} $0 != ""
		StrCpy $CACHEINTEMP $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "ImportJava"
	${If} $0 != ""
		StrCpy $IMPORTJAVA $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "UsePAMLanguage"
	${If} $0 != ""
		StrCpy $UsePAMLanguage $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "PortablePasswords"
	${If} $0 != ""
		StrCpy $PortablePasswords $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\${NAME}.ini" "${NAME}" "EncryptPortablePasswords"
	${If} $0 != ""
		StrCpy $EncryptPortablePasswords $0
	${EndIf}

	; Missing values produce errors, clear them.
	ClearErrors
FunctionEnd

Function CheckForProgram
	; Make sure the program is there

	${IfNot} ${FileExists} "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"
		StrCpy $MISSINGFILEORPATH $PROGRAMEXECUTABLE
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
		Abort
	${EndIf}
FunctionEnd

; Check to see if the portable device is writable
Function CheckWritable
	ClearErrors
	FileOpen $R0 "$PROGRAMDIRECTORY\writetest.temp" w
	${If} ${Errors}
		ClearErrors
		StrCpy $ReadOnlyMedia "true"
		; Ask the user if they want to copy their profile locally
		MessageBox MB_YESNO|MB_ICONQUESTION `$(LauncherAskCopyLocal)` IDYES EndMessageBox1
			MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherNoReadOnly)`
			Abort
		EndMessageBox1:
		; Return a value for $RUNLOCALLY
		Push "true"
		Return
	${EndIf}
	FileClose $R0
	Delete "$PROGRAMDIRECTORY\writetest.temp"
	; Return a value for $RUNLOCALLY
	Push "false"
FunctionEnd

; Copy the profile locally
Function CopyLocal
	RMDir /r "$TEMP\${NAME}\"
	CreateDirectory $TEMP\${NAME}\profile
	CopyFiles /SILENT $PROFILEDIRECTORY\*.* $TEMP\${NAME}\profile

	Push $TEMP\${NAME}
	Call Attrib
FunctionEnd

; Get the chrome version, and read and cache the local chrome settings from registry
Function GetChromeSettings
	${Locate} "$PROGRAMDIRECTORY" "/L=D /M=*.*.*.* /G=0" "FoundDir"

	ReadRegStr $OldChromeVer HKCU "Software\Google\Update\Clients\${CLSID}" "pv"
	WriteRegStr HKCU "Software\Google\Update\Clients\${CLSID}" "pv" $ChromeVer

!ifdef CHROMESXSMODE
	ReadRegStr $OldChromeVer2 HKCU "Software\Google\Update\Clients\${CLSIDSXS}" "pv"
	WriteRegStr HKCU "Software\Google\Update\Clients\${CLSIDSXS}" "pv" $ChromeVer
!endif
	
	ReadRegStr $OldChromeAssociation HKCR Applications\chrome.exe\shell\open\command ""
FunctionEnd

Function FoundDir
	; Locate is buggy and incorrectly trests *.* as * so we have to check ourselves to see if the mask actually matched!
	${WordFind} $R7 "." "*" $R0
	${If} $R0 == "3"
		StrCpy $ChromeVer $R7
	${EndIf}
	Push $0
FunctionEnd

; Move a local profile back (unless running from CD) and clean up
Function MoveProfileBack
	; Keep deleted files from reappearing on portable device
	RMDir /r $TempProfileDir
	CreateDirectory $TempProfileDir

	; Excludes cache files which we don't care about
	FindFirst $0 $1 "$TEMP\${NAME}\profile\*"
	${While} $1 != ""
		${If} ${FileExists} "$TEMP\${NAME}\profile\$1\Cache"
			RMDir /r "$TEMP\${NAME}\profile\$1\Cache"
		${EndIf}
		${If} ${FileExists} "$TEMP\${NAME}\profile\$1\Media Cache"
			RMDir /r "$TEMP\${NAME}\profile\$1\Media Cache"
		${EndIf}		
		FindNext $0 $1
	${EndWhile}
	FindClose $0

	CopyFiles /SILENT "$TEMP\${NAME}\profile\*" "$TempProfileDir"

	RMDir /r "$TEMP\${NAME}\profile\"
FunctionEnd

Function SetUpAdditionalPlugins
	${GetParent} $EXEDIR $PortableAppsPath
	${If} ${FileExists} "$PortableAppsPath\CommonFiles\Java\bin\plugin2\*.*"
		System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("JAVA_HOME", "$PortableAppsPath\CommonFiles\Java").r0'
		StrCpy $ADDITIONALPARAMETERS `$ADDITIONALPARAMETERS --extra-plugin-dir="$PortableAppsPath\CommonFiles\Java\bin\plugin2"`
	${ElseIf} ${FileExists} "$PortableAppsPath\CommonFiles\Java\bin\new_plugin\*.*"
		System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("JAVA_HOME", "$PortableAppsPath\CommonFiles\Java").r0'
		StrCpy $ADDITIONALPARAMETERS `$ADDITIONALPARAMETERS --extra-plugin-dir="$PortableAppsPath\CommonFiles\Java\bin\new_plugin"`
	${EndIf}
	${If} ${FileExists} "$PortableAppsPath\CommonFiles\Silverlight\files\*.*"
		StrCpy $ADDITIONALPARAMETERS `$ADDITIONALPARAMETERS --extra-plugin-dir="$PortableAppsPath\CommonFiles\Silverlight\files"`
	${EndIf}
	${If} ${FileExists} "$PortableAppsPath\CommonFiles\Flash\files\*.*"
		StrCpy $ADDITIONALPARAMETERS `$ADDITIONALPARAMETERS --extra-plugin-dir="$PortableAppsPath\CommonFiles\Flash\files"`
	${EndIf}
	${If} ${FileExists} "$PortableAppsPath\CommonFiles\BrowserPlugins\*.*"
		StrCpy $ADDITIONALPARAMETERS `$ADDITIONALPARAMETERS --extra-plugin-dir="$PortableAppsPath\CommonFiles\BrowserPlugins"`
	${EndIf}
FunctionEnd

; Get the language code from PortableApps Menu, if provided
Function GetLanguageCode
	${WordFind} $ADDITIONALPARAMETERS "--lang=" * $R0
	${If} $R0 > 0
		Push ""
		Return
	${EndIf}

	ClearErrors
	ReadEnvStr $R0 "PortableApps.comLanguageCode"
	${If} ${Errors}
		Push ""
		Return		
	${EndIf}

	${If} ${FileExists} "$PROGRAMDIRECTORY\$ChromeVer\Locales\$R0.dll"
		Push $R0
		Return
	${EndIf}

	${WordFind} $R0 "-" "+1" $R0
	${If} $R0 == ""
		Push ""
		Return
	${EndIf}

	${If} ${FileExists} "$PROGRAMDIRECTORY\$ChromeVer\Locales\$R0.dll"
		Push $R0
		Return
	${EndIf}

	Push ""
	Return
FunctionEnd

; http://nsis.sourceforge.net/Remove_leading_and_trailing_whitespaces_from_a_string
; Re-implemented using LogicLib
Function LTrim
	Exch $R1 ; Original string
	Push $R2

	${While} 1 == 1
		StrCpy $R2 $R1 1
		${Select} $R2
			${Case4} " " "$\r" "$\n" "$\t"
				StrCpy $R1 $R1 "" 1
				${Continue}
			${CaseElse}
				${Break}
		${EndSelect}
	${EndWhile}

	Pop $R2
	Exch $R1
FunctionEnd

Function RTrim
	Exch $R1 ; Original string
	Push $R2

	${While} 1 == 1
		StrCpy $R2 $R1 1 -1
		${Select} $R2
			${Case4} " " "$\r" "$\n" "$\t"
				StrCpy $R1 $R1 -1
				${Continue}
			${CaseElse}
				${Break}
		${EndSelect}
	${EndWhile}

	Pop $R2
	Exch $R1
FunctionEnd

Function Trim
	Call LTrim
	Call RTrim
FunctionEnd

; http://nsis.sourceforge.net/Another_String_Replace_(and_Slash/BackSlash_Converter)#StrRep
; I'm not even gonna try to rewrite this with LogicLib, I'd probably break it
Function StrRep
  Exch $R4 ; $R4 = Replacement String
  Exch
  Exch $R3 ; $R3 = String to replace (needle)
  Exch 2
  Exch $R1 ; $R1 = String to do replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R5 ; Len (needle)
  Push $R6 ; len (haystack)
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R5 $R3
  StrLen $R6 $R1
loop:
  StrCpy $R7 $R1 $R5
  StrCmp $R7 $R3 found
  StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
  StrCpy $R2 "$R2$R7"
  StrCpy $R1 $R1 $R6 1
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCpy $R1 $R1 $R6 $R5
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R2
  Pop $R1
  Pop $R4
  Exch $R3
FunctionEnd

; Fixes a Google Chrome preferences' file paths
Function FixPreferences
	Pop $R8 ; Profile name
	Pop $R1 ; New filename
	Pop $R0	; Old filename
	StrCpy $R2 "" ; Location stack

	ClearErrors
	FileOpen $R3 $R0 r ; Open old file for read
	${If} ${Errors}
		Return ; Skip on error
	${EndIf}

	ClearErrors
	FileOpen $R4 $R1 w ; Open new file for write
	${If} ${Errors}
		FileClose $R3
		Return ; Skip on error
	${EndIf}

	${While} 1 == 1 ; While we still have stuff to read
		ClearErrors
		FileRead $R3 $R5
		${If} ${Errors} ; EOF, we're done
			FileClose $R3
			FileClose $R4
			Return
		${EndIf}

		StrCpy $R6 $R5
		Push $R6
		Call Trim
		Pop $R6
		StrCpy $R7 $R6 1 -1 ; Get the character at the end of the line

		${If} $R7 == "{" ; Entering a section
			ClearErrors
			${WordFind} $R5 '"' E+2 $R7
			${IfNot} ${Errors}
				${StrFilter} $R7 - "" "" $R7
				${If} $R2 == ""
					StrCpy $R2 $R7 ; Push on the stack
				${Else}
					StrCpy $R2 "$R2 $R7" ; Push on the stack
				${EndIf}
			${EndIf}
		${Else}
			StrCpy $R7 $R6 1 ; Get the character at the start
			${If} $R7 == "}" ; Leaving a section
				ClearErrors
				${WordFind} $R2 ' ' E-1{{ $R2 ; Pop the stack
				${If} ${Errors}
					StrCpy $R2 ""
				${Else}
					Push $R2
					Call Trim
					Pop $R2
				${EndIf}
			${ElseIf} $R2 == "extensions theme images"
				; We want to manipulate paths in this section!
			
				ClearErrors
				${WordFind} $R5 '": "' E+2{{ $R6 ; Part before the path

				${IfNot} ${Errors}
					StrCpy $R7 "\\$R8\\Extensions\\"
					; A substring to look for

					; Double slashes are intentional, for some reason they
					; are escaped in Preferences
	
					ClearErrors
					${WordFind} $R5 $R7 E-1 $R9
					; Is it in the string?
					; If so we want what comes after it (image filename).
					${If} ${Errors}
						; If not, we check for the other possibility
						; Don't wanna use just $R8 cause it could be
						; any generic name that could appear multiple
						; times... trouble!

						StrCpy $R7 "\\$R8\\Cached Theme Images\\"
						ClearErrors
						${WordFind} $R5 $R7 E-1 $R9
						${If} ${Errors}
							StrCpy $R9 ""
						${EndIf}
					${EndIf}
	
					${If} $R9 != ""
						Push $PROFILEDIRECTORY ; Get the new path
						Push "\"
						Push "\\"
						Call StrRep
						Pop $9
						; Escape backslashes.  Since paths can't
						; contain quotes there's no reason to escape
						; anything else AFAIK.

						StrCpy $R5 $R6$9$R7$R9
						; R6 is what comes before, R7 and R9 what
						; after.  So put it all together.
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}

		FileWrite $R4 $R5
	${EndWhile}
FunctionEnd

; Iterates through all Preferences (technically a Chrome profile may contain serveral)
Function FixAllPreferences
	FindFirst $8 $7 "$PROFILEDIRECTORY\*"
	${While} $7 != ""
		${If} ${FileExists} "$PROFILEDIRECTORY\$7\Preferences"
			Push "$PROFILEDIRECTORY\$7\Preferences"
			Push "$PROFILEDIRECTORY\$7\Preferences.GCP"
			Push "$7"
			Call FixPreferences

			Delete "$PROFILEDIRECTORY\$7\Preferences"
			Rename "$PROFILEDIRECTORY\$7\Preferences.GCP" "$PROFILEDIRECTORY\$7\Preferences"
		${EndIf}
		FindNext $8 $7
	${EndWhile}
	FindClose $8
FunctionEnd

; Imports all passwords stored in Passwords Portable for use in Google Chrome by decrypting them with the master password and then re-encrypting them with the local user account.
Function ImportPasswords
	${If} $PortablePasswords != "true"
		Return
	${EndIf}

	FindFirst $8 $7 "$PROFILEDIRECTORY\*"
	${While} $7 != ""
		${If} ${FileExists} "$PROFILEDIRECTORY\$7\Portable Passwords"
		${AndIf} ${FileExists} "$PROFILEDIRECTORY\$7\Login Data"
			ChromePasswords::ImportPasswords "$PROFILEDIRECTORY\$7\Portable Passwords" "$PROFILEDIRECTORY\$7\Login Data" $MasterPassword
		${EndIf}
		FindNext $8 $7
	${EndWhile}
	FindClose $8
FunctionEnd

; Exports all passwords stored in Login Data by decrypting using the local user account and encrypting using our master password.
Function ExportPasswords
	${If} $PortablePasswords != "true"
		Return
	${EndIf}

	FindFirst $8 $7 "$PROFILEDIRECTORY\*"
	${While} $7 != ""
		${If} ${FileExists} "$PROFILEDIRECTORY\$7\Login Data"
			ChromePasswords::ExportPasswords "$PROFILEDIRECTORY\$7\Login Data" "$PROFILEDIRECTORY\$7\Portable Passwords" $MasterPassword
		${EndIf}
		FindNext $8 $7
	${EndWhile}
	FindClose $8
FunctionEnd

; Run the portable app
Function RunProgram
	;=== Get any passed parameters
	${GetParameters} $0

	${If} $CACHEINTEMP != "false"
		CreateDirectory $TEMP\${NAME}
		StrCpy $1 `--disk-cache-dir="$TEMP\${NAME}"`
	${Else}
		StrCpy $1 ""
	${EndIf}
	
	StrCpy $URI '$1 $0'

!ifdef CHROMESXSMODE
	StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" --chrome-sxs --user-data-dir="$PROFILEDIRECTORY"`
!else
	StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" --user-data-dir="$PROFILEDIRECTORY"`
!endif
	
	${If} $UsePAMLanguage != "false"
		Call GetLanguageCode
		Pop $0

		${If} $0 != ""
			StrCpy $EXECSTRING `$EXECSTRING --lang=$0`
		${EndIf}
	${EndIf}

	${If} $SECONDARYLAUNCH != "true"
		Call SetUpAdditionalPlugins
		Call FixAllPreferences
		Call ImportPasswords

		${registry::SaveKey} HKEY_CURRENT_USER\Software\Google\Common\Rlz $TEMP\${NAME}\rlz.reg "/A=0 /D=1 /G=1 /B=0" $0
		DeleteRegKey HKCU "Software\Google\Common\Rlz"

		ClearErrors
			
		
		${If} ${FileExists} "$LOCALAPPDATA\Google\Chrome\User Data\Crashpad"
			StrCpy $bolCrashpadExists true
		${EndIf}
		
		${If} ${FileExists} "$LOCALAPPDATA\Google\Chrome\User Data\SwiftShader"
			StrCpy $bolSwiftShaderExists true
		${EndIf}
			
		${registry::KeyExists} "HKCU\SOFTWARE\MozillaPlugins" $0
		${If} $0 == -1
			StrCpy $bolMozillaPluginsHKCUExists false
		${Else}
			StrCpy $bolMozillaPluginsHKCUExists true
		${EndIf}
		${registry::KeyExists} "HKLM\SOFTWARE\MozillaPlugins" $0
		${If} $0 == -1
			StrCpy $bolMozillaPluginsHKLMExists false
		${Else}
			StrCpy $bolMozillaPluginsHKLMExists true
		${EndIf}
		${registry::KeyExists} "HKCU\Software\Google\Chrome\BrowserCrashDumpAttempts" $0
		${If} $0 == -1
			StrCpy $bolGoogleChromeCrashRegistryExists false
		${Else}
			StrCpy $bolGoogleChromeCrashRegistryExists true
		${EndIf}
		${registry::KeyExists} "HKCU\Software\Google\Chrome\BLBeacon" $0
		${If} $0 == -1
			StrCpy $bolGoogleChromeBeaconRegistryExists false
		${Else}
			StrCpy $bolGoogleChromeBeaconRegistryExists true
			${registry::MoveKey} "HKCU\Software\Google\Chrome\BLBeacon" "HKCU\Software\Google\Chrome\BLBeacon-BackupByGoogleChromePortable" $R0
		${EndIf}
		${registry::KeyExists} "HKCU\Software\Google\Chrome\BLFinchList" $0
		${If} $0 == -1
			StrCpy $bolGoogleChromeBLFinchListRegistryExists false
		${Else}
			StrCpy $bolGoogleChromeBLFinchListRegistryExists true
			${registry::MoveKey} "HKCU\Software\Google\Chrome\BLFinchList" "HKCU\Software\Google\Chrome\BLFinchList-BackupByGoogleChromePortable" $R0
		${EndIf}	
		${registry::KeyExists} "HKCU\Software\Google\Chrome\StabilityMetrics" $0
		${If} $0 == -1
			StrCpy $bolGoogleChromeStabilityMetricsRegistryExists false
		${Else}
			StrCpy $bolGoogleChromeStabilityMetricsRegistryExists true
			${registry::MoveKey} "HKCU\Software\Google\Chrome\StabilityMetrics" "HKCU\Software\Google\Chrome\StabilityMetrics-BackupByGoogleChromePortable" $R0
		${EndIf}	
		
		${registry::KeyExists} "HKCU\Software\Google\Chrome\BrowserExitCodes" $0
		${If} $0 == -1
			StrCpy $bolBrowserExitCodesExists false
		${Else}
			StrCpy $bolBrowserExitCodesExists true
			${registry::MoveKey} "HKCU\Software\Google\Chrome\BrowserExitCodes" "HKCU\Software\Google\Chrome\BrowserExitCodes-BackupByGoogleChromePortable" $R0
		${EndIf}	
		
		${registry::KeyExists} "HKCU\Software\Google\Software Removal Tool" $0
		${If} $0 == -1
			StrCpy $bolSoftwareRemovalToolExists false
		${Else}
			StrCpy $bolSoftwareRemovalToolExists true
			${registry::MoveKey} "HKCU\Software\Google\Software Removal Tool" "HKCU\Software\Google\Software Removal Tool-BackupByGoogleChromePortable" $R0
		${EndIf}	
		
		${registry::KeyExists} "HKCU\Software\Google\Chrome\Extensions" $0
		${If} $0 == -1
			StrCpy $bolRegistryExtensionsExists false
		${Else}
			StrCpy $bolRegistryExtensionsExists true
		${EndIf}
		
		${registry::KeyExists} "HKCU\Software\Google\Chrome\PreReadFieldTrial" $0
		${If} $0 == -1
			StrCpy $bolRegistryPreReadFieldTrialExists false
		${Else}
			StrCpy $bolRegistryPreReadFieldTrialExists true
		${EndIf}
		
		${registry::KeyExists} "HKCU\Software\Google\Update\ClientState\${CLSID}" $0
		${If} $0 == -1
			StrCpy $bolCLSIDExists false
		${Else}
			StrCpy $bolCLSIDExists true
		${EndIf}
!ifdef CHROMESXSMODE
		ClearErrors
		${registry::KeyExists} "HKCU\Software\Google\Update\ClientState\${CLSIDSXS}" $0
		${If} $0 == -1
		${AndIf} $1 == ""
			StrCpy $bolCLSIDSXSExists false
		${Else}
			StrCpy $bolCLSIDSXSExists true
		${EndIf}
!endif
	${EndIf}
	
	${If} $ADDITIONALPARAMETERS != ""
		;=== Additional Parameters
		StrCpy $EXECSTRING `$EXECSTRING $ADDITIONALPARAMETERS`
	${EndIf}

	StrCpy $EXECSTRING `$EXECSTRING $URI`
	
	${If} $SECONDARYLAUNCH != "true"
	${AndIf} $WAITFORPROGRAM == "true"
		ExecWait $EXECSTRING
		
		CheckRunning:
			Sleep 2000
			FindProcDLL::FindProc "chrome.exe"                  
			StrCmp $R0 "1" CheckRunning NoLongerRunning
			
		NoLongerRunning:		
	${Else}
		; Other chrome already running
		Exec $EXECSTRING
		Return
	${EndIf}

	Call ExportPasswords

	${If} $RUNLOCALLY == "true"
		StrCpy $0 "${NAME}.exe"
		KillProc::FindProcesses

		${If} $0 > 1
			Return
		${EndIf}

		FileOpen $0 "$SETTINGSDIRECTORY\GoogleChromePortableShuttingDown" w
		FileClose $0

                ${If} $ReadOnlyMedia != "true"
			Call MoveProfileBack
		${EndIf}
	${EndIf}

	${If} $bolCLSIDExists == false
		DeleteRegKey HKCU "Software\Google\Update\ClientState\${CLSID}"
	${EndIf}
!ifdef CHROMESXSMODE
	${If} $bolCLSIDSXSExists == false
		DeleteRegKey HKCU "Software\Google\Update\ClientState\${CLSIDSXS}"
	${EndIf}
!endif

	DeleteRegKey HKCU "Software\Google\Common\Rlz"
	${If} ${FileExists} "$TEMP\${NAME}\rlz.reg"
		;${registry::RestoreKey} $TEMP\${NAME}\rlz.reg $0
		; The operation is NOT complete when it returns!
		; This results in a nasty race condition when we delete $TEMP\${NAME}
		; often before regedit.exe has started up, causing it to not find
		; the file.

		; I'll do better in one line:
		ExecWait `regedit /s "$TEMP\${NAME}\rlz.reg"`
	${EndIf}

	EnumRegValue $0 HKLM "Software\Google\Update\ClientStateMedium\${CLSID}" 0
	EnumRegValue $1 HKLM "Software\Google\Update\ClientStateMedium\${CLSID}" 1

	${If} $0 == "usagestats"
	${AndIf} $1 == ""
		DeleteRegKey /ifempty HKLM "Software\Google\Update\ClientStateMedium\${CLSID}"
		DeleteRegKey /ifempty HKLM Software\Google\Update\ClientStateMedium
	${EndIf}

!ifdef CHROMESXSMODE
	EnumRegValue $0 HKLM "Software\Google\Update\ClientStateMedium\${CLSIDSXS}" 0
	EnumRegValue $1 HKLM "Software\Google\Update\ClientStateMedium\${CLSIDSXS}" 1

	${If} $0 == "usagestats"
	${AndIf} $1 == ""
		DeleteRegKey /ifempty HKLM "Software\Google\Update\ClientStateMedium\${CLSIDSXS}"
		DeleteRegKey /ifempty HKLM Software\Google\Update\ClientStateMedium
	${EndIf}
!endif
	${If} $bolMozillaPluginsHKLMExists == false
		DeleteRegKey /ifempty HKLM Software\MozillaPlugins
	${EndIf}
	
	${IfNot} ${FileExists} "$LOCALAPPDATA\Google\Chrome\User Data\Local State"
		SetShellVarContext current
		
		${If} $bolSwiftShaderExists != true
			RMDir /r "$LOCALAPPDATA\Google\Chrome\User Data\SwiftShader"
		${EndIf}
		
		${If} $bolCrashpadExists != true
			RMDir /r "$LOCALAPPDATA\Google\Chrome\User Data\Crashpad"
		${EndIf}

		RMDir "$LOCALAPPDATA\Google\Chrome\User Data"
		RMDir "$LOCALAPPDATA\Google\Chrome"
		RMDir "$LOCALAPPDATA\Google"
		; This is safe since without /r the directories will only be removed if empty
	${EndIf}

	${If} ${FileExists} "$PROGRAMDIRECTORY\debug.log"
		Delete "$PROGRAMDIRECTORY\debug.log"
	${EndIf}

	${If} ${FileExists} "$TEMP\${NAME}"
		RMDir /r "$TEMP\${NAME}\"
	${EndIf}
	${If} ${FileExists} "$SETTINGSDIRECTORY\GoogleChromePortableShuttingDown"
		Delete "$SETTINGSDIRECTORY\GoogleChromePortableShuttingDown"
	${EndIf}

	${If} $OldChromeVer == ""
		DeleteRegKey HKCU "Software\Google\Update\Clients\${CLSID}"
	${Else}
		WriteRegStr HKCU "Software\Google\Update\Clients\${CLSID}" "pv" $OldChromeVer
	${EndIf}
!ifdef CHROMESXSMODE
	${If} $OldChromeVer2 == ""
		DeleteRegKey HKCU "Software\Google\Update\Clients\${CLSIDSXS}"
	${Else}
		WriteRegStr HKCU "Software\Google\Update\Clients\${CLSIDSXS}" "pv" $OldChromeVer2
	${EndIf}
!endif

	DeleteRegKey /ifempty HKCU Software\Google\Update\ClientState
	DeleteRegKey /ifempty HKCU Software\Google\Update\Clients

	EnumRegValue $0 HKCU Software\Google\Update 0
	${If} $0 == ""
		DeleteRegKey /ifempty HKCU Software\Google\Update
	${EndIf}
	
	DeleteRegKey /ifempty HKCU Software\Google\Common
	
	${If} $bolGoogleChromeCrashRegistryExists == false
		DeleteRegKey HKCU Software\Google\Chrome\BrowserCrashDumpAttempts
	${EndIf}
	
	DeleteRegKey HKCU Software\Google\Chrome\BLBeacon
	${If} $bolGoogleChromeBeaconRegistryExists == true
		${registry::MoveKey} "HKCU\Software\Google\Chrome\BLBeacon-BackupByGoogleChromePortable" "HKCU\Software\Google\Chrome\BLBeacon" $R0
	${EndIf}
	
	DeleteRegKey HKCU Software\Google\Chrome\BLFinchList
	${If} $bolGoogleChromeBLFinchListRegistryExists == true
		${registry::MoveKey} "HKCU\Software\Google\Chrome\BLFinchList-BackupByGoogleChromePortable" "HKCU\Software\Google\Chrome\BLFinchList" $R0
	${EndIf}
	
	DeleteRegKey HKCU Software\Google\Chrome\StabilityMetrics
	${If} $bolGoogleChromeStabilityMetricsRegistryExists == true
		${registry::MoveKey} "HKCU\Software\Google\Chrome\StabilityMetrics-BackupByGoogleChromePortable" "HKCU\Software\Google\Chrome\StabilityMetrics" $R0
	${EndIf}
	
	DeleteRegKey HKCU Software\Google\Chrome\BrowserExitCodes
	${If} $bolBrowserExitCodesExists == true
		${registry::MoveKey} "HKCU\Software\Google\Chrome\BrowserExitCodes-BackupByGoogleChromePortable" "HKCU\Software\Google\Chrome\BrowserExitCodes" $R0
	${EndIf}
	
	DeleteRegKey HKCU "Software\Google\Software Removal Tool"
	${If} $bolSoftwareRemovalToolExists == true
		${registry::MoveKey} "HKCU\Software\Google\Software Removal Tool-BackupByGoogleChromePortable" "HKCU\Software\Google\Software Removal Tool" $R0
	${EndIf}
	
	${If} $bolRegistryExtensionsExists == false
		DeleteRegKey HKCU "Software\Google\Chrome\Extensions"
	${EndIf}
	
	${If} $bolRegistryPreReadFieldTrialExists == false
		DeleteRegKey HKCU "Software\Google\Chrome\PreReadFieldTrial"
	${EndIf}
	
	DeleteRegKey /ifempty HKCU Software\Google\Chrome
	DeleteRegKey /ifempty HKCU Software\Google
	${If} $bolMozillaPluginsHKCUExists == false
		DeleteRegKey /ifempty HKCU Software\MozillaPlugins
	${EndIf}

	${If} $OldChromeAssociation == ""
		DeleteRegKey HKCR Applications\chrome.exe
		DeleteRegKey HKCR .htm\OpenWithList\chrome.exe
		DeleteRegKey HKCR .html\OpenWithList\chrome.exe
	${Else}
		WriteRegStr HKCR Applications\chrome.exe\shell\open\command "" $OldChromeAssociation
	${EndIf}
;	${If} $FixJava == "true"
;		${If} $OldJavaVer == ""
;			DeleteRegValue HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "BrowserJavaVersion"
;		${Else}
;			WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "BrowserJavaVersion" $OldJavaVer
;		${EndIf}
;
;		${If} $OldJavaPath == ""
;			DeleteRegKey  HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$JavaVer"
;		${Else}
;			WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$JavaVer" "JavaHome" $OldJavaPath
;		${EndIf}
;
;		${If} $OldJavaPath2 == ""
;			DeleteRegKey  HKLM "SOFTWARE\JavaSoft\Java Plug-in\$JavaVer"
;		${Else}
;			WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Plug-in\$JavaVer" "JavaHome" $OldJavaPath2
;		${EndIf}
;	${EndIf}
FunctionEnd

; Read settings
Function Init
	Call ReadINI
	${IfNot} ${FileExists} `$PROFILEDIRECTORY\*.*`
		CreateDirectory $PROFILEDIRECTORY
		CopyFiles /SILENT `$EXEDIR\App\DefaultData\profile\*.*` $PROFILEDIRECTORY
	${EndIf}
	Call CheckForProgram

	StrCpy $TempProfileDir $PROFILEDIRECTORY

	StrCpy $0 "${NAME}.exe"
	KillProc::FindProcesses
	${If} $0 > 1
		; One of these is us.  If there is another, Google Chrome Portable is already running.
		${If} ${FileExists} $SETTINGSDIRECTORY\GoogleChromePortableShuttingDown
			; The running Google Chrome Portable is busy copying the profile back.

			MessageBox MB_ICONEXCLAMATION `$(LauncherShuttingDown)`
			Abort				
		${EndIf}

		StrCpy $SECONDARYLAUNCH "true"
	${EndIf}

	${If} ${FileExists} $SETTINGSDIRECTORY\GoogleChromePortableShuttingDown
		Delete $SETTINGSDIRECTORY\GoogleChromePortableShuttingDown
	${EndIf}

	${If} $RUNLOCALLY != "true"
		Call CheckWritable
		Pop $RUNLOCALLY
	${EndIf}

	StrCpy $MasterPassword ""

	${If} $PortablePasswords == "true"
	${AndIf} $EncryptPortablePasswords != "false"
	${AndIf} $SECONDARYLAUNCH != "true"
		${InputPwdBox} "$(LauncherOptionsHeader)" "$(LauncherOptionsIntro)" "" "32767" "$(LauncherOptionsOK)" "$(LauncherOptionsCancel)" 0
		StrCpy $MasterPassword $0

		${If} $0 == ""
			Abort
		${EndIf}

		ChromePasswords::HashPassword $MasterPassword
		Pop $0

		${If} $0 == ""
			MessageBox MB_ICONEXCLAMATION `$(LauncherDLLError)`
			StrCpy $PortablePasswords "false"
		${Else}
			${If} ${FileExists} "$SETTINGSDIRECTORY\masterpassword.hash"
				FileOpen $2 "$SETTINGSDIRECTORY\masterpassword.hash" r
				FileRead $2 $1
				FileClose $2

				${If} $0 != $1
					MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherInvalidPassword)`
					Abort
				${EndIf}
			${Else}
				${IfNot} ${FileExists} $SETTINGSDIRECTORY
					CreateDirectory $SETTINGSDIRECTORY
				${EndIf}

				FileOpen $1 "$SETTINGSDIRECTORY\masterpassword.hash" w
				FileWrite $1 $0
				FileClose $1
			${EndIf}
		${EndIf}
	${EndIf}

	${If} $RUNLOCALLY == "true"
		${If} $SECONDARYLAUNCH != "true"
			Call CopyLocal
		${EndIf}
		StrCpy $PROFILEDIRECTORY $TEMP\${NAME}\profile
	${EndIf}

	${If} $SECONDARYLAUNCH != "true"
!ifdef USEDEVSPLASH
		${If} $DISABLESPLASHSCREEN != "true"
			InitPluginsDir
			File /oname=$PLUGINSDIR\splash.jpg "${NAME}.jpg"
			newadvsplash::show /NOUNLOAD 2000 200 0 0xFF00FF /L $PLUGINSDIR\splash.jpg
		${EndIf}
!endif
		Call GetChromeSettings
	${EndIf}
FunctionEnd

Section "Main"
	Call Init
	Call RunProgram
	${registry::Unload}
SectionEnd