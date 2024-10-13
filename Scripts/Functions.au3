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
#include <Date.au3>
#include <GuiTreeView.au3>


Func ListFiles_ToTreeView(Byref $treeHandle, $sSourceFolder, $hItem)

    Local $sFile

    ; Force a trailing \
    If StringRight($sSourceFolder, 1) <> "\" Then $sSourceFolder &= "\"

    ; Start the search
    Local $hSearch = FileFindFirstFile($sSourceFolder & "*.*")
    ; If no files found then return
    If $hSearch = -1 Then Return ; This is where we break the recursive loop <<<<<<<<<<<<<<<<<<<<<<<<<<

    ; Now run through the contents of the folder
    While 1
        ; Get next match
        $sFile = FileFindNextFile($hSearch)
        ; If no more files then close search handle and return
        If @error Then ExitLoop ; This is where we break the recursive loop <<<<<<<<<<<<<<<<<<<<<<<<<<

        ; Check if a folder
        If @extended Then
            ; If so then call the function recursively
            ListFiles_ToTreeView($treeHandle,$sSourceFolder & $sFile, _GUICtrlTreeView_AddChild($treeHandle, $hItem, $sFile))
        Else
            ; If a file than write path and name
            _GUICtrlTreeView_AddChild($treeHandle, $hItem, $sFile)
        EndIf
    WEnd

    ; Close search handle
    FileClose($hSearch)

EndFunc   ;==>ListFiles_ToTreeView

Func ChooseFolder()
    Local $sFolderSelectDialog, $sErrorMessage

    ; Versuche, den Ordnerauswahldialog zu öffnen
    $sFolderSelectDialog = FileSelectFolder("Select a folder", @DesktopDir, 1)

    ; Fehlerbehandlung
    If @error Then
        Switch @error
            Case 1
                $sErrorMessage = "No Folder selected"
            Case 2
                $sErrorMessage = "Could not open Folder Chooser"
            Case Else
                $sErrorMessage = "An unknown error occured. Errorcode: " & @error
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
Func getIniValue($sFilePath, $sSection, $sKey,$sDefault = "",$goBack=1)
    ; Überprüfen, ob die Datei existiert
    If Not FileExists($sFilePath) Then
        logging("Error", "Ini-file does not exist: "&$sFilePath,1, false,true,16,true)
        Return $sDefault
    EndIf
    
    ; Auslesen des Wertes
    Local $sValue = IniRead($sFilePath, $sSection, $sKey, $sDefault)
    
    ; Überprüfen, ob der Schlüssel existiert
    If $sValue = $sDefault Then
        logging("Warning", "The key '" & $sKey & "' in section '" & $sSection & "' was not found",$goBack)
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

Func FormatDate($sDatum, $sFormat = "dd.mm.yyyy")
    ; Erkennen, welches Trennzeichen verwendet wird ('.' oder '/')
    Local $sSeparator = "/"
    If StringInStr($sDatum, ".") Then
        $sSeparator = "."
    EndIf
    
    ; Splitte das Datum in seine Bestandteile
    Local $aDatum = StringSplit($sDatum, $sSeparator)

    ; Überprüfe, ob das Datum korrekt formatiert ist
    If $aDatum[0] <> 3 Then
        Return "Ungültiges Datum"
    EndIf
    
    ; Überprüfen, ob Jahr, Monat und Tag gültige Zahlen sind
    If Not StringIsInt($aDatum[1]) Or Not StringIsInt($aDatum[2]) Or Not StringIsInt($aDatum[3]) Then
        Return "Ungültige Zahlen im Datum"
    EndIf

    ; Konvertiere das Datum je nach gewünschtem Format
    Local $sNeuesDatum = ""
    Switch $sFormat
        Case "dd.mm.yyyy"
            $sNeuesDatum = $aDatum[3] & "." & $aDatum[2] & "." & $aDatum[1]
        Case "yyyy/mm/dd"
            $sNeuesDatum = $aDatum[3] & "/" & $aDatum[2] & "/" & $aDatum[1]
        Case Else
            Return "Ungültiges Format"
    EndSwitch
    
    ; Rückgabe des neu formatierten Datums
    Return $sNeuesDatum
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
        logging("Info","Command executed")
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
    If(GUICtrlRead($inputGUI_comboBox_locations) = "") Then
        MsgBox(48,"Warning","Please choose a location. If you want to add a loaction, you have to add an IP-Address")
        return 0
    endif
    
    If(GUICtrlRead($inputGUI_comboBox_locations) = "Add new location") Then
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

Func AddDNSLinesToFile(ByRef $list, $filepath, $subitem = 0)

    Local $length = _GUICtrlListView_GetItemCount($list)

    If($length = 0) Then 
        return 0
    endif

    For $i = 0 To $length-1 Step +1
        $item = _GUICtrlListView_GetItem($list,$i,$subitem)
        FileWriteLine($filepath,"DNS."&$i+1&" = "&$item[3])
        logging("Info","Added line: 'DNS."&$i+1&" = "&$item[3]&"' to "&$filepath)
    Next
EndFunc

Func deleteEntryFromListView(ByRef $mainListview, ByRef $locations_array, $arrayofListViews = "")
    If(UBound(_GUICtrlListView_GetSelectedIndices($mainListview,true)) <= 1) Then 
        MsgBox(64,"Info","Please selected an entry")
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
                    If Not ($locations_array = "") Then
                        _ArrayDelete($locations_array,_ArraySearch($locations_array,$delete_text))
                    endif
                endif
            Next
        Next
    endif
EndFunc

Func changeEntryToListView(Byref $inputGUI_comboBox_locations, Byref $inputGUI_inputBox_one, ByRef $mainListview)
    If(GUICtrlRead($inputGUI_inputBox_one) = "") Then
        MsgBox(48,"Warning","Please enter all information")
        return 0
    endif
    If(UBound(_GUICtrlListView_GetSelectedIndices($mainListview,true)) <= 1) Then 
        MsgBox(64,"Info","Please selected an entry. You can add a common name by adding an IP-Address")
        return 0
    endif
    $change = StringSplit(_GUICtrlListView_GetSelectedIndices($mainListview),"|")
    _ArrayDelete($change,0)
    $change_location = _GUICtrlListView_GetItemText($mainListview, Number($change[0]), 0)
    _GUICtrlListView_DeleteItem($mainListview,$change[0])


    GUICtrlCreateListViewItem($change_location&"|"&GUICtrlRead($inputGUI_inputBox_one),$mainListview)

    Return 1
EndFunc

Func addToSingleColumnList(ByRef $list)
    $value = InputBox("DNS", "Enter DNS-Information:")
    if Not ($value = "") Then
        GUICtrlCreateListViewItem($value,$list)
    endif
EndFunc

Func stopProcesses($sProcessName)
    ; Holen Sie sich die Liste aller Prozesse mit dem angegebenen Namen
    Local $aProzesse = ProcessList($sProcessName)
    
    ; Überprüfen, ob Prozesse gefunden wurden
    If @error Then
        logging("Info","No process with the name: "&$sProcessName&" found",0)
        Return
    EndIf
    
    ; Durchlaufen der Prozesse und Beenden
    For $i = 1 To UBound($aProzesse) - 1
        ; Prozess-ID abrufen
        Local $pid = $aProzesse[$i][1]
        ; Prozess beenden
        ProcessClose($pid)
    Next
    
    logging("Info","Process with the name: "&$sProcessName&" stopped",0)
EndFunc

Func writeLineToFile($filepath,$text)
    FileWriteLine($filepath,$text)
    logging("Info","Added line: '"&$text&"' to "&$filepath)
EndFunc