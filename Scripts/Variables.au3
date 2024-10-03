#include <Functions.au3>

$iniFilePath = GoBack(@ScriptDir,0) & "\configurables.ini"
If Not (FileExists($iniFilePath)) Then
    $iniFilePath = GoBack(@ScriptDir,1) & "\configurables.ini"
endif

$name1 = getIniValue($iniFilePath,"configuration|values","name1")
$name2 = getIniValue($iniFilePath,"configuration|values","name2")
$name3 = getIniValue($iniFilePath,"configuration|values","name3")
$name4 = getIniValue($iniFilePath,"configuration|values","name4")

$name1_values_max_expiration_certificate = getIniValue($iniFilePath,"name1|values","maximum_expiration_certificate")
$name1_default_expiration_certificate = getIniValue($iniFilePath,"name1|defaults","expiration_certificate")
$name1_default_openssl_directory = getIniValue($iniFilePath,"name1|defaults","openssl_directory")
$name1_default_common_name = getIniValue($iniFilePath,"name1|defaults","common_name")


$name2_default_openssl_directory = getIniValue($iniFilePath,"name2|defaults","openssl_directory")
$name2_values_maximum_vss_hosts = getIniValue($iniFilePath,"name2|values","maximum_vss_hosts")
$name2_values_max_expiration_certificate = getIniValue($iniFilePath,"name2|values","maximum_expiration_certificate")


$name3_default_openssl_directory = getIniValue($iniFilePath,"name3|defaults","openssl_directory")
$name3_values_maximum_dns = getIniValue($iniFilePath,"name3|values","maximum_dns")
$name3_values_maximum_vss_hosts = getIniValue($iniFilePath,"name3|values","maximum_vss_hosts")
$name3_default_expiration_certificate = getIniValue($iniFilePath,"name3|defaults","expiration_certificate")
$name3_values_max_expiration_certificate = getIniValue($iniFilePath,"name3|values","maximum_expiration_certificate")


;Windows parameters
$gui_width = 600
$gap_left = 15
$global_settings_group = 200
$first_group_height = 185
$secound_group_height = 350
$third_group_height = 500
$fourth_group_height = 210