#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <Constants.au3>
#include <Array.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>


Func ChooseFolder()
    Local $sFolderSelectDialog, $sErrorMessage

    ; Versuche, den Ordnerauswahldialog zu öffnen
    $sFolderSelectDialog = FileSelectFolder("Select a folder", @DesktopDir, 1)

    ; Fehlerbehandlung
    If @error Then
        Switch @error
            Case 1
                $sErrorMessage = "Kein Datei ausgewählt"
            Case 2
                $sErrorMessage = "Fehler beim Öffnen des Dialogs."
            Case Else
                $sErrorMessage = "Ein unbekannter Fehler ist aufgetreten. Fehlercode: " & @error
        EndSwitch

        MsgBox($MB_ICONERROR, "Error", $sErrorMessage)
        Return ""
    Else
        Return $sFolderSelectDialog
    EndIf
EndFunc

; Funktion zum Schreiben eines Werts in eine .ini-Datei
Func WriteIniValue($sFilePath, $sSection, $sKey, $sValue)
    Local $iResult = IniWrite($sFilePath, $sSection, $sKey, $sValue)
    Return $iResult
EndFunc

; Funktion zum Auslesen von Werten aus einer INI-Datei
Func getIniValue($sFilePath, $sSection, $sKey, $sDefault = "")
    ; Überprüfen, ob die Datei existiert
    If Not FileExists($sFilePath) Then
        logging("Error", "Ini-file does not exist: "&$sFilePath, false,true,16,true)
        Return $sDefault
    EndIf
    
    ; Auslesen des Wertes
    Local $sValue = IniRead($sFilePath, $sSection, $sKey, $sDefault)
    
    ; Überprüfen, ob der Schlüssel existiert
    If $sValue = $sDefault Then
        logging("Warning", "The key '" & $sKey & "' in section '" & $sSection & "' was not found")
        Return $sDefault
    EndIf
    
    Return $sValue
EndFunc

Func logging($level, $message, $showProgess=false, $showMessageBox=false,$flagForMessageBox=64, $doExit=false)
	If Not FileExists(GoBack(@ScriptDir,1)&"\messages.log") Then
			FileOpen(GoBack(@ScriptDir,1)&"\messages.log")
	EndIf

	FileWriteLine(GoBack(@ScriptDir,1)&"\messages.log",@YEAR&"/"&@MON&"/"&@MDAY&" - "&@HOUR&":"&@MIN&":"&@SEC&" --- "& $level & " --- "&$message)

	If($showMessageBox) Then
			MsgBox($flagForMessageBox,$level,$message)
	Endif
    
    #cs
	if($showProgess) Then
			GUICtrlSetData($progrssbarLabel,$message)
	Endif
    #ce
    

	If ($doExit) Then
			Exit
	EndIf

EndFunc

Func ExecuteCMD($cmd)
    Local $iPID = Run(@ComSpec & " /c " & $cmd, @SystemDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    Local $sOutput = ""
    logging("Info","Executing CMD command: " &$cmd)
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop
    WEnd
    Return $sOutput
EndFunc

Func ReplaceStringInFile($sFilePath, $sSearchString, $sReplaceString)
    logging("Info","Replacing in file: "&$sFilePath)
    ; Prüfen, ob die Datei existiert
    If Not FileExists($sFilePath) Then
        logging("Error","File does not exist: "&$sFilePath,false,true,16,true)
        Return False
    EndIf

    ; Datei in eine Variable einlesen
    Local $sFileContent = FileRead($sFilePath)
    If @error Then
        logging("Error","Could not read file: "&$sFilePath,false,true,16,true)
        Return False
    EndIf

    ; Ersetzen des Strings
    $sFileContent = StringReplace($sFileContent, $sSearchString, $sReplaceString)

    ; Datei mit dem geänderten Inhalt überschreiben
    Local $hFile = FileOpen($sFilePath, 2)
    If $hFile = -1 Then
        logging("Error","Could not open file: "&$sFilePath,false,true,16,true)
        Return False
    EndIf

    FileWrite($hFile, $sFileContent)
    FileClose($hFile)

    logging("Info","Changed '"&$sSearchString&"' with '"&$sReplaceString&"'")
    Return True
EndFunc

Func runOpenSSlCommand($cmd, $checkFilePath, $successMessage, $errorMessage)

    Local $iPID = Run(@ComSpec & " /c " & '"'&$cmd&'"', @SystemDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    Local $sOutput = ""
    logging("Info","Executing CMD command: " &$cmd)

    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop
    WEnd

    Sleep(1000)
    ; Überprüfen, ob die Datei erfolgreich erstellt wurde
    If FileExists($checkFilePath) Then
        logging("Info",$sOutput)
    Else
        logging("Error",$errorMessage&":"&@CRLF&$sOutput,false,true,16,true)
    EndIf
EndFunc

Func ExecutePowerShell($psCmd, $isFileCommand = false)
    If ($isFileCommand) Then 
        Local $iPID = Run("powershell.exe -File " & $psCmd, @SystemDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    else
        Local $iPID = Run("powershell.exe -Command " & $psCmd, @SystemDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    endif
    Local $sOutput = ""
    logging("Info","Executing PowerShell command: " &$psCmd)
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop
    WEnd
    Return $sOutput
EndFunc


Func GoBack($path, $levels = 1)
	For $i = 1 To $levels
		; Entfernt den letzten Verzeichnistrenner und alles danach
		$pos = StringInStr($path, "\", 0, -1)
		If $pos = 0 Then
			; Wenn kein Verzeichnistrenner mehr gefunden wird, bleibt nur das Wurzelverzeichnis übrig
			Return "\"
		EndIf
		$path = StringLeft($path, $pos - 1)
	Next
	Return $path
EndFunc