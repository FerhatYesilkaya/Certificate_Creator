#include <Functions.au3>

$iniFilePath = @ScriptDir & "\configurables.ini"
$goBackLogging = 0
If (FileExists($iniFilePath) = false) Then
    $iniFilePath = GoBack(@ScriptDir,1) & "\configurables.ini"
    $goBackLogging = 1
endif

$name1 = getIniValue($iniFilePath,"configuration|values","name1","",$goBackLogging)
$name2 = getIniValue($iniFilePath,"configuration|values","name2","",$goBackLogging)
$name3 = getIniValue($iniFilePath,"configuration|values","name3","",$goBackLogging)
$name4 = getIniValue($iniFilePath,"configuration|values","name4","",$goBackLogging)


$name1_values_max_expiration_certificate = getIniValue($iniFilePath,"name1|values","maximum_expiration_certificate_in_months","",$goBackLogging)
$name1_default_expiration_certificate = getIniValue($iniFilePath,"name1|defaults","expiration_certificate","",$goBackLogging)
$name1_default_common_name = getIniValue($iniFilePath,"name1|defaults","common_name","",$goBackLogging)


$name2_values_max_expiration_certificate = getIniValue($iniFilePath,"name2|values","maximum_expiration_certificate_in_months","",$goBackLogging)
$name2_default_expiration_certificate = getIniValue($iniFilePath,"name2|defaults","expiration_certificate","",$goBackLogging)
$name2_default_ip_address = getIniValue($iniFilePath,"name2|defaults","nplh_ip_address","",$goBackLogging)
$name2_values_minimum_dns_entries = getIniValue($iniFilePath,"name2|values","minimum_dns_entries","",$goBackLogging)

$name3_default_expiration_certificate = getIniValue($iniFilePath,"name3|defaults","expiration_certificate","",$goBackLogging)
$name3_values_max_expiration_certificate = getIniValue($iniFilePath,"name3|values","maximum_expiration_certificate_in_months","",$goBackLogging)
$name3_values_minimum_ip_entries = getIniValue($iniFilePath,"name3|values","minimum_ip_entries","",$goBackLogging)
$name3_values_minimum_dns_entries = getIniValue($iniFilePath,"name3|values","minimum_dns_entries","",$goBackLogging)

$name4_default_expiration_certificate = getIniValue($iniFilePath,"name4|defaults","expiration_certificate","",$goBackLogging)


$name4_values_max_expiration_certificate = getIniValue($iniFilePath,"name4|values","maximum_expiration_certificate_in_months","",$goBackLogging)
$name4_default_common_name = getIniValue($iniFilePath,"name4|defaults","common_name","",$goBackLogging)
$name4_values_minimum_dns_entries = getIniValue($iniFilePath,"name4|values","minimum_dns_entries","",$goBackLogging)
$name4_default_ip_address = getIniValue($iniFilePath,"name4|defaults","nplh_ip_address","",$goBackLogging)
$global_default_openssl_directory = getIniValue($iniFilePath,"global|defaults","openssl_directory","",$goBackLogging)


$common_name_tool_tip_text = getIniValue($iniFilePath,"configuration|values","common_name_description","",$goBackLogging)
$dns_tool_tip_text = getIniValue($iniFilePath,"configuration|values","dns_description","",$goBackLogging)
$expiration_date_tool_tip_text = getIniValue($iniFilePath,"configuration|values","expiration_date_description","",$goBackLogging)
$ip_tool_tip_text = getIniValue($iniFilePath,"configuration|values","ip_description","",$goBackLogging)
$csr_tool_tip_text = getIniValue($iniFilePath,"configuration|values","csr_description","",$goBackLogging)
$private_key_tool_tip_text = getIniValue($iniFilePath,"configuration|values","priavte_key_description","",$goBackLogging)
$ca_passphrase_tool_tip_text = getIniValue($iniFilePath,"configuration|values","ca_passhrase_description","",$goBackLogging)
$openssl_folder_tool_tip_text = getIniValue($iniFilePath,"configuration|values","openssl_folder_description","",$goBackLogging)

;Windows parameters
$gui_width = 900
$gap_left = 15
$global_settings_group = 200
$first_group_height = 185
$secound_group_height = 350
$third_group_height = 470
$fourth_group_height = 350