#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIConstants.au3>
#include <Constants.au3>
#include <Array.au3>
#include <ColorConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <WinAPISysWin.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiComboBox.au3>
#include <GuiComboBoxEx.au3>
#include <GuiListView.au3>
#include <GuiListBox.au3>



Func ChooseFolder()
    Local $sFolderSelectDialog, $sErrorMessage

    ; Versuche, den Ordnerauswahldialog zu öffnen
    $sFolderSelectDialog = FileSelectFolder("Select a folder", @DesktopDir, 1)

    ; Fehlerbehandlung
    If @error Then
        Switch @error
            Case 1
                $sErrorMessage = "No File selected"
            Case 2
                $sErrorMessage = "Could not open File Chooser"
            Case Else
                $sErrorMessage = "An unknown error occured. Errorcode: " & @error
        EndSwitch

        MsgBox($MB_ICONERROR, "Error", $sErrorMessage)
        Return ""
    Else
        Return $sFolderSelectDialog
    EndIf
EndFunc

Func addInputBoxDynamically($array, $current_dns_count,$left,$top,$width,$height)
    if($current_dns_count < UBound($array)) Then
        $array[$current_dns_count] = GUICtrlCreateInput("Type here" & $current_dns_count,$left,$top,$width,$height)
        Return $current_dns_count+1
    else
        Return $current_dns_count
    endif
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

Func logging($level, $message, $goBack = 1, $showProgess=false, $showMessageBox=false,$flagForMessageBox=64, $doExit=false)
	If Not FileExists(GoBack(@ScriptDir,$goBack)&"\messages.log") Then
			FileOpen(GoBack(@ScriptDir,$goBack)&"\messages.log")
	EndIf

	FileWriteLine(GoBack(@ScriptDir,$goBack)&"\messages.log",@YEAR&"/"&@MON&"/"&@MDAY&" - "&@HOUR&":"&@MIN&":"&@SEC&" --- "& $level & " --- "&$message)

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

Func calculateReadableExpiration(ByRef $expiration_date_readable, ByRef $cb_expiration_date )

    $expirationNumber = GUICtrlRead($cb_expiration_date)

    If Mod($expirationNumber,12) = 0 Then
       Local  $years = 0

        For $i = 0 To $expirationNumber-1 Step +12
            $years = $years+1
            GUICtrlSetData($expiration_date_readable, $years & " year(s)")
        Next

    Else

        Local $years = 0

        For $i = 0 To $expirationNumber-12 Step +12
            $years = $years+1
        Next

        $months = $expirationNumber - ($years*12)

        GUICtrlSetData($expiration_date_readable, $years & " year(s) and "&$months&" month(s)")

    EndIf

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
        logging("Error",$errorMessage&":"&@CRLF&$sOutput,1,false,true,16,true)
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


Func changeCSRButtonState(ByRef $csrButton, $arrayOfElements)
    If(GUICtrlRead($csrButton) = "CSR-Only-Off") Then
        GUICtrlSetData($csrButton,"CSR-Only-On")
        GUICtrlSetBkColor($csrButton, $COLOR_GREEN)

        For $i = 0 To UBound($arrayOfElements)-1 Step +1
            GUICtrlSetState($arrayOfElements[$i],$GUI_DISABLE)
        Next
    
    Else
        GUICtrlSetData($csrButton,"CSR-Only-Off")
        GUICtrlSetBkColor($csrButton, $COLOR_RED)

        For $i = 0 To UBound($arrayOfElements)-1 Step +1
            GUICtrlSetState($arrayOfElements[$i],$GUI_ENABLE)
        Next
    endif
EndFunc


Func ArrayExpand($aArray, $vNewElement)
    ; Berechne die neue Größe
    Local $iOldSize = UBound($aArray)
    Local $iNewSize = $iOldSize + 1

    ; Erstelle ein neues Array mit der neuen Größe
    Local $aNewArray[$iNewSize]

    ; Kopiere die alten Werte ins neue Array
    For $i = 0 To $iOldSize - 1
        $aNewArray[$i] = $aArray[$i]
    Next

    ; Füge das neue Element hinzu
    $aNewArray[$iNewSize - 1] = $vNewElement

    ; Gib das neue Array zurück
    Return $aNewArray
EndFunc

Func showPassword(ByRef $rb_passphrase, ByRef $tf_passphrase, $sDefaultPassChar)
    If GUICtrlRead($rb_passphrase) = $GUI_CHECKED Then
        GUICtrlSendMsg($tf_passphrase, $EM_SETPASSWORDCHAR, 0, 0)
        _WinAPI_SetFocus(ControlGetHandle("","",$tf_passphrase))
    Else
        GUICtrlSendMsg($tf_passphrase, $EM_SETPASSWORDCHAR, $sDefaultPassChar, 0)
        _WinAPI_SetFocus(ControlGetHandle("","",$tf_passphrase))
EndIf
EndFunc

Func addEntryToListView(Byref $inputGUI_comboBox_locations, Byref $inputGUI_inputBox_one, Byref $inputGUI_inputBox_two, ByRef $mainListview, Byref $secondListView)
    If(GUICtrlRead($inputGUI_comboBox_locations) = "Add for new location") Then
        If(GUICtrlRead($inputGUI_inputBox_one) = "" Or GUICtrlRead($inputGUI_inputBox_two) = "") Then
            MsgBox(48,"Warning","Please enter all information")
            return 0
        else
            Local $newLocationtext
            _GUICtrlComboBoxEx_GetItemText($inputGUI_comboBox_locations,_GUICtrlComboBox_GetCount($inputGUI_comboBox_locations)-1,$newLocationtext)
            For $g = 0 To  _GUICtrlComboBox_GetCount($inputGUI_comboBox_locations)-1 Step +1
                _GUICtrlComboBoxEx_GetItemText($inputGUI_comboBox_locations,$g,$newLocationtext)
                if($newLocationtext = GUICtrlRead($inputGUI_inputBox_two)) Then
                    MsgBox(48,"Warning","This location already exists. Please select from dropdown")
                    Return 0
                endif
            Next 
            GUICtrlCreateListViewItem(GUICtrlRead($inputGUI_inputBox_two)&"|"&GUICtrlRead($inputGUI_inputBox_one), $mainListview)
            if Not ($secondListView = "") Then
                GUICtrlCreateListViewItem(GUICtrlRead($inputGUI_inputBox_two)&"|"&GUICtrlRead($inputGUI_inputBox_one), $secondListView)
            endif
            Return 1
        endif
    else
        If(GUICtrlRead($inputGUI_inputBox_one) = "") Then
            MsgBox(48,"Warning","Please enter all information")
            return 0
        else
            GUICtrlCreateListViewItem(GUICtrlRead($inputGUI_comboBox_locations)&"|"&GUICtrlRead($inputGUI_inputBox_one), $mainListview)
            if Not ($secondListView = "") Then
                $locationSecondListExists = false
                For $m = 0 To _GUICtrlListView_GetItemCount($secondListView)-1 Step +1
                    $current_location = _GUICtrlListView_GetItemText($secondListView, $m, 0)
                    If(GUICtrlRead($inputGUI_comboBox_locations) = $current_location) Then
                        $locationSecondListExists = true
                    else
                        $locationSecondListExists = false 
                    endif
                Next
                If ($locationSecondListExists = false) Then
                    GUICtrlCreateListViewItem(GUICtrlRead($inputGUI_comboBox_locations)&"|"&GUICtrlRead($inputGUI_inputBox_one), $secondListView)
                endif
            endif
            Return 1
        endif
    endif

EndFunc

Func deleteEntryFromListView(ByRef $mainListview, $arrayofListViews = "")
    If(UBound(_GUICtrlListView_GetSelectedIndices($mainListview,true)) <= 1) Then 
        return 0
    endif

    $delete = StringSplit(_GUICtrlListView_GetSelectedIndices($mainListview),"|")
    _ArrayDelete($delete,0)

    $delete_text = _GUICtrlListView_GetItemText($mainListview, Number($delete[0]), 0)
    For $i = 0 To UBound($delete)-1 Step +1
        _GUICtrlListView_DeleteItem($mainListview,$delete[$i])
    Next

    Local $entriesWithLocationExists = false
    For $j = 0 To _GUICtrlListView_GetItemCount($mainListview)-1 Step +1
        $current_location = _GUICtrlListView_GetItemText($mainListview, $j, 0)
        If($current_location = $delete_text) Then
            $entriesWithLocationExists = true
            ExitLoop
        else
            $entriesWithLocationExists = false
        endif
    next

    If ($arrayofListViews <> "" AND $entriesWithLocationExists = false) Then 
        For $k = 0 To UBound($arrayofListViews)-1 Step +1
            For $p = 0 To _GUICtrlListView_GetItemCount($arrayofListViews[$k])-1 Step +1
                $current_location = _GUICtrlListView_GetItemText($arrayofListViews[$k], $p, 0)
                If($current_location = $delete_text) Then
                    _GUICtrlListView_DeleteItem($arrayofListViews[$k],$p)
                    $p = $p-1
                endif
            Next
        Next
    endif
EndFunc