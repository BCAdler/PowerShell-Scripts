$cert = (dir cert:currentuser\my\ -CodeSigningCert)

$location = Read-Host "Where is your script that you would like signed located? Ex) C:\Users\brand\Desktop\MyScript.ps1"

#cd $location #Just for Testing

Set-AuthenticodeSignature $location $cert -TimestampServer http://timestamp.comodoca.com/authenticode
