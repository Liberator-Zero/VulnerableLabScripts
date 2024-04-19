# Create 10 random user accounts with simple passwords
$users = 1..10 | ForEach-Object {
    $username = "User$($_)"
    $password = "Password123!"
    # Create the user account
    New-LocalUser -Name $username -Password (ConvertTo-SecureString -AsPlainText $password -Force) -PasswordNeverExpires -AccountNeverExpires -Description "PenTest Account"
    # Add the user to the "Users" group
    Add-LocalGroupMember -Group "Users" -Member $username
    # Output username and password
    Write-Output "Username: $username, Password: $password"
}

# Disable Windows Defender Real-Time Monitoring
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable Windows Defender Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Enable guest account (common misconfiguration)
Enable-LocalUser -Name "Guest"

# Set up a shared folder with weak permissions (everyone full access)
$sharePath = "C:\SharedFolder"
New-Item -Path $sharePath -ItemType Directory -Force
icacls $sharePath /grant everyone:F
New-SmbShare -Name "OpenShare" -Path $sharePath -FullAccess everyone

# Configure SMB Server to use SMBv1 (vulnerable to numerous exploits)
Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force

# Disable SMB signing (increases vulnerability to man-in-the-middle attacks)
Set-SmbServerConfiguration -RejectUnencryptedAccess $false -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RequireSecuritySignature" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RequireSecuritySignature" -Value 0 -Force

# Create a globally writable PowerShell script
# You have to create the script and place it
$scriptPath = "C:\Scripts\EmptyBin.ps1"
New-Item -Path $scriptPath -ItemType File -Force
Add-Content -Path $scriptPath -Value 'Write-Output "This script can be modified by anyone."'
icacls $scriptPath /grant everyone:M

# Create a scheduled task to run the globally writable script
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $scriptPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
Register-ScheduledTask -TaskName "Empty Recyle Bin" -Action $action -Trigger $trigger -Principal $principal -Force

# Disable UAC
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Force
# Set UAC to never notify (vulnerable setting)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0


# Unrestricted PowerShell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" -Name "ExecutionPolicy" -Value "Unrestricted" -Force

