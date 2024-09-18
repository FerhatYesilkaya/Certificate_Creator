#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include "Functions.au3"
#RequireAdmin

$openssl_directory = getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_for_hosts|defaults","openssl_directory")
$maximum_dns = getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_for_hosts|values","maximum_dns")
$maximum_vss_hosts = getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_for_hosts|values","maximum_vss_hosts")


        ; Create a GUI with various controls.
        Local $hGUI = GUICreate("Certificate for hosts", 340, 330)


        GUICtrlCreateLabel("OpenSSL Folder",5,5,200)
        $tf_openssl_directory = GUICtrlCreateInput($openssl_directory,5,25,200,20,$ES_READONLY)
        $btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",230,25, 100, 20)

        GUICtrlCreateLabel("Choose number of DNS",5,55,200)
        $cb_number_of_dns = GUICtrlCreateCombo("",5,75,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $maximum_dns-1 Step +1
            $data_string = $data_string & "|" & String($i+1)
        Next
        GUICtrlSetData($cb_number_of_dns,$data_string,1)

        GUICtrlCreateLabel("Choose number of VSS hosts",5,105,200)
        $cb_number_of_vss_hosts = GUICtrlCreateCombo("",5,125,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string_vss = ""
        For $i = 0 To $maximum_vss_hosts Step +1
            $data_string_vss = $data_string_vss & "|" & String($i)
        Next
        GUICtrlSetData($cb_number_of_vss_hosts,$data_string_vss,1)

        GUICtrlCreateLabel("Private key passphrase",5,155,200,25)
        local $tf_passphrase = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","temporary_values","passphrase"),5,175,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD,$ES_READONLY))
        $rb_show_password = GUICtrlCreateCheckbox("Show Password",210,175)
        $sDefaultPassChar = GUICtrlSendMsg($tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        GUICtrlCreateLabel("Common name",5,205,200,25)
        local $tf_common_name = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_signing_requests|defaults","common_name"),5,225,200,20)

        $btn_start = GUICtrlCreateButton("Start", 5, 275, 320, 25)

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
                            doSteps()
                            logging("Info","Completed",false, true,64, true)

                        Case $btn_choose_lab_hub_directory
                            GUICtrlSetData($tf_openssl_directory,ChooseFolder())

                            Case $rb_show_password
                                If GUICtrlRead($rb_show_password) = $GUI_CHECKED Then
                                        GUICtrlSendMsg($tf_passphrase, $EM_SETPASSWORDCHAR, 0, 0)
                                        _WinAPI_SetFocus(ControlGetHandle("","",$tf_passphrase))
                                    Else
                                        GUICtrlSendMsg($tf_passphrase, $EM_SETPASSWORDCHAR, $sDefaultPassChar, 0)
                                        _WinAPI_SetFocus(ControlGetHandle("","",$tf_passphrase))
                                    EndIf

                EndSwitch
        WEnd

        ; Delete the previous GUI and all controls.
        GUIDelete($hGUI)


Func doSteps()

    If Not (FileExists(GoBack(@ScriptDir,1)&"\temp")) Then
        DirCreate(GoBack(@ScriptDir,1)&"\temp")
    endif

    FileCopy(GoBack(@ScriptDir,1)&"\temp\_data\vanilla\Vconnect.ext",GoBack(@ScriptDir,1)&"\temp\data",1)
        
    runOpenSSlCommand('"'&GUICtrlRead($tf_openssl_directory)&'\openssl.exe" req -new -key "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.key"&'" -out "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.csr"&'" -passin pass:'&GUICtrlRead($tf_passphrase)&' -config "'&GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"&'"',GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.csr","CSR generated", "Could not generate CSR")


EndFunc


Func repeatDNSPrompts()

    For $i = 0 To GUICtrlRead($cb_number_of_dns)-1 Step +1

        $dns = InputBox("DNS","Enter DNS"&$i+1&" Information")

        FileWriteLine(GoBack(@ScriptDir,1)&"\temp\_data\Vconnect.ext","DNS."&$i+1&" = "&$dns)

        runOpenSSlCommand('"'&GUICtrlRead($tf_openssl_directory)&'\openssl.exe" -x509 req -in "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.csr"&'" -CA "'&GoBack(@ScriptDir,1)&"\temp\self signed certificate\RocheCA.cer"&'" -CAkey "'&GoBack(@ScriptDir,1)&"\temp\self signed certificate\RocheCA.key"&'" -CAcreateserial -passin pass:'&getIniValue(GoBack(@ScriptDir,1) ,"temporary_values","passphrase")&' -config "'&GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"&'"',GoBack(@ScriptDir,1)&"\temp\self signed certificate\RocheCA.cer","Certificate generated", "Could not generate certificate")



    Next


EndFunc
