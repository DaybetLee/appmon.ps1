$notpressed = $true
$string = 'Press any key to stop logging:'
$i = 0

# Change the following as require
$dots = 3 # Seconds to next interval check
$targetProcess = "ClearPassAgentController" # Get-Process to locate target process
$targetService = "ClearPass Agent Controller" # Get-Service to locate target service
$targetPort = 25427
$progamPath = "\Aruba Networks\ClearPassOnGuard"
$appdataPath = "\Aruba Networks\ClearPassOnGuard"

# Create ps_logs folder in Desktop if it is not already there
if (-not (Test-Path -Path $env:HOMEPATH\Desktop\ps_logs)) {
    # Out-Null prevent output to console
    New-Item -Path "$env:HOMEPATH\Desktop" -Name "ps_logs" -ItemType "directory" | Out-Null
}

function LogNow {
    # Check if current process
    if (Get-Process -Name $targetProcess -ErrorAction SilentlyContinue) {
        # "$(Get-Date -format 'u') - Info - $targetProcess is running. Wait for next minute to check again." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
    }
    else {
        "$(Get-Date -format 'u') - Err - $targetProcess is not running. Initial capturing." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append

        # Capture application logs
        $DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"
        Copy-Item -Path "$env:ProgramData$progamPath" -Destination "$env:HOMEPATH\Desktop\ps_logs\ProgramData-$DateStamp" -Recurse
        Copy-Item -Path "$env:APPDATA$appdataPath" -Destination "$env:HOMEPATH\Desktop\ps_logs\APPDATA-$DateStamp" -Recurse
        "$(Get-Date -format 'u') - Info - Copied %AppData%\Aruba Networks\ClearPassOnGuard and %ProgramData%\Aruba Networks\ClearPassOnGuard logs." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append

        # Check if local port uses the port
        if (Get-NetTCPConnection -LocalPort $targetPort -ErrorAction SilentlyContinue ) {
            "$(Get-Date -format 'u') - Info - Capturing application that uses local port $targetPort" | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
            Get-Process -Id (Get-NetTCPConnection -LocalPort $targetPort).OwningProcess | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
            
            if (Get-NetUDPEndpoint -LocalPort $targetPort -ErrorAction SilentlyContinue ) {
                "$(Get-Date -format 'u') - Info - Capturing application that uses local port $targetPort" | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
                Get-Process -Id (Get-NetUDPEndpoint -LocalPort $targetPort).OwningProcess | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
            }
        }
        else {
            "$(Get-Date -format 'u') - Info - Local Port $targetPort is not in use." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
        }

        # Capture Windows Event Logs
        Get-EventLog -LogName System -Newest 5 | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
        "$(Get-Date -format 'u') - Info - Captured Event Logs." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
        
        # Restart Application Service
        "$(Get-Date -format 'u') - Info - Capturing the 'ClearPass Agent Controller' service status before restart." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
        Get-Service $targetService | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
        "$(Get-Date -format 'u') - Info - Restarting 'ClearPass Agent Controller' service." | Out-File -FilePath $env:HOMEPATH\Desktop\ps_logs\logging.txt -Append
        Start-Service -InputObject $targetService  -PassThru | Format-List >> $env:HOMEPATH\Desktop\ps_logs\logging.txt
     
        Write-Host $string
    }
}

# Delay per check
Write-Host $string
while ($notpressed) {
    $i++
    if ([console]::KeyAvailable) {
        $notpressed = $false    
    }    
    else {
        if ($i % ($dots + 1) -eq 1) {
            # Write-Host $string -NoNewline
            Start-Sleep -Milliseconds 500          
        }
        elseif ($i % ($dots + 1) -eq 0) {
            # Write-Host 'logged'
            LogNow
            Start-Sleep -Milliseconds 500           
        }
        else {
            # Write-Host '.' -NoNewline
            Start-Sleep -Milliseconds 1000           
        }
    }
}
