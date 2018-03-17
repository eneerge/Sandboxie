@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------


echo Sandboxie Installer Started

::==========================================
:: [ Check for Sandboxie Installation ]
::==========================================

set sandboxieDir="%programfiles%\Sandboxie"

echo.
echo - Checking for Sandboxie installation...

if exist %sandboxieDir% (
 color 2f
 echo - Found Sandboxie Installation.
) else (
 color 4f
 echo - ERROR: Sandboxie does not appear to be installed.
 pause
 goto end
)

::==========================================
:: [ Configure Sandboxie Directories ]
::==========================================
set sandboxieConfigFile="C:\windows\Sandboxie.ini"
if not exist "C:\windows\Sandboxie.ini" (
	set sandboxieConfigFile="%programfiles%\Sandboxie.ini"
)

:: Folder path of sandboxie default sandbox path (location of sandboxes)
set sandboxDir=C:\Sandbox\%username%

::==========================================
:: [ Configure Sandbox Application ]
::==========================================

::
:: The name the VM will be called and the name of the template nfolder (no spaces)
set sandboxName=mIRC

:: For start menu and desktop shortcuts
set appStartMenuFolder=mIRC
set appName=mIRC


:: Various options for vm
set appExePath="%sandboxDir%\%sandboxName%\drive\C\mIRC\mIRC.exe"
set appIconPath=%appExePath%
set appIconNumber=0


start "" %sandboxieDir%\start.exe /box:%sandboxName% /terminate
timeout 2
start "" %sandboxieDir%\start.exe /box:%sandboxName% delete_sandbox
timeout 3

::==========================================
:: [ Install Application ]
::==========================================
echo - Copying template sandbox to live sandbox directory
rd /S /q %sandboxDir%\%sandboxName%
robocopy "%cd%\%sandboxName%" "%sandboxDir%\%sandboxName%" /E /W:5


echo - Creating Desktop shortcuts...
call :CreateDesktopShortcut

echo - Creating Start Menu shortcuts...
call :CreateStartMenuShortcut


echo - Registering File Associations
regedit /s "%cd%\Associations.reg"

echo - Creating Sandboxie Configuration Entries For %sandboxName%
call :CreateSandbox

::==========================================
:: [ Exit Installer ]
::==========================================
echo Installation Completed!
pause
:end
echo.
echo The installer will now exit.
exit /b
goto:eof

:: =================================================================================================================================
:: =================================================================================================================================
:: =================================================================================================================================
:: =================================================================================================================================

::==========================================
:: Functions
::==========================================

:CreateDesktopShortcut
	echo   - Creating desktop shortcut for %appName%...

	echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
	(
		echo sLinkFile = "%userprofile%\Desktop\%appName%.lnk"
		echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
		echo oLink.TargetPath = %appExePath%

		echo oLink.IconLocation = %appIconPath%
		echo oLink.Save
	) >> "%temp%\CreateShortcut.vbs"

	rem Extras
	rem oLink.WindowStyle = "1"
	rem oLink.WorkingDirectory = "C:\Program Files\MyApp"
	rem oLink.Arguments = ""
	rem oLink.Description = "MyProgram"
	rem oLink.HotKey = "ALT+CTRL+F"

	cscript "%temp%\CreateShortcut.vbs" > nul
	del "%temp%\CreateShortcut.vbs" > nul
goto:eof

:CreateStartMenuShortcut
	echo   - Creating Start Menu entry for %appName%...
	if not exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%" ( mkdir "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%" )

	echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
	(
		echo sLinkFile = "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%\%appName%.lnk"
		echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
		echo oLink.TargetPath = %appExePath%
		echo oLink.IconLocation = %appIconPath%
		echo oLink.Save
	) >> "%temp%\CreateShortcut.vbs"

	cscript "%temp%\CreateShortcut.vbs" > nul
	del "%temp%\CreateShortcut.vbs" > nul
goto:eof

:CreateSandbox
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% Enabled y
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% OpenPipePath=Reflector.exe,\Device\NamedPipe\SandboxieReflectorCommands
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% ConfigLevel=7
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% AutoRecover=y
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% Template=WindowsFontCache
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% Template=BlockPorts
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% Template=LingerPrograms
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% Template=AutoRecoverIgnore
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% RecoverFolder=%Personal%
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% RecoverFolder=%Personal%\Downloads
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% RecoverFolder=%Favorites%
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% RecoverFolder=%Desktop%
	start "" %sandboxieDir%\sbieini.exe set %sandboxName% BorderColor=#00FFFF,ttl
	start "" %sandboxieDir%\start.exe /reload
goto:eof