#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include "Variables.au3"
#RequireAdmin

        ; Create a GUI with various controls.
        Local $hGUI = GUICreate($name3, 340, 370)


        GUICtrlCreateLabel("OpenSSL Folder",5,5,200)
        $tf_openssl_directory = GUICtrlCreateInput(getIniValue($iniFilePath,"temporary_values","open_ssl_path",$name3_default_openssl_directory),5,25,200,20,$ES_READONLY)
        $btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",230,25, 100, 20)

        GUICtrlCreateLabel("Choose number of DNS",5,55,200)
        $cb_number_of_dns = GUICtrlCreateCombo("",5,75,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $name3_values_maximum_dns Step +1
            $data_string = $data_string & "|" & String($i)
        Next
        GUICtrlSetData($cb_number_of_dns,$data_string,1)

        GUICtrlCreateLabel("Choose number of VSS hosts",5,105,200)
        $cb_number_of_vss_hosts = GUICtrlCreateCombo("",5,125,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string_vss = ""
        For $i = 0 To $name3_values_maximum_vss_hosts-1 Step +1
            $data_string_vss = $data_string_vss & "|" & String($i+1)
        Next
        GUICtrlSetData($cb_number_of_vss_hosts,$data_string_vss,1)

        
        GUICtrlCreateLabel("Certificate expiration (months)",5,155,200)
        $cb_certificate_expiration = GUICtrlCreateCombo(getIniValue($iniFilePath,"temporary_values","certificate_expiration_in_months",$name3_default_expiration_certificate),5,175,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string_exp = ""
        For $i = 0 To $name3_values_max_expiration_certificate-1 Step +1
            $data_string_exp = $data_string_exp & "|" & String($i+1)
        Next
        GUICtrlSetData($cb_certificate_expiration,$data_string_exp,getIniValue($iniFilePath,"temporary_values","certificate_expiration_in_months",getIniValue($iniFilePath,"name3|defaults","expiration_certificate")))


        GUICtrlCreateLabel("Private key passphrase",5,205,200,25)
        local $tf_passphrase = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","temporary_values","passphrase"),5,225,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD,$ES_READONLY))
        $rb_show_password = GUICtrlCreateCheckbox("Show Password",210,225)
        $sDefaultPassChar = GUICtrlSendMsg($tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        ;GUICtrlCreateLabel("Common name",5,255,200,25)
        ;local $tf_common_name = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","name3|defaults","common_name"),5,275,200,20)

        $btn_start = GUICtrlCreateButton("Start", 5, 310, 320, 25)

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
    $t_vanilla_vss_ext = GoBack(@ScriptDir,1)&"\temp\_data\vanilla\VSS.ext"
    $t_vss_ext = GoBack(@ScriptDir,1)&"\temp\_data\VSS.ext"
    $t_openSSLPath = GUICtrlRead($tf_openssl_directory)&'\openssl.exe'
    $t_passphrase = GUICtrlRead($tf_passphrase)
    $t_roche_ca_crt = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.crt"
    $t_roche_ca_key = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.key"
    $t_vanilla_openssl_cnf = GoBack(@ScriptDir,1)&"\temp\_data\vanilla\openssl.cnf"
    $t_openssl_cnf = GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"
    $t_certificate_expiration_in_days = GUICtrlRead($cb_certificate_expiration)*30

    For $i = 0 To GUICtrlRead($cb_number_of_vss_hosts)-1 Step +1
        $t_vss_description = InputBox("VSS","Enter a name for VSS"&$i+1)
        $t_common_name =  InputBox("IP","Enter IP-Address of VSS: "&$t_vss_description)

        $t_vss_key = GoBack(@ScriptDir,1)&"\temp\"&$name3&"\VSS_"&$t_vss_description&".key"
        $t_vss_csr = GoBack(@ScriptDir,1)&"\temp\"&$name3&"\VSS_"&$t_vss_description&".csr"
        $t_vss_crt = GoBack(@ScriptDir,1)&"\temp\"&$name3&"\VSS_"&$t_vss_description&".crt"
    
        ExecuteCMD('set OPENSSL_CONF='&GoBack($apache_path,1)&'\conf\openssl.cnf')
    
        runOpenSSlCommand('"'&$t_openSSLPath&'" genrsa -out "'&$t_vss_key&'" 2048',$t_vss_key,"Private key generated", "Private key could not be generated")
    
        FileCopy($t_vanilla_openssl_cnf,GoBack(@ScriptDir,1)&"\temp\_data",1)
    
        ReplaceStringInFile($t_openssl_cnf,"CN = default","CN = "&$t_common_name)
            
        runOpenSSlCommand('"'&$t_openSSLPath&'" req -new -key "'&$t_vss_key&'" -out "'&$t_vss_csr&'" -passin pass:'&$t_passphrase&' -config "'&$t_openssl_cnf&'"',$t_vss_csr,"Key generated", "Could not generate key-file")
        
        FileCopy($t_vanilla_vss_ext,GoBack(@ScriptDir,1)&"\temp\_data",1)
    
        FileWriteLine($t_vss_ext,"IP.1 = "&$t_common_name)

        Local $t_vss_dns
        For $j = 0 To GUICtrlRead($cb_number_of_dns)-1 Step +1
            $t_vss_dns = InputBox("VSS","Enter DNS"&$j+1&" for "&$t_vss_description)
            FileWriteLine($t_vss_ext,"DNS."&$j+1&" = "&$t_vss_dns)
        Next

    
        runOpenSSlCommand('"'&$t_openSSLPath&'" x509 -req -in "'&$t_vss_csr&'" -CA "'&$t_roche_ca_crt&'" -CAkey "'&$t_roche_ca_key&'" -CAcreateserial -out "'&$t_vss_crt&'" -days '&$t_certificate_expiration_in_days&' -sha256 -extfile "'&$t_vss_ext&'" -passin pass:'&$t_passphrase,$t_vss_crt,"CSR generated", "Could not generate CSR")
     
    Next
EndFunc

Func addDNSLines($path)

    For $i = 0 To GUICtrlRead($cb_number_of_dns)-1 Step +1

        $dns = InputBox("DNS","Enter DNS"&$i+1&" Information")

        FileWriteLine($path,"DNS."&$i+1&" = "&$dns)
    Next
EndFunc