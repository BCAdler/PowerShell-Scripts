@echo off

xcopy "\\Server\Share\forcepxe.exe" "\\%1\\C$\Folder\Destination\" /Y
psexec \\%1 -accepteula -u Domain\User -p Password -h "C:\Folder\Destination\forcepxe.exe"

psshutdown.exe -accepteula -r -t 60-c \\%1
