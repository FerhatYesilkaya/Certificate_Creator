#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include "Variables.au3"
#RequireAdmin

        ; Create a GUI with various controls.
        Local $hGUI = GUICreate($name2, 340, 300)


        GUICtrlCreateLabel("OpenSSL Folder",5,5,200)
        $tf_openssl_directory = GUICtrlCreateInput(getIniValue($iniFilePath,"temporary_values","open_ssl_path",$name2_default_openssl_directory),5,25,200,20,$ES_READONLY)
        $btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",230,25, 100, 20)

        GUICtrlCreateLabel("Number of DNS",5,55,200)
        $cb_number_of_dns = GUICtrlCreateCombo("",5,75,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $name2_values_maximum_vss_hosts Step +1
            $data_string = $data_string & "|" & String($i)
        Next
        GUICtrlSetData($cb_number_of_dns,$data_string,1)

        GUICtrlCreateLabel("Certificate expiration (months)",5,105,200)
        $cb_certificate_expiration = GUICtrlCreateCombo("",5,125,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $name2_values_max_expiration_certificate Step +1
            $data_string = $data_string & "|" & String($i)
        Next
        GUICtrlSetData($cb_certificate_expiration,$data_string,getIniValue($iniFilePath,"temporary_values","certificate_expiration_in_months",getIniValue($iniFilePath,"name1|defaults","expiration_certificate")))


        GUICtrlCreateLabel("Private key passphrase",5,155,200,25)
        local $tf_passphrase = GUICtrlCreateInput(getIniValue($iniFilePath,"temporary_values","passphrase"),5,175,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
        $rb_show_password = GUICtrlCreateCheckbox("Show Password",210,175)
        $sDefaultPassChar = GUICtrlSendMsg($tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        GUICtrlCreateLabel("Common name",5,205,200,25)
        local $tf_common_name = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","name2|defaults","common_name"),5,225,200,20)

        $btn_start = GUICtrlCreateButton("Start", 5, 250, 320, 25)

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
                            logging("Info","Completed",1,false, true,64, true)

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
    $t_common_name = GUICtrlRead($tf_common_name)
    $t_openSSLPath = GUICtrlRead($tf_openssl_directory)&'\openssl.exe'
    $t_VConnect_key = GoBack(@ScriptDir,1)&"\temp\"&$name2&"\VConnect.key"
    $t_VConnect_csr = GoBack(@ScriptDir,1)&"\temp\"&$name2&"\VConnect.csr"
    $t_VConnect_crt = GoBack(@ScriptDir,1)&"\temp\"&$name2&"\VConnect.crt"
    $t_roche_ca_crt = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.crt"
    $t_roche_ca_key = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.key"
    $t_vanilla_openssl_cnf = GoBack(@ScriptDir,1)&"\temp\_data\vanilla\openssl.cnf"
    $t_openssl_cnf = GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"
    $t_certificate_expiration_in_days = GUICtrlRead($cb_certificate_expiration)*30
    $t_passphrase = GUICtrlRead($tf_passphrase)
    $t_vanilla_ext = GoBack(@ScriptDir,1)&"\temp\_data\vanilla\VConnect.ext"
    $t_ext = GoBack(@ScriptDir,1)&"\temp\_data\VConnect.ext"

    ExecuteCMD('set OPENSSL_CONF='&GoBack($apache_path,1)&'\conf\openssl.cnf')

	
	runOpenSSlCommand('"'&$t_openSSLPath&'" genrsa -out "'&$t_VConnect_key&'" 2048',$t_VConnect_key,"Private key generated", "Private key could not be generated")
   
    FileCopy($t_vanilla_ext,GoBack(@ScriptDir,1)&"\temp\_data",1)

    FileWriteLine($t_ext,"IP.1 = "&$t_common_name)

    addDNSLines()

    FileCopy($t_vanilla_openssl_cnf,GoBack(@ScriptDir,1)&"\temp\_data",1)

    ReplaceStringInFile($t_openssl_cnf,"CN = default","CN = "&$t_common_name)
    
    runOpenSSlCommand('"'&$t_openSSLPath&'" req -new -key "'&$t_VConnect_key&'" -out "'&$t_VConnect_csr&'" -passin pass:'&$t_passphrase&' -config "'&$t_openssl_cnf&'"',$t_VConnect_csr,"Key generated", "Could not generate key-file")


    runOpenSSlCommand('"'&$t_openSSLPath&'" x509 -req -in "'&$t_VConnect_csr&'" -CA "'&$t_roche_ca_crt&'" -CAkey "'&$t_roche_ca_key&'" -CAcreateserial -out "'&$t_VConnect_crt&'" -days '&$t_certificate_expiration_in_days&' -sha256 -extfile "'&$t_ext&'" -passin pass:'&$t_passphrase,$t_VConnect_crt,"CSR generated", "Could not generate CSR")

EndFunc


Func addDNSLines()

    For $i = 0 To GUICtrlRead($cb_number_of_dns)-1 Step +1

        $dns = InputBox("DNS","Enter DNS"&$i+1&" Information")

        FileWriteLine(GoBack(@ScriptDir,1)&"\temp\_data\VConnect.ext","DNS."&$i+1&" = "&$dns)
    Next
EndFunc
