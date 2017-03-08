<#
 # 
#>

#Hashes items in a directory and stores it as a csv
#if you run on a directory already hashed it will compare hashes

param (
    [Parameter(Mandatory=$true)]$Path,
	[switch]$Recurse,
    [string]$FileExtensions = "*"
)

function Get-Files {
	$FileExtensions = $FileExtensions.Split(',')

	if ($Recurse -and $FileExtensions -eq "*") {
		$files = Get-ChildItem -Path $Path -Recurse
	}
	elseif ($Recurse) {
		foreach($ext in $FileExtensions) {
			$files += Get-ChildItem -Path $Path -Recurse -Filter *.$ext
		}
	}
	elseif (!$Recurse -and $FileExtensions -eq "*") {
		$files = Get-ChildItem -Path $Path -Recurse
	} 
	else {
		foreach ($ext in $FileExtensions) {
			$files += Get-ChildItem -Path $Path -Recurse -Filter *.$ext
		}
	}
	
	return $files
}

function Get-FileHash($file, $type) {
	$Provider = new-object System.Security.Cryptography.SHA1CryptoServiceProvider
	$Provider = new-object System.Security.Cryptography.MD5CryptoServiceProvider

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
            [Void]$hashstring.Append($byte.ToString("X2"))
        }
        $stream.Close()
    }
    $hashstring.ToString()
}

$Path = $Path.Trim("`"")
$folder = $Path.Split('\')
$folder = $folder[$folder.Length-2]
$csvPath = $PSScriptRoot + '\' + $folder + '.csv'
Write-Host $csvPath

$test = Test-Path -Path $csvPath
if(!$test) {
    Write-Host Base Integrity Creation
    $results = @()

	$files = Get-Files 
	Write-Host "Out of Get-Files"
    foreach ($item in $files) {
        $fileObject = New-Object PSObject
    
        $fileObject | Add-Member -MemberType NoteProperty -Name "Filename" -Value $item."Name"
        $fileObject | Add-Member -MemberType NoteProperty -Name "LastWriteTime" -Value $item."LastWriteTime"
        $md = Get-FileHash $item MD5
        $fileObject | Add-Member -MemberType NoteProperty -Name "MD5" -Value $md
        $sha = Get-FileHash $item SHA1
        $fileObject | Add-Member -MemberType NoteProperty -Name "SHA1" -Value $sha
    
        $results += $fileObject
    }

    $results | Export-csv $csvPath -NoTypeInformation
	Write-Host "Exiting Base Integrity"
    Exit
} 
else {
    Write-Host Integrity Check
    
    $files = Get-Files
    $results = @()
    foreach ($item in $files) {
        $fileObject = New-Object PSObject

        $fileObject | Add-Member -MemberType NoteProperty -Name "Filename" -Value $item."Name"
        $fileObject | Add-Member -MemberType NoteProperty -Name "LastWriteTime" -Value $item."LastWriteTime"
        $md = Get-FileHash $item MD5
        $fileObject | Add-Member -MemberType NoteProperty -Name "MD5" -Value $md
        $sha = Get-FileHash $item SHA1
        $fileObject | Add-Member -MemberType NoteProperty -Name "SHA1" -Value $sha

        $results += $fileObject
    }

    $newCSVPath = $csvPath.Split('\')
    $newCSVPath = $newCSVPath[$newCSVPath.Length-1]
    $newCSVPath = $newCSVPath.Substring(0, $newCSVPath.IndexOf('.')) + "_new.csv"
    $newCSVPath = $PSScriptRoot + '\' + $newCSVPath
    $results | Export-csv -Path $newCSVPath -NoTypeInformation

    $oldCSV = Import-Csv $csvPath
    $oldCount = (Get-Content -Path $csvPath -ReadCount 1 | Measure-Object -Line).Lines
    $newCSV = Import-Csv $newCSVPath
    $newCount = (Get-Content -Path $newCSVPath -ReadCount 1 | Measure-Object -Line).Lines
    $diff = ($newCount - $oldCount)
    Write-Host Difference in num of files: $diff

    foreach ($item in $oldCSV) {
        $newItem = $newCSV | Where-Object {
            $_."Filename" -eq $item."Filename"
        }
        if ($item."MD5" -ne $newItem."MD5") { 
            Write-Host $item."Filename" MD5  Has been changed -ForegroundColor Red 
        }
        elseif ($item."SHA1" -ne $newItem."SHA1") { 
            Write-Host $item."Filename" SHA1  Has been changed -ForegroundColor Red 
        }
        elseif ($item."LastWriteTime" -ne $newItem."LastWriteTime") {
            Write-Host $item."LastWriteTime" Has been written to -ForegroundColor Red
        }
        else {
            Write-Host $item."Filename"    Checked -ForegroundColor Green 
        }
    }
    $results | Export-Csv -Path $csvPath -NoTypeInformation
}
