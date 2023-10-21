# PRMSSIUS-PowerShell
Powershell script that allows the user to specify a directory name and file names, and it can also create subdirectories within directories:


Usage 

To run a PowerShell script like the one provided, follow these steps:

Prepare the Script:

Copy the entire script text to a text editor like Notepad.
Save the file with a .ps1 extension, for example, "password_audit.ps1".
Open PowerShell:

Open PowerShell as an administrator. To do this, right-click on the "Windows PowerShell" or "PowerShell" application and choose "Run as administrator."
Set Execution Policy (if needed):

If you haven't run PowerShell scripts before, you may need to set the execution policy to allow script execution. Run the following command:
powershell
Copy code
Set-ExecutionPolicy RemoteSigned
Select "Y" (Yes) when prompted.

Navigate to the Script Location:

Use the cd command to navigate to the directory where your script is saved. For example:
powershell
Copy code
cd C:\Path\To\Your\Script\Directory
Run the Script:

To run the script, use the following command:
powershell
Copy code
.\password_audit.ps1
Make sure you replace "password_audit.ps1" with the actual name you gave to your script.

Follow the On-Screen Prompts:

The script will provide on-screen prompts according to the options you choose, such as whether to create users, create a root user, reset user passwords, and display options.
Please note that when running PowerShell scripts, you should be cautious and understand the script's purpose and the potential impact on your system, especially if it involves user creation or administrative privileges. Always ensure the source of the script is trusted.
