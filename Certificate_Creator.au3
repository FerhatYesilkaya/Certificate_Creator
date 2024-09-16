#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include 'Scripts\Functions.au3'
#RequireAdmin

$max_expiration_certificate = getIniValue("values","maximum_expiration_certificate")
$default_expiration_certificate = getIniValue("defaults","expiration_certificate")
$apache_installation_directory = getIniValue("defaults","apache_installation_directory")

        ; Create a GUI with various controls.
        Local $hGUI = GUICreate("Certificate_Creator", 400, 400)

        GUICtrlCreateLabel("Choose certificate-type",5,10,200)
        $cb_certificate_type = GUICtrlCreateCombo("",5,30,200,25,$CBS_DROPDOWNLIST)
        GUICtrlSetData($cb_certificate_type, "Self-signed root certificate|Certificate Signing Requests|Certificates for your hosts", "Self-signed root certificate")

        GUICtrlCreateLabel("Lab Hub directory",5,60,200)
        $tf_apache_installation_directory = GUICtrlCreateInput($apache_installation_directory,5,80,200,20,$ES_READONLY)
        $btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",230,80, 100, 20)

        GUICtrlCreateLabel("Choose expiration of certificatiate (years)",5,110,200)
        $cb_expiration_certificate = GUICtrlCreateCombo("",5,130,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $data_string = ""
        For $i = 0 To $max_expiration_certificate-1 Step +1
            If($i = 0) Then
                $data_string = $data_string & String($i+1)
            endif

            $data_string = $data_string & "|" & String($i+1)
        Next
        GUICtrlSetData($cb_expiration_certificate,$data_string,$default_expiration_certificate)

        $btn_start = GUICtrlCreateButton("OK", 310, 370, 85, 25)

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
                            createEnvironmentVariable()
                            logging("Info","Certificate generated",false, true,64, true)

                        Case $btn_choose_lab_hub_directory
                            GUICtrlSetData($tf_apache_installation_directory,ChooseFolder())

                EndSwitch
        WEnd

        ; Delete the previous GUI and all controls.
        GUIDelete($hGUI)


Func createEnvironmentVariable()
    $apache_path = GUICtrlRead($tf_apache_installation_directory)

    ExecuteCMD('set OPENSSL_CONF="'&$apache_path&'\Apache2.4\conf\openssl.cnf"')

    If Not (FileExists(@ScriptDir&"\temp")) Then
        DirCreate(@ScriptDir&"\temp")
    endif

    MsgBox(0,"",ExecuteCmdWithPassphrase('"'&GUICtrlRead($tf_apache_installation_directory)&'\Apache2.4\bin\openssl.exe" genrsa -des3 -out "'&@ScriptDir&'\temp\RocheCA.key" 2048',"123456"))
EndFunc
