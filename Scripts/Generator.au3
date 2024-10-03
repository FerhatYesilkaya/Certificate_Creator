#include <GUIConstantsEx.au3>
#include <GUIConstants.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GUIScrollbars_Ex.au3>
#include "Variables.au3"
#RequireAdmin

        ; Create a GUI with various controls
        Local $hGUI = GUICreate("Cert-Generator", $gui_width+20, 500)

        ;Global Settings - Start
        GUICtrlCreateGroup("Global",5,5,$gui_width-10,$global_settings_group-15)
        GUICtrlSetFont(-1,11,700)
        GUICtrlCreateLabel("OpenSSL Folder",$gap_left,30,200)
        $global_settings_tf_openssl_directory = GUICtrlCreateInput($name1_default_openssl_directory,$gap_left,50,200,20,$ES_READONLY)
        $global_settings_btn_choose_lab_hub_directory = GUICtrlCreateButton("Directory",$gap_left+210,50, 100, 20)

        $global_settings_checkbox_name1 = GUICtrlCreateCheckbox("Create "&$name1,$gap_left,80)
        $global_settings_checkbox_name2 = GUICtrlCreateCheckbox("Create "&$name2,$gap_left,105)
        $global_settings_checkbox_name3 = GUICtrlCreateCheckbox("Create "&$name3,$gap_left,130)
        $global_settings_checkbox_name4 = GUICtrlCreateCheckbox("Create "&$name4,$gap_left,155)

        $global_start_btn = GUICtrlCreateButton("Create selected",$gui_width-110,$global_settings_group-50,100,30)

        ;Global Settings - End

        ;First - Start
        $first_group = GUICtrlCreateGroup($name1,5,$global_settings_group,$gui_width-10, $first_group_height)
        GUICtrlSetFont(-1,11,700)
        GUICtrlCreateLabel("Choose expiration of certificate (months)",$gap_left,30+$global_settings_group)
        $first_cb_expiration_certificate = GUICtrlCreateCombo("",$gap_left,50+$global_settings_group,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $first_data_string = ""
        For $i = 0 To $name1_values_max_expiration_certificate-1 Step +1
            If($i = 0) Then
                $first_data_string = $first_data_string & String($i+1)
            endif

            $first_data_string = $first_data_string & "|" & String($i+1)
        Next
        GUICtrlSetData($first_cb_expiration_certificate,$first_data_string,$name1_default_expiration_certificate)

        $first_expiration_date_readable = GUICtrlCreateLabel("Test",210+$gap_left,$global_settings_group+52,200)
        calculateReadableExpiration($first_expiration_date_readable,$first_cb_expiration_certificate)

        GUICtrlCreateLabel("Private key passphrase",$gap_left,$global_settings_group+80,200,25)
        local $first_tf_passphrase = GUICtrlCreateInput("",$gap_left,$global_settings_group+100,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
        $first_rb_show_password = GUICtrlCreateCheckbox("Show Password",210+$gap_left,$global_settings_group+100)
        local $first_sDefaultPassChar = GUICtrlSendMsg($first_tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        GUICtrlCreateLabel("Common name",$gap_left,$global_settings_group+130,200,25)
        local $first_tf_common_name = GUICtrlCreateInput($name1_default_common_name,$gap_left,$global_settings_group+150,200,20)

        $first_create = GUICtrlCreateButton("Create",$gui_width-80,$global_settings_group+$first_group_height-40,70,30)

        GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
        ;First - End 

        ;Second - Start
        $secound_group = GUICtrlCreateGroup($name2,5,$global_settings_group+$first_group_height+10,$gui_width-10, $secound_group_height)
        GUICtrlSetFont(-1,11,700)

        $second_do_csr_only_btn = GUICtrlCreateButton("CSR-Only-Off",$gui_width-95,$global_settings_group+$first_group_height+30,85,30)
        GUICtrlSetBkColor(-1,$COLOR_RED)


        GUICtrlCreateLabel("DNS",$gap_left,$global_settings_group+$first_group_height+35,200,25)

        $second_list_view = GUICtrlCreateListView("DNS", $gap_left,$global_settings_group+$first_group_height+55,300, 80, BitOR($WS_VSCROLL,$LVS_SINGLESEL))
        $second_add_to_list = GUICtrlCreateButton("Add DNS",$gap_left+310,$global_settings_group+$first_group_height+60,70)
        $second_delete_from_list = GUICtrlCreateButton("Delete DNS",$gap_left+310,$global_settings_group+$first_group_height+100,70)



        ;$second_add_dns_btn = GUICtrlCreateButton("Add DNS",$gap_left,$global_settings_group+$first_group_height+55)


        GUICtrlCreateLabel("Certificate expiration (months)",$gap_left,$global_settings_group+$first_group_height+145,200)
        $second_cb_certificate_expiration = GUICtrlCreateCombo("",$gap_left,$global_settings_group+$first_group_height+165,200,25,$CBS_DROPDOWNLIST + $WS_VSCROLL) 
        $second_data_string = ""
        For $i = 0 To $name2_values_max_expiration_certificate Step +1
            $second_data_string = $second_data_string & "|" & String($i)
        Next
        GUICtrlSetData($second_cb_certificate_expiration,$second_data_string,getIniValue($iniFilePath,"temporary_values","certificate_expiration_in_months",getIniValue($iniFilePath,"name2|defaults","expiration_certificate")))
        $second_expiration_date_readable = GUICtrlCreateLabel("Test",$gap_left+210,$global_settings_group+$first_group_height+168,200)
        calculateReadableExpiration($second_expiration_date_readable,$second_cb_certificate_expiration)

        GUICtrlCreateLabel("CA passphrase",$gap_left,$global_settings_group+$first_group_height+195,200,25)
        local $second_tf_passphrase = GUICtrlCreateInput(getIniValue($iniFilePath,"temporary_values","passphrase"),$gap_left,$global_settings_group+$first_group_height+215,200,20, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
        $second_rb_show_password = GUICtrlCreateCheckbox("Show Password",$gap_left+210,$global_settings_group+$first_group_height+215)
        $second_sDefaultPassChar = GUICtrlSendMsg($second_tf_passphrase, $EM_GETPASSWORDCHAR, 0, 0)

        GUICtrlCreateLabel("nPLH/VConnect-Server IP",$gap_left,$global_settings_group+$first_group_height+245)
        $second_tf_nplh_ip_address = GUICtrlCreateInput("",$gap_left,$global_settings_group+$first_group_height+265,200,20)

        GUICtrlCreateLabel("Common name",$gap_left,$global_settings_group+$first_group_height+295,200,25)
        local $second_tf_common_name = GUICtrlCreateInput(getIniValue(GoBack(@ScriptDir,1)&"\configurables.ini","name2|defaults","common_name"),$gap_left,$global_settings_group+$first_group_height+315,200,20)
        
        $second_create = GUICtrlCreateButton("Create",$gui_width-80,$global_settings_group+$first_group_height+$secound_group_height-30,70,30)

        ;Second - End



        ;Third - Start
        $third_group = GUICtrlCreateGroup($name3,5,$global_settings_group+$first_group_height+$secound_group_height+15,$gui_width-10, $third_group_height)
        GUICtrlSetFont(-1,11,700)

        $third_do_csr_only_btn = GUICtrlCreateButton("CSR-Only-Off",$gui_width-95,$global_settings_group+$first_group_height+$secound_group_height+35,85,30)
        GUICtrlSetBkColor(-1,$COLOR_RED)


        GUICtrlCreateLabel("VSS-IP-Address",$gap_left,$global_settings_group+$first_group_height+$secound_group_height+40,200,25)
        $third_list_ip_view = GUICtrlCreateListView("Location|IP", $gap_left,$global_settings_group+$first_group_height+$secound_group_height+55,300, 80, BitOR($WS_VSCROLL,$LVS_SINGLESEL))
        $third_add_to_ip_list = GUICtrlCreateButton("Add IP",$gap_left+310,$global_settings_group+$first_group_height+$secound_group_height+65,70)
        $third_delete_from_ip_list = GUICtrlCreateButton("Delete IP",$gap_left+310,$global_settings_group+$first_group_height+$secound_group_height+105,70)

        GUICtrlCreateLabel("DNS",$gap_left,$global_settings_group+$first_group_height+$secound_group_height+150,200,25)
        $third_dns_list_view = GUICtrlCreateListView("Location|DNS", $gap_left,$global_settings_group+$first_group_height+$secound_group_height+165,300, 80, BitOR($WS_VSCROLL,$LVS_SINGLESEL))
        $third_add_to_dns_list = GUICtrlCreateButton("Add DNS",$gap_left+310,$global_settings_group+$first_group_height+$secound_group_height+175,70)
        $third_delete_from_dns_list = GUICtrlCreateButton("Delete DNS",$gap_left+310,$global_settings_group+$first_group_height+$secound_group_height+215,70)

        GUICtrlCreateLabel("Common-Name",$gap_left,$global_settings_group+$first_group_height+$secound_group_height+260,200,25)
        $third_list_ip_view = GUICtrlCreateListView("Location|Common Name", $gap_left,$global_settings_group+$first_group_height+$secound_group_height+275,300, 80, BitOR($WS_VSCROLL,$LVS_SINGLESEL))
        $third_change_cn_list = GUICtrlCreateButton("Change Common Name",$gap_left+310,$global_settings_group+$first_group_height+$secound_group_height+285,125)        

        $third_create = GUICtrlCreateButton("Create",$gui_width-80,$global_settings_group+$first_group_height+$secound_group_height+$third_group_height-25,70,30)

        ;Third - End



        ;Fourth - Start
        $fourth_group = GUICtrlCreateGroup($name4,5,$global_settings_group+$first_group_height+$secound_group_height+$third_group_height+20,$gui_width-10, $fourth_group_height)
        GUICtrlSetFont(-1,11,700)
        ;Fourth - End


        Local $aWindow_Size = WinGetPos($hGUI)
        ConsoleWrite('Window Width  = ' & $aWindow_Size[2] & @CRLF)
        ConsoleWrite('Window Height = ' & $aWindow_Size[3] & @CRLF)
        Local $aWindowClientArea_Size = WinGetClientSize($hGUI)
        ConsoleWrite('Window Client Area Width  = ' & $aWindowClientArea_Size[0] & @CRLF)
        ConsoleWrite('Window Client Area Height = ' & $aWindowClientArea_Size[1] & @CRLF)
        _GUIScrollbars_Generate($hGUI, $gui_width, $global_settings_group+$first_group_height+$secound_group_height+$third_group_height+$fourth_group_height+20)

        GUISetState(@SW_SHOW, $hGUI)

        #cs
        $i = 0
        $size = 5
        Local $input[$size]
        #ce
        ; Loop until the user exits.
        While 1
                Switch GUIGetMsg()
                        Case $GUI_EVENT_CLOSE
                            ExitLoop
                        Case $global_settings_btn_choose_lab_hub_directory
                            $path = ChooseFolder()
                            If Not ($path = "") Then
                                GUICtrlSetData($global_settings_tf_openssl_directory,$path)
                            Endif

                        Case $first_cb_expiration_certificate
                            calculateReadableExpiration($first_expiration_date_readable,$first_cb_expiration_certificate)

                        Case $first_rb_show_password
                            showPassword($first_rb_show_password, $first_tf_passphrase, $first_sDefaultPassChar)

                        Case $first_create
                            first_group_do_steps()
                            logging("Info", "Completed",1, false, true,64, false)
                        Case $second_add_to_list
                            secondAddDNS()
                        Case $second_delete_from_list
                            secondDeleteDNS()

                        Case $second_rb_show_password
                            showPassword($second_rb_show_password, $second_tf_passphrase, $second_sDefaultPassChar)

                        Case $second_cb_certificate_expiration
                            calculateReadableExpiration($second_expiration_date_readable,$second_cb_certificate_expiration)
            
                        Case $second_create
                            second_group_do_steps()
                            logging("Info", "Completed",1, false, true,64, false)

                        Case $second_do_csr_only_btn
                            Local $array[0]
                            $array = ArrayExpand($array, $second_add_to_list)
                            $array = ArrayExpand($array, $second_delete_from_list)
                            $array = ArrayExpand($array, $second_cb_certificate_expiration)
                            $array = ArrayExpand($array, $second_list_view)
                            $array = ArrayExpand($array, $second_rb_show_password)
                            $array = ArrayExpand($array, $second_tf_passphrase)
                            $array = ArrayExpand($array, $second_tf_nplh_ip_address)
                            changeCSRButtonState($second_do_csr_only_btn,$array)
                EndSwitch
        WEnd

        ; Delete the previous GUI and all controls.
        GUIDelete($hGUI)

Func first_group_do_steps()

    ;WriteIniValue($iniFilePath,"temporary_values","open_ssl_path",GUICtrlRead($first_tf_openssl_directory))
    WriteIniValue($iniFilePath,"temporary_values","passphrase",GUICtrlRead($first_tf_passphrase))
    WriteIniValue($iniFilePath,"temporary_values","certificate_expiration_in_months",GUICtrlRead($first_cb_expiration_certificate))
    $t_openSSLPath = GUICtrlRead($global_settings_tf_openssl_directory)&'\openssl.exe'
    $t_openCNFPath = GoBack(@ScriptDir,1)&"\data\vanilla\openssl.cnf"
    $t_rocheCAPath = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.key"
    $t_rocheCRTPath = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.crt"
    $t_passphrase  = GUICtrlRead($first_tf_passphrase)
    $t_expiration_certificate = (GUICtrlRead($first_cb_expiration_certificate)*30)
    $t_common_name = GUICtrlRead($first_tf_common_name)
    $apache_path = GUICtrlRead($global_settings_tf_openssl_directory)
    
    logging("Info", "Creating OpenSSL Evironment variable")
    ExecuteCMD('set OPENSSL_CONF='&GoBack($apache_path,1)&'\conf\openssl.cnf')

    if($t_passphrase = "") Then
        logging("Info", "Creating RocheCA.key without passphrase")
        runOpenSSlCommand('"'&$t_openSSLPath&'" genrsa -out "'&$t_rocheCAPath&'" 2048',$t_rocheCAPath,"Private key generated", "Private key could not be generated")

    Else
        logging("Info", "Creating RocheCA.key with passphrase")
        runOpenSSlCommand('"'&$t_openSSLPath&'" genrsa -des3 -passout pass:'&$t_passphrase&' -out "'&$t_rocheCAPath&'" 2048',$t_rocheCAPath,"Private key generated", "Private key could not be generated")

    endif
    FileCopy(GoBack(@ScriptDir,1)&"\data\vanilla\openssl.cnf",GoBack(@ScriptDir,1)&"\data",1)
    ReplaceStringInFile(GoBack(@ScriptDir,1)&"\data\openssl.cnf", "CN = default", "CN = "&$t_common_name)
    
    logging("Info", "Creating RocheCA.crt")
    runOpenSSlCommand('"'&$t_openSSLPath&'" req -x509 -new -nodes -key "'&$t_rocheCAPath&'" -sha256 -days '&$t_expiration_certificate&' -out "'&$t_rocheCRTPath&'" -passin pass:'&$t_passphrase&' -config "'&GoBack(@ScriptDir,1)&"\data\openssl.cnf"&'"',$t_rocheCRTPath,"Certificate generated", "Could not generate certificate")
EndFunc

Func secondAddDNS()
    $value = InputBox("DNS", "Enter DNS-Information:")
    if Not ($value = "") Then
        GUICtrlCreateListViewItem($value,$second_list_view)
    endif
EndFunc

Func secondDeleteDNS() 
    If(UBound(_GUICtrlListView_GetSelectedIndices($second_list_view,true)) <= 1) Then 
        return 0
    endif

    $delete = StringSplit(_GUICtrlListView_GetSelectedIndices($second_list_view),"|")
    _ArrayDelete($delete,0)

    For $i = 0 To UBound($delete)-1 Step +1
        _GUICtrlListView_DeleteItem($second_list_view,$delete[$i])
    Next
EndFunc


Func second_group_do_steps()
    $apache_path = GUICtrlRead($global_settings_tf_openssl_directory)
    $t_common_name = GUICtrlRead($second_tf_common_name)
    $t_nplh_ip_address = GUICtrlRead($second_tf_nplh_ip_address)
    $t_openSSLPath = GUICtrlRead($global_settings_tf_openssl_directory)&'\openssl.exe'
    $t_VConnect_key = GoBack(@ScriptDir,1)&"\temp\"&$name2&"\VConnect.key"
    $t_VConnect_csr = GoBack(@ScriptDir,1)&"\temp\"&$name2&"\VConnect.csr"
    $t_VConnect_crt = GoBack(@ScriptDir,1)&"\temp\"&$name2&"\VConnect.crt"
    $t_roche_ca_crt = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.crt"
    $t_roche_ca_key = GoBack(@ScriptDir,1)&"\temp\"&$name1&"\RocheCA.key"
    $t_vanilla_openssl_cnf = GoBack(@ScriptDir,1)&"\data\vanilla\openssl.cnf"
    $t_openssl_cnf = GoBack(@ScriptDir,1)&"\data\openssl.cnf"
    $t_certificate_expiration_in_days = GUICtrlRead($second_cb_certificate_expiration)*30
    $t_passphrase = GUICtrlRead($second_tf_passphrase)
    $t_vanilla_ext = GoBack(@ScriptDir,1)&"\data\vanilla\VConnect.ext"
    $t_ext = GoBack(@ScriptDir,1)&"\data\VConnect.ext"

    ExecuteCMD('set OPENSSL_CONF='&GoBack($apache_path,1)&'\conf\openssl.cnf')

    FileCopy($t_vanilla_openssl_cnf,GoBack(@ScriptDir,1)&"\data",1)

    ReplaceStringInFile($t_openssl_cnf,"CN = default","CN = "&$t_common_name)

	runOpenSSlCommand('"'&$t_openSSLPath&'" genrsa -out "'&$t_VConnect_key&'" 2048',$t_VConnect_key,"Private key generated", "Private key could not be generated")

    runOpenSSlCommand('"'&$t_openSSLPath&'" req -new -key "'&$t_VConnect_key&'" -out "'&$t_VConnect_csr&'" -config "'&$t_openssl_cnf&'"',$t_VConnect_csr,"CSR generated", "Could not CSR file")

    If(GUICtrlRead($second_do_csr_only_btn) = "CSR-Only-On") Then
        return 0
    endif

    FileCopy($t_vanilla_ext,GoBack(@ScriptDir,1)&"\data",1)

    FileWriteLine($t_ext,"IP.1 = "&$t_nplh_ip_address)

    secondAddDNSLinesToFile()

    if($t_passphrase = "") Then
        runOpenSSlCommand('"'&$t_openSSLPath&'" x509 -req -in "'&$t_VConnect_csr&'" -CA "'&$t_roche_ca_crt&'" -CAkey "'&$t_roche_ca_key&'" -CAcreateserial -out "'&$t_VConnect_crt&'" -days '&$t_certificate_expiration_in_days&' -sha256 -extfile "'&$t_ext&'"',$t_VConnect_crt,"CRT generated", "Could not generate CRT")

    Else
        runOpenSSlCommand('"'&$t_openSSLPath&'" x509 -req -in "'&$t_VConnect_csr&'" -CA "'&$t_roche_ca_crt&'" -CAkey "'&$t_roche_ca_key&'" -CAcreateserial -out "'&$t_VConnect_crt&'" -days '&$t_certificate_expiration_in_days&' -sha256 -extfile "'&$t_ext&'" -passin pass:'&$t_passphrase,$t_VConnect_crt,"CRT generated", "Could not generate CRT")
    endif

EndFunc

Func secondAddDNSLinesToFile()

    Local $length = _GUICtrlListView_GetItemCount($second_list_view)

    If($length = 0) Then 
        return 0
    endif

    For $i = 0 To $length-1 Step +1
        $item = _GUICtrlListView_GetItem($second_list_view,$i)
        FileWriteLine(GoBack(@ScriptDir,1)&"\data\VConnect.ext","DNS."&$i+1&" = "&$item[3])
    Next
EndFunc
