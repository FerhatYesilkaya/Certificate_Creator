#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
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

; Funktion zum Auslesen von Werten aus einer INI-Datei
Func getIniValue($sSection, $sKey, $sDefault = "")
    $sFilePath = @ScriptDir&"\configurables.ini"
    ; Überprüfen, ob die Datei existiert
    If Not FileExists($sFilePath) Then
        MsgBox(16, "Fehler", "Die INI-Datei '" & $sFilePath & "' existiert nicht.")
        Return $sDefault
    EndIf
    
    ; Auslesen des Wertes
    Local $sValue = IniRead($sFilePath, $sSection, $sKey, $sDefault)
    
    ; Überprüfen, ob der Schlüssel existiert
    If $sValue = $sDefault Then
        MsgBox(48, "Hinweis", "Der Schlüssel '" & $sKey & "' in der Sektion '" & $sSection & "' wurde nicht gefunden oder hat den Standardwert.")
        Return $sDefault
    EndIf
    
    Return $sValue
EndFunc

Func logging($level, $message, $showProgess=false, $showMessageBox=false,$flagForMessageBox=64, $doExit=false)
	If Not FileExists(GoBack(@ScriptDir,0)&"\messages.log") Then
			FileOpen(@ScriptDir & "\messages.log")
	EndIf

	FileWriteLine(GoBack(@ScriptDir,0)&"\messages.log",@YEAR&"/"&@MON&"/"&@MDAY&" - "&@HOUR&":"&@MIN&":"&@SEC&" --- "& $level & " --- "&$message)

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