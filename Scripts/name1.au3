#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include "Variables.au3"
#RequireAdmin



        ; Create a GUI with various controls.
        Local $hGUI = GUICreate($name1, 340, 300)


        GUICtrlCreateLabel("OpenSSL Folder",5,5,200)
        $tf_openssl_directory = GUICtrlCreateInput($name1_default_openssl_directory,5,25,200,20,$ES_READONLY)
        $btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",230,25, 100, 20)

        GUICtrlCreateLabel("Choose expiration of certificatiate (months)",5,55,200)
        $cb_expiration_certificate = GUICtrlCreateCombo("",5,75,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $name1_values_max_expiration_certificate-1 Step +1
            If($i = 0) Then
                $data_string = $data_string & String($i+1)
            endif

            $data_string = $data_string & "|" & String($i+1)
        Next
        GUICtrlSetData($cb_expiration_certificate,$data_string,$name1_default_expiration_certificate)


        GUICtrlCreateLabel("Private key passphrase",5,105,200,25)
        local $tf_passphrase = GUICtrlCreateInput("",5,125,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
        $rb_show_password = GUICtrlCreateCheckbox("Show Password",210,125)
        $sDefaultPassChar = GUICtrlSendMsg($tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        GUICtrlCreateLabel("Common name",5,155,200,25)
        local $tf_common_name = GUICtrlCreateInput($name1_default_common_name,5,175,200,20)

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

    WriteIniValue($iniFilePath,"temporary_values","open_ssl_path",GUICtrlRead($tf_openssl_directory))
    WriteIniValue($iniFilePath,"temporary_values","passphrase",GUICtrlRead($tf_passphrase))
    WriteIniValue($iniFilePath,"temporary_values","certificate_expiration_in_months",GUICtrlRead($cb_expiration_certificate))
    $t_openSSLPath = GUICtrlRead($tf_openssl_directory)&'\openssl.exe'
    $t_openCNFPath = GoBack(@ScriptDir,1)&"\temp\_data\vanilla\openssl.cnf"
    $t_rocheCAPath = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.key"
    $t_rocheCRTPath = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.crt"
    $t_passphrase  = GUICtrlRead($tf_passphrase)
    $t_expiration_certificate = (GUICtrlRead($cb_expiration_certificate)*30)
    $t_common_name = GUICtrlRead($tf_common_name)

    $test = "/CN=ca.rochediagnosticsbelgium.local/O=RocheDiagnosticsBelgium/C=BE"
    $apache_path = GUICtrlRead($tf_openssl_directory)
    
    ExecuteCMD('set OPENSSL_CONF='&GoBack($apache_path,1)&'\conf\openssl.cnf')
	
	runOpenSSlCommand('"'&$t_openSSLPath&'" genrsa -des3 -passout pass:'&$t_passphrase&' -out "'&$t_rocheCAPath&'" 2048',$t_rocheCAPath,"Private key generated", "Private key could not be generated")
   
    FileCopy(GoBack(@ScriptDir,1)&"\temp\_data\vanilla\openssl.cnf",GoBack(@ScriptDir,1)&"\temp\_data",1)
    
    ReplaceStringInFile(GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf", "CN = default", "CN = "&$t_common_name)
    
    runOpenSSlCommand('"'&$t_openSSLPath&'" req -x509 -new -nodes -key "'&$t_rocheCAPath&'" -sha256 -days '&$t_expiration_certificate&' -out "'&$t_rocheCRTPath&'" -passin pass:'&$t_passphrase&' -config "'&GoBack(@ScriptDir,1)&"\temp\_data\openssl.cnf"&'"',$t_rocheCRTPath,"Certificate generated", "Could not generate certificate")


    ;runOpenSSlCommand('"'&$t_openSSLPath&'" req -x509 -new -nodes -key "'&$t_rocheCAPath&'" -sha256 -days '&$t_expiration_certificate&' -out "'&$t_rocheCRTPath&'" -passin pass:'&$t_passphrase&' -subj "'&$test&'"',$t_rocheCRTPath,"Certificate generated", "Could not generate certificate")

EndFunc
