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
#include "Scripts\Functions.au3"
#RequireAdmin

        ; Create a GUI with various controls.
        Local $hGUI = GUICreate("Configuration", 220, 150)

        GUICtrlCreateLabel("Choose certificate-type",5,10,200)
        $cb_certificate_type = GUICtrlCreateCombo("",5,30,200,25,$CBS_DROPDOWNLIST)
        GUICtrlSetData($cb_certificate_type, "Self-signed root certificate|Certificate Signing Requests|Certificates for your hosts", "Self-signed root certificate")


        $btn_start = GUICtrlCreateButton("Confirm", 5, 100, 210, 25)

        Local $aWindow_Size = WinGetPos($hGUI)
        ConsoleWrite('Window Width  = ' & $aWindow_Size[2] & @CRLF)
        ConsoleWrite('Window Height = ' & $aWindow_Size[3] & @CRLF)
        Local $aWindowClientArea_Size = WinGetClientSize($hGUI)
        ConsoleWrite('Window Client Area Width  = ' & $aWindowClientArea_Size[0] & @CRLF)
        ConsoleWrite('Window Client Area Height = ' & $aWindowClientArea_Size[1] & @CRLF)

        ; Display the GUI.
        GUISetState(@SW_SHOW, $hGUI)

        ; Loop until the user exits.
        While 1
                Switch GUIGetMsg()
                        Case $GUI_EVENT_CLOSE
                            ExitLoop

                        Case $btn_start
							If(GUICtrlRead($cb_certificate_type) = "Self-signed root certificate") Then
								ShellExecute(@ScriptDir&"\Scripts\Self_signed_root_certificate.au3")
							endif

							If(GUICtrlRead($cb_certificate_type) = "Certificate Signing Requests") Then
								ShellExecute(@ScriptDir&"\Scripts\Certificate_signing_requests.au3")
							endif

							ExitLoop
				EndSwitch

        WEnd

        ; Delete the previous GUI and all controls.
        GUIDelete($hGUI)