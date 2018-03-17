# Sandboxie
### Installer.cmd - Install a Sandboxie Application
This script will:
- Create a sandbox based on how the script is configured
- Copy the contents of the sandbox folder to the Sandboxie sandbox directory. (IE: If you have a copy of "FirefoxVM" sandbox at "E:\Software\Firefox\FirefoxVM", the script will create the "FirefoxVM" Sandbox in Sandboxie, then copy all contents of "FirefoxVM" to your Sandboxie sandbox folder which is usually C:\Sandbox\user\FirefoxVM
- Create start menu shortcuts for the specified exe.
- Create desktop shortcut for the specified exe.

1. Configure variables in script
- <b>sandboxName</b> - This is the name of the Sandbox the script will create
- <b>appStartMenuFolder</b> - The folder to place shortcuts in on the start menu.
- <b>appName</b> - The name of the application
- <b>appIconPath</b> - Full path to the exe.
- <b>appExePath</b> - Full path to the icon.
- <b>appIconNumber</b> - (not implemented) Resource number inside of the icon resource file.

2. Ensure you have a copy of the sandbox you want to deploy in the same folder as the installer.cmd

3. Launch


