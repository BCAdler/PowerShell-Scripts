$cert = (dir cert:currentuser\my\ -CodeSigningCert)

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# *** Entry Point to Script ***

$fileName = Get-FileName -initialDirectory "%HOME%"
Write-Host $fileName


cd $fileName

#$location = Read-Host "Where is your script that you would like signed located? Ex) C:\Users\<Username>\Desktop\MyScript.ps1"

#cd $location

Set-AuthenticodeSignature $fileName $cert -TimestampServer http://timestamp.comodoca.com/authenticode
