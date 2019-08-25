# Davis Busteed
# 
# Checkout README.md for info

Function Stop-Script {
    Write-Host "[INFO] Quiting MySSH..." -ForegroundColor Yellow
    exit
}

Clear-Host

$sessions_path = $HOME + "\.ssh\sessions"

Write-Host ""

# quit if SSH not installed
If (-not( Get-Command ssh -errorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'ssh' command doesn't exist or is not available" -ForegroundColor Red
    Stop-Script
}

# create file if not exists
If (-not (Test-Path $sessions_path)) {
    Write-Host "[INFO] MySSH Sessions not found at $sessions_path" -ForegroundColor Yellow
    Write-Host "[INFO] Creating MySSH Sessions file at $sessions_path" -ForegroundColor Yellow
    $null > $sessions_path
    Write-Host ""
}

# get the data found in session file
[array]$sessions = Get-Content $sessions_path

$i = 1

# Write first part of menu
Write-Host "Available SSH Sessions" -ForegroundColor Blue
Write-Host "----------------------" -ForegroundColor Blue
If ($sessions.Length -eq 0)  {

    Write-Host "No sessions found" -ForegroundColor Cyan

} 
Else {

    $sessions | forEach {
        Write-Host "[$i] $_" -ForegroundColor Cyan
        $i += 1
    }

}

# Write second part of menu
Write-Host "`nOther Options" -ForegroundColor Blue
Write-Host "-------------" -ForegroundColor Blue
Write-Host "[a] Add / edit SSH sessions" -ForegroundColor Cyan
Write-Host "[h] Help" -ForegroundColor Cyan
Write-Host "[q] Quit" -ForegroundColor Cyan

$choice = Read-Host "`nSelect an option"

Write-Host ""

# adding / editing sessions
If($choice -eq "a") {

    Clear-Host

    Write-Host "Add / edit SSH Sessions" -ForegroundColor Blue
    Write-Host "---------------" -ForegroundColor Blue    

    Write-Host "[n] Add / edit thru Notepad" -ForegroundColor Cyan
    Write-Host "[c] Add thru CLI" -ForegroundColor Cyan
    Write-Host "[r] Return to menu" -ForegroundColor Cyan
    Write-Host "[q] Quit" -ForegroundColor Cyan
    
    $choice = Read-Host "`nSelect an option"

    If ($choice -eq "n") {
    
        Write-Host "`n[INFO] Check out the Help menu for session file example" -ForegroundColor Yellow

        start notepad $sessions_path

    }
	ElseIf ($choice -eq "c") {
        
        Write-Host ""

        Do {
      
            $sesh = Read-Host "Enter SSH session or 'q' to quit"
            
            If ($sesh -ne "q") {
                Add-Content $sessions_path $sesh
            }
              
        } While($sesh -ne "q")
    
    }
	ElseIf ($choice -eq "r") {

        myssh

    }
	ElseIf ($choice -eq "q") {
        
        Write-Host ""
        Stop-Script
    
    }
	Else {
    
        Write-Host "`n[ERROR] Invalid input." -ForegroundColor Red
        Stop-Script
    
    }


}
# help menu
ElseIf ($choice -eq "h") {

    Clear-Host
    
    Write-Host "MySSH Help" -ForegroundColor Blue
    Write-Host "----------" -ForegroundColor Blue
    Write-Host ""    
    Write-Host "USAGE:" -ForegroundColor Cyan
    Write-Host "  Run the script in PowerShell my typing in 'myssh'."
    Write-Host "  (if you are reading this message, you probably already did this)"
    Write-Host ""
    Write-Host "  Also remember to add 'myssh.ps1' to your PATH, so that it can be used anywhere"
    Write-Host ""
    Write-Host "SESSIONS FILE:" -ForegroundColor Cyan
    Write-Host "  The file located at $sessions_path stores your SSH sessions"
    Write-Host "  Use option 'a' in this script to add to it, or simply use a text editor"
    Write-Host ""
    Write-Host "  Each line of the sessions file should contain valid arguments for the 'ssh' command"
    Write-Host "  In other words, each line should be the arguments you would normally pass the 'ssh' command"
    Write-Host ""
    Write-Host "  An example sessions file could be as follows:"
    Write-Host ""
    Write-Host "    +----------------------+"
    Write-Host "    | admin@dev-server.com |"
    Write-Host "    | 123.23.42.51 -l bob  |"
    Write-Host "    | ...                  |"
    Write-Host "    +----------------------+"
    Write-Host ""

    $choice = Read-Host "Hit any key to continue or 'q' to quit"

    If ($choice -eq "q") {
        Write-Host ""
        Stop-Script
    } Else {
        myssh
    }

}
# quit
ElseIf ($choice -eq "q") {

    Stop-Script

}
# connecting to session (check if valid #)
ElseIf ($choice -gt 0 -and $choice -lt ($sessions.Length+1) ) {

    Try {	
        ssh $sessions[$choice-1]
    } Catch {
        Write-Host "[ERROR] Unknown issue with SSH, check your session arguments" -ForegroundColor Red
        Stop-Script
    }

}
# everythin else
Else {
    
    Write-Host "[ERROR] Invalid Input" -ForegroundColor Red
    Stop-Script

}