#This is a script to interact with SCCM and Dell computers to remotely 
#network boot them to contact a PXE server for imaging


#Functions

Function Deploy-Script($collection) {
    $devices = Get-CMDevice -CollectionName $collection | Select-Object Name | Sort-Object Name
    Write-Host "`n`nDevices in collection:`n"
    Write-Host $devices.Name -Separator `n
    

    #Confirm Hosts
    $loop = $true
    while ($loop) {
        $confirm = Read-Host "`nAre these the correct hostnames? (y or n)`n" 
        if ($confirm -eq "n") {
            Write-Host "Exiting." -ForegroundColor Red
            Exit
        }
        elseif ($confirm -eq "y") {
            $loop = $false
        }
        else {
            Write-Host "Incorrect input.  Please try again." -ForegroundColor Yellow
        }
    }

    #Deploy
    Write-Host "Deploying script."

    $script = $PSScriptRoot + "\forcepxe.bat"
    foreach ($device in $devices) {
        $name = $device.Name
        cmd.exe /c "$script" $name
    }

    Write-Host "'nScript ran successfully!  PC's should begin to restart in about 60 seconds." -ForegroundColor Green

    Stop-Script
}

Function Stop-Script {
    #Write-Host "Test Complete." 
    cd $currentDir
    Exit
}


#Main Script Entry

$currentDir = pwd #retains directory before script was run

#PowerShell Version Check
$version = $PSVersionTable.PSVersion.Major
if($version -gt 2) {
    Write-Host "Version Test Successful!" -ForegroundColor Green
    #Stop-Script #Just for testing
}
else {
    Write-Host "You must have at least Powershell v3. Please update PowerShell. " -ForegroundColor Red -BackgroundColor Black
    Stop-Script
}


#SCCM Module check
Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -ErrorVariable importErr -ErrorAction SilentlyContinue
if ($importErr) {
    Write-Host "Module Import Error: " -ForegroundColor Red -BackgroundColor Black
    Write-Host "                     " -ForegroundColor Red -BackgroundColor Black
    Write-Host $importErr -ForegroundColor Red -BackgroundColor Black
    Stop-Script
}
else {
    Write-Host "Module Import Successful!`n" -ForegroundColor Green
}

Write-Host "Please wait while the list of Collections is compiled.`n"
cd CME:\
$collections = Get-CMDeviceCollection | Select-Object Name | Sort-Object Name
Write-Host $collections.Name -ForegroundColor Yellow -Separator `n

$found = $false
while ($found -eq $false) {
    Write-Host "`nWhat collection would you like to deploy to? (Collection name must be typed exactly as shown above):  `n:" -ForegroundColor Cyan -NoNewline 
    $collection = Read-Host

    foreach ($object in $collections) {
        if($object.Name -eq $collection) {
                $found = $true
                Deploy-Script($collection)
        }
    }

    if ($found -eq $false) 
        {Write-Host "Collection wasn't found or was typed incorrectly. Please try again." -ForegroundColor Red -BackgroundColor Black}
}
