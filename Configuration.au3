#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Ferhat Yesilkaya

#ce ----------------------------------------------------------------------------


#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include "Scripts\Variables.au3"
#RequireAdmin

        ; Create a GUI with various controls.
        Local $hGUI = GUICreate("Configuration", 220, 150)

        GUICtrlCreateLabel("Choose creation of:",5,10,200)
        $cb_certificate_type = GUICtrlCreateCombo("",5,30,200,25,$CBS_DROPDOWNLIST)
        GUICtrlSetData($cb_certificate_type, $name1&"|"&$name2&"|"&$name3&"|"&$name4, $name1)


        $btn_start = GUICtrlCreateButton("Confirm", 5, 100, 210, 25)

        Local $aWindow_Size = WinGetPos($hGUI)
        ConsoleWrite('Window Width  = ' & $aWindow_Size[2] & @CRLF)
        ConsoleWrite('Window Height = ' & $aWindow_Size[3] & @CRLF)
        Local $aWindowClientArea_Size = WinGetClientSize($hGUI)
        ConsoleWrite('Window Client Area Width  = ' & $aWindowClientArea_Size[0] & @CRLF)
        ConsoleWrite('Window Client Area Height = ' & $aWindowClientArea_Size[1] & @CRLF)

        ; Display the GUI.
        GUISetState(@SW_SHOW, $hGUI)

        checkFilePath()

        ; Loop until the user exits.
        While 1
                Switch GUIGetMsg()
                        Case $GUI_EVENT_CLOSE
                            ExitLoop

                        Case $btn_start
							If(GUICtrlRead($cb_certificate_type) = $name1) Then
								ShellExecute(@ScriptDir&"\Scripts\name1.au3")
							endif

							If(GUICtrlRead($cb_certificate_type) = $name2) Then
								ShellExecute(@ScriptDir&"\Scripts\name2.au3")
							endif


                                                        If(GUICtrlRead($cb_certificate_type) = $name3) Then
								ShellExecute(@ScriptDir&"\Scripts\name3.au3")
							endif


                                                        If(GUICtrlRead($cb_certificate_type) = $name4) Then
								ShellExecute(@ScriptDir&"\Scripts\name4.au3")
							endif

							ExitLoop
				EndSwitch

        WEnd

        ; Delete the previous GUI and all controls.
        GUIDelete($hGUI)

        Func checkFilePath()
                $name1Path = @ScriptDir&"\temp\"&$name1
                $name2Path = @ScriptDir&"\temp\"&$name2
                $name3Path = @ScriptDir&"\temp\"&$name3
                $name4Path = @ScriptDir&"\temp\"&$name4

                If Not (FileExists($name1Path)) Then
                        logging("Info",$name1Path & " does not exist. Creating path",0)
                        DirCreate($name1Path)
                endif

                If Not (FileExists($name2Path)) Then
                        logging("Info",$name2Path & " does not exist. Creating path",0)
                        DirCreate($name2Path)
                endif

                If Not (FileExists($name3Path)) Then
                        logging("Info",$name3Path & " does not exist. Creating path",0)
                        DirCreate($name3Path)
                endif


                If Not (FileExists($name4Path)) Then
                        logging("Info",$name4Path & " does not exist. Creating path",0)
                        DirCreate($name4Path)
                endif
        EndFunc