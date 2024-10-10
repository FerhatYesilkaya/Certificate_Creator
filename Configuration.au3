#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Ferhat Yesilkaya

#ce ----------------------------------------------------------------------------

#include "Scripts\Variables.au3"
#RequireAdmin

stopProcesses("openssl.exe")
checkFilePath()
ShellExecute(@ScriptDir&"\Scripts\Generator.au3")


        Func checkFilePath()
                $name1Path = @ScriptDir&"\temp\"&$name1
                $name2Path = @ScriptDir&"\temp\"&$name2
                $name3Path = @ScriptDir&"\temp\"&$name3
                $name4Path = @ScriptDir&"\temp\"&$name4

                If Not (FileExists($name1Path)) Then
                        logging("Info",$name1Path & " does not exist. Creating path",0)
                        DirCreate($name1Path)
                endif

                If Not (FileExists($name2Path)) Then
                        logging("Info",$name2Path & " does not exist. Creating path",0)
                        DirCreate($name2Path)
                endif

                If Not (FileExists($name3Path)) Then
                        logging("Info",$name3Path & " does not exist. Creating path",0)
                        DirCreate($name3Path)
                endif


                If Not (FileExists($name4Path)) Then
                        logging("Info",$name4Path & " does not exist. Creating path",0)
                        DirCreate($name4Path)
                endif
        EndFunc