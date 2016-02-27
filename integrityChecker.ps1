#Hashes items in a directory and stores it as a csv
#if you run on a directory already hashed it will compare hashes

$Path = "C:\Windows\System32\"

$Provider = new-object System.Security.Cryptography.SHA1CryptoServiceProvider
$Provider = new-object System.Security.Cryptography.MD5CryptoServiceProvider
function get-filehash2($file, $type) {
    if ($file -isnot [System.IO.FileInfo]) {
      #write-error "'$($file)' is not a file."
      return
    }
    
    switch ($type) {
    "MD5" {
      $Provider = new-object System.Security.Cryptography.MD5CryptoServiceProvider
      break
    }
    "SHA1" {
      $Provider = new-object System.Security.Cryptography.SHA1CryptoServiceProvider
      break
    }
    default {
      throw "HashType must be one of the following: MD5 SHA1"
    }
    }
  
    $hashstring = new-object System.Text.StringBuilder
    $stream = $file.OpenRead()
    if ($stream) {
      foreach ($byte in $Provider.ComputeHash($stream)) {
        [Void] $hashstring.Append($byte.ToString("X2"))
      }
      $stream.Close()
    }
    $hashstring.ToString()
}
  
$test = Test-Path -Path .\System32.csv
if(!$test) {
    Write-Host Base Integrity Creation
    $results = @()
    $files = Get-Childitem $Path -Filter *.exe
    $files += Get-Childitem $Path -Filter *.dll
    foreach ($item in $files) {
        $fileObject = New-Object PSObject
    
        $fileObject | Add-Member -MemberType NoteProperty -Name "Filename" -Value $item."Name"
        $fileObject | Add-Member -MemberType NoteProperty -Name "LastWriteTime" -Value $item."LastWriteTime"
        $md = get-filehash2 $item MD5
        $fileObject | Add-Member -MemberType NoteProperty -Name "MD5" -Value $md
        $sha = get-filehash2 $item SHA1
        $fileObject | Add-Member -MemberType NoteProperty -Name "SHA1" -Value $sha
    
        $results += $fileObject
    }

    $results | Export-csv System32.csv -notypeinformation
    Exit
} 
else {
Write-Host Integrity Check
#Rename-Item .\System32.csv -NewName System32_Base.csv
$files = Get-ChildItem $Path -Filter *.exe 
$files += Get-ChildItem $Path -Filter *.dll 
$results = @()
foreach ($item in $files) {
        $fileObject = New-Object PSObject
    
        $fileObject | Add-Member -MemberType NoteProperty -Name "Filename" -Value $item."Name"
        $fileObject | Add-Member -MemberType NoteProperty -Name "LastWriteTime" -Value $item."LastWriteTime"
        $md = get-filehash2 $item MD5
        $fileObject | Add-Member -MemberType NoteProperty -Name "MD5" -Value $md
        $sha = get-filehash2 $item SHA1
        $fileObject | Add-Member -MemberType NoteProperty -Name "SHA1" -Value $sha
    
        $results += $fileObject
    }

$results | Export-csv System32_New.csv -notypeinformation

$oldCSV = Import-Csv .\System32.csv
$oldCount = (Get-Content .\System32.csv -ReadCount 1 | Measure-Object -Line).Lines
$newCSV = Import-Csv .\System32_New.csv
$newCount = (Get-Content .\System32_New.csv -ReadCount 1 | Measure-Object -Line).Lines
$diff = ($newCount - $oldCount)
Write-Host Difference in num of files: $diff

foreach ($item in $oldCSV) {
    $newItem = $newCSV | where {$_."Filename" -eq $item."Filename"}
    if($item."MD5" -ne $newItem."MD5") { Write-Host $item."Filename".ToString() MD5  Has been changed -ForegroundColor Red }
    ElseIf ($item."SHA1" -ne $newItem."SHA1") { Write-Host $item."Filename" SHA1  Has been changed -ForegroundColor Red }
    else {Write-Host $item."Filename"    Checked -ForegroundColor Green }
}
}
