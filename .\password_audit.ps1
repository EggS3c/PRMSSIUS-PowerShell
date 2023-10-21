# Output file for the audit report
$REPORT_FILE = "password_audit_report.txt"

# Function to display script banner
function Display-Banner {
    Write-Host @"
  ██████╗ ██████╗ ███╗   ███╗███████╗███████╗██╗██╗   ██╗███████╗
  ██╔══██╗██╔══██╗████╗ ████║██╔════╝██╔════╝██║██║   ██║██╔════╝
  ██████╔╝██████╔╝██╔████╔██║███████╗██████╗  ██║██║   ██║███████╗
  ██╔═══╝ ██╔══██╗██║╚██╔╝██║╚════██║╚════██╗██║██║   ██║╚════██║
  ██║     ██║  ██║██║ ╚═╝ ██║███████║██████╔╝██║╚██████╔╝███████║
  ╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝ ╚═════╝ ╚══════╝
"@
}

# Function to display script usage and help
function Display-Help {
    Display-Banner
    Write-Host "-----------------------------------"
    Write-Host "This script audits the strength of user passwords on a Windows system and optionally creates new users."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "   .\password_audit.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "   -h, --help          Display this help message."
    Write-Host "   -c, --create-user   Create a new user interactively after the audit."
    Write-Host "   -r, --root-user     Create a temporary user with administrative privileges (use with extreme caution)."
    Write-Host "   -p, --password-reset Reset a user's password interactively."
    Write-Host "   -o, --display-options Display selected script options at the end of the script."
    Write-Host ""
    Write-Host "When to use:"
    Write-Host "   - Use this script to audit the strength of passwords on your Windows system."
    Write-Host "   - It helps identify weak or short passwords and provides recommendations."
    Write-Host "   - You can also create new users with strong passwords interactively."
    Write-Host "   - Run this script when you want to assess and improve password security."
    exit
}

# Function to check if a password is weak and provide recommendations
function Check-Password-Strength {
    param (
        [string]$user,
        [string]$password
    )

    # Check if the password is too short
    $minLength = 8  # Minimum password length
    $recommendedLength = 12  # Recommended password length

    if ($user -eq "Administrator" -or $user -eq $env:USERNAME) {
        Write-Host "$user Exempt $password (User-specific)" | Out-File -Append $REPORT_FILE
    }
    elseif ($password.Length -lt $minLength) {
        Write-Host "$user Weak $password (Consider a longer password) (Possible Privilege Escalation Risk)" | Out-File -Append $REPORT_FILE
    }
    else {
        Write-Host "$user Strong $password" | Out-File -Append $REPORT_FILE
    }
}

# Function to create a new user
function Create-New-User {
    param (
        [string]$newUser,
        [string]$newPassword
    )

    # Check if the user already exists
    $existingUser = net user $newUser | Select-String "User name" -Quiet
    if ($existingUser) {
        Write-Host "User '$newUser' already exists. Skipping user creation."
        return
    }

    # Create the new user with the specified password
    $createUserCommand = "net user $newUser $newPassword /add"
    Invoke-Expression $createUserCommand
    Write-Host "User '$newUser' created."
}

# Function to create a temporary user with administrative privileges
function Create-Root-User {
    param (
        [string]$rootUser,
        [string]$rootPassword
    )

    # Check if the user already exists
    $existingUser = net user $rootUser | Select-String "User name" -Quiet
    if ($existingUser) {
        Write-Host "User '$rootUser' already exists. Skipping user creation."
        return
    }

    # Create the temporary user with administrative privileges
    $createUserCommand = "net user $rootUser $rootPassword /add"
    Invoke-Expression $createUserCommand

    $addUserToAdminGroupCommand = "net localgroup Administrators $rootUser /add"
    Invoke-Expression $addUserToAdminGroupCommand

    Write-Host "Temporary user '$rootUser' created with administrative privileges."
}

# Function to reset a user's password
function Reset-User-Password {
    param (
        [string]$user,
        [string]$newPassword
    )

    # Check if the user exists
    $existingUser = net user $user | Select-String "User name" -Quiet
    if ($existingUser) {
        # Reset the user's password
        $resetPasswordCommand = "net user $user $newPassword"
        Invoke-Expression $resetPasswordCommand
        Write-Host "Password for user '$user' reset."
    }
    else {
        Write-Host "User '$user' does not exist. Password reset failed."
    }
}

# Function to display selected script options
function Display-Selected-Options {
    Write-Host ""
    Write-Host "Selected Script Options:"
    Write-Host "Create User: $CREATE_USER"
    Write-Host "Create Root User: $CREATE_ROOT_USER"
    Write-Host "Reset User Password: $RESET_PASSWORD"
    Write-Host "Display Options at the End: $DISPLAY_OPTIONS"
}

# Function to perform the password audit
function Password-Audit {
    Display-Banner
    Write-Host "Password Audit Report" | Out-File $REPORT_FILE
    Write-Host "Minimum Password Length: 8 characters" | Out-File -Append $REPORT_FILE
    Write-Host "Recommended Password Length: 12 characters or more" | Out-File -Append $REPORT_FILE
    Write-Host "User`t`tStatus`t`tPassword" | Out-File -Append $REPORT_FILE

    $users = net user | Select-String "User name"
    foreach ($user in $users) {
        $userName = $user -split "  +"
        $userName = $userName[1].Trim()
        $passwordInfo = net user $userName | Select-String "Password last set"
        $passwordLastSet = $passwordInfo -split "  +"
        $passwordLastSet = $passwordLastSet[3].Trim()
        Check-Password-Strength $userName $passwordLastSet
    }
}

# Check if the script is run as an administrator
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an administrator."
    exit 1
}

# Initialize option variables
$CREATE_USER = $false
$CREATE_ROOT_USER = $false
$RESET_PASSWORD = $false
$DISPLAY_OPTIONS = $false

# Check for script options
foreach ($arg in $args) {
    switch -Regex ($arg) {
        "-h|--help" {
            Display-Help
        }
        "-c|--create-user" {
            $CREATE_USER = $true
        }
        "-r|--root-user" {
            $CREATE_ROOT_USER = $true
        }
        "-p|--password-reset" {
            $RESET_PASSWORD = $true
        }
        "-o|--display-options" {
            $DISPLAY_OPTIONS = $true
        }
        default {
            Write-Host "Unknown option: $arg"
            Display-Help
        }
    }
}

# Run the password audit
Password-Audit

# Display the audit report
Get-Content $REPORT_FILE

Write-Host "Password audit completed. Report saved in '$REPORT_FILE'."

# Prompt to create a new user
if ($CREATE_USER) {
    $createUserOption = Read-Host "Do you want to create a new user? (y/n)"

    if ($createUserOption -eq "y") {
        $newUser = Read-Host "Enter the username for the new user"
        $newPassword = Read-Host "Enter the password for the new user" -AsSecureString
        Create-New-User $newUser $newPassword
    }
}

# Create a temporary user with administrative privileges if specified
if ($CREATE_ROOT_USER) {
    $createRootUserOption = Read-Host "Create a temporary user with administrative privileges? (use with extreme caution) (y/n)"

    if ($createRootUserOption -eq "y") {
        $rootUser = Read-Host "Enter the username for the temporary root user"
        $rootPassword = Read-Host "Enter the password for the temporary root user" -AsSecureString
        Create-Root-User $rootUser $rootPassword
    }
}

# Reset a user's password if specified
if ($RESET_PASSWORD) {
    $resetPasswordOption = Read-Host "Reset a user's password? (y/n)"

    if ($resetPasswordOption -eq "y") {
        $resetUser = Read-Host "Enter the username for the user whose password you want to reset"
        $newPassword = Read-Host "Enter the new password for the user" -AsSecureString
        Reset-User-Password $resetUser $newPassword
    }
}

# Display selected script options if specified
if ($DISPLAY_OPTIONS) {
    Display-Selected-Options
}
