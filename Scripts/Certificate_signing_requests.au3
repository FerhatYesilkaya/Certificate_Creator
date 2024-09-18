#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include "Functions.au3"
#RequireAdmin

$openssl_directory = getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_signing_requests|defaults","openssl_directory")
$maximum_vss_hosts = getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_signing_requests|values","maximum_vss_hosts")


        ; Create a GUI with various controls.
        Local $hGUI = GUICreate("Certificate signing requests", 340, 300)


        GUICtrlCreateLabel("OpenSSL Folder",5,5,200)
        $tf_openssl_directory = GUICtrlCreateInput($openssl_directory,5,25,200,20,$ES_READONLY)
        $btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",230,25, 100, 20)

        GUICtrlCreateLabel("Choose number of VSS hosts",5,55,200)
        $cb_number_of_vss_hosts = GUICtrlCreateCombo("",5,75,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $maximum_vss_hosts Step +1
            $data_string = $data_string & "|" & String($i)
        Next
        GUICtrlSetData($cb_number_of_vss_hosts,$data_string,1)

        GUICtrlCreateLabel("Private key passphrase",5,105,200,25)
        local $tf_passphrase = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","temporary_values","passphrase"),5,125,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD,$ES_READONLY))
        $rb_show_password = GUICtrlCreateCheckbox("Show Password",210,125)
        $sDefaultPassChar = GUICtrlSendMsg($tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        GUICtrlCreateLabel("Common name",5,155,200,25)
        local $tf_common_name = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","certificate_signing_requests|defaults","common_name"),5,175,200,20)

        $btn_start = GUICtrlCreateButton("Start", 5, 225, 320, 25)

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
    $apache_path = GUICtrlRead($tf_openssl_directory)
    
    ExecuteCMD('set OPENSSL_CONF='&GoBack($apache_path,1)&'\conf\openssl.cnf')

    If Not (FileExists(GoBack(@ScriptDir,1)&"\temp")) Then
        DirCreate(GoBack(@ScriptDir,1)&"\temp")
    endif
	
	runOpenSSlCommand('"'&GUICtrlRead($tf_openssl_directory)&'\openssl.exe" genrsa -passout pass:'&GUICtrlRead($tf_passphrase)&' -out "'&GoBack(@ScriptDir,1)&'\temp\certificate signing requests\VConnect.key" 2048',GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.key","Private key generated", "Private key could not be generated")
   
    FileCopy(GoBack(@ScriptDir,1)&"\temp\data\vanilla\openssl.cnf",GoBack(@ScriptDir,1)&"\temp\data",1)
    
    ReplaceStringInFile(GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf", "CN = default", "CN = "&GUICtrlRead($tf_common_name))
    
    runOpenSSlCommand('"'&GUICtrlRead($tf_openssl_directory)&'\openssl.exe" req -new -key "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.key"&'" -out "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.csr"&'" -passin pass:'&GUICtrlRead($tf_passphrase)&' -config "'&GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"&'"',GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VConnect.csr","CSR generated", "Could not generate CSR")

    repeatCSRforAllVSS()
EndFunc


Func repeatCSRforAllVSS()

    For $i = 0 To GUICtrlRead($cb_number_of_vss_hosts)-1 Step +1

        $vss_description = InputBox("VSS", "Enter a name for VSS"&$i+1)

        $vss_ip = InputBox("VSS","Enter IP-Address of "&$vss_description)

        runOpenSSlCommand('"'&GUICtrlRead($tf_openssl_directory)&'\openssl.exe" genrsa -passout pass:'&GUICtrlRead($tf_passphrase)&' -out "'&GoBack(@ScriptDir,1)&'\temp\certificate signing requests\VSS_'&$vss_description&'.key" 2048',GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VSS_"&$vss_description&".key","Private key generated", "Private key could not be generated")

        ReplaceStringInFile(GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf", "CN = default", "CN = "&$vss_ip)

        runOpenSSlCommand('"'&GUICtrlRead($tf_openssl_directory)&'\openssl.exe" req -new -key "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VSS_"&$vss_description&".key"&'" -out "'&GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VSS_"&$vss_description&".csr"&'" -passin pass:'&GUICtrlRead($tf_passphrase)&' -config "'&GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"&'"',GoBack(@ScriptDir,1)&"\temp\certificate signing requests\VSS_"&$vss_description&".csr","CSR generated", "Could not generate CSR")


    Next


EndFunc
