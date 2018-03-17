@echo off
:: BatchGotAdmin
:-------------------------------------
mkdir "%windir%\BatchGotAdmin"
if '%errorlevel%' == '0' (
  rmdir "%windir%\BatchGotAdmin" & goto gotAdmin 
) else ( goto UACPrompt )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute %0, "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"      
    CD /D "%~dp0""
:--------------------------------------
echo Sandboxie Installer Started

::==========================================
:: [ Check for Sandboxie Installation ]
::==========================================
set sandboxieDir=%programfiles%\Sandboxie

echo.
echo - Checking for Sandboxie installation...

if exist "%sandboxieDir%" (
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
:: The name the VM will be called and the name of the template folder (no spaces)
set sandboxName=Firefox
set sandboxToRunIn=Firefox

:: For start menu and desktop shortcuts
set appStartMenuFolder=Mozilla Firefox
set appName=Mozilla Firefox


:: Various options for vm
set appExePath=%sandboxDir%\%sandboxName%\drive\C\Program Files\Mozilla Firefox\firefox.exe
set appIconPath=%appExePath%
set appIconNumber=0

::==========================================
:: [ Terminate Running Sandbox Application ]
::==========================================
start "" "%sandboxieDir%\start.exe" /box:%sandboxName% /terminate
if %sandboxToRunIn% neq %sandboxName (
  start "" "%sandboxieDir%\start.exe" /box:%sandboxToRunIn% /terminate
)
timeout 1

start "" "%sandboxieDir%\start.exe" /box:%sandboxName% delete_sandbox
timeout 2
if %sandboxToRunIn% neq %sandboxName (
  start "" "%sandboxieDir%\start.exe" /box:%sandboxToRunIn% delete_sandbox
  timeout 1
)

::==========================================
:: [ Install Application ]
::==========================================
echo - Copying template sandbox to live sandbox directory
if %sandboxToRunIn% neq %sandboxName (
  rd /S /q %sandboxDir%\%sandboxToRunIn%
)
rd /S /q %sandboxDir%\%sandboxName%
md /S /q %sandboxDir%\%sandboxName%
robocopy "%cd%\%sandboxName%" %sandboxDir%\%sandboxName% /E /W:5

if %sandboxToRunIn% neq %sandboxName (
  robocopy "%cd%\%sandboxToRunIn%" %sandboxDir%\%sandboxToRunIn% /E /W:5
)


echo - Creating Desktop shortcuts...
call :CreateDesktopShortcut

echo - Creating Start Menu shortcuts...
call :CreateStartMenuShortcut

echo - Creating Sandboxie Configuration Entries For %sandboxName%
call :CreateSandbox

::==========================================
:: [ Exit Installer ]
::==========================================
echo Installation Completed!

:end
echo.
echo The installer will now exit.
pause
exit /b
goto:eof

:: =================================================================================================================================
:: =================================================================================================================================
:: =================================================================================================================================

::==========================================
:: Functions
::==========================================

:CreateDesktopShortcut
	echo   - Creating desktop shortcut for %appName%...
	del /q "%userprofile%\Desktop\%appName%.lnk"
	echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
	(
		echo sLinkFile = "%userprofile%\Desktop\%appName%.lnk"
		echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
		echo oLink.TargetPath = "%appExePath%"        
		echo oLink.IconLocation = "%appIconPath%"
		echo oLink.Save
	) >> "%temp%\CreateShortcut.vbs"

	rem Extras
	rem oLink.WindowStyle = "1"   
	rem oLink.WorkingDirectory = "C:\Program Files\MyApp"
	rem oLink.Description = "MyProgram"   
	rem oLink.HotKey = "ALT+CTRL+F"
	rem echo oLink.Arguments = "/box:%sandboxToRunIn% %appExePath%"

	cscript "%temp%\CreateShortcut.vbs" > nul
	del "%temp%\CreateShortcut.vbs" > nul
goto:eof

:CreateStartMenuShortcut
	echo   - Creating Start Menu entry for %appName%...
	if not exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%" ( mkdir "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%" )
        del /q "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%\%appName%.lnk"
	echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
	(
		echo sLinkFile = "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\%appStartMenuFolder%\%appName%.lnk"
        echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
		echo oLink.TargetPath = "%appExePath%"
		echo oLink.IconLocation = "%appIconPath%"
		echo oLink.Save
	) >> "%temp%\CreateShortcut.vbs"

        rem echo oLink.Arguments = "/box:%sandboxToRunIn% %appExePath%"

	cscript "%temp%\CreateShortcut.vbs" > nul
	del "%temp%\CreateShortcut.vbs" > nul
goto:eof

:CreateSandbox
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% Enabled y
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% OpenPipePath=Reflector.exe,\Device\NamedPipe\SandboxieReflectorCommands
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% ConfigLevel=7
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% AutoRecover=y
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% Template=WindowsFontCache
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% Template=BlockPorts
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% Template=LingerPrograms
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% Template=AutoRecoverIgnore
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% RecoverFolder=%Personal%
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% RecoverFolder=%Personal%\Downloads
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% RecoverFolder=%Favorites%
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% RecoverFolder=%Desktop%
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxName% BorderColor=#00FFFF,ttl

	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% Enabled y
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% OpenPipePath=Reflector.exe,\Device\NamedPipe\SandboxieReflectorCommands
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% ConfigLevel=7
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% AutoRecover=y
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% Template=WindowsFontCache
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% Template=BlockPorts
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% Template=LingerPrograms
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% Template=AutoRecoverIgnore
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% RecoverFolder=%Personal%
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% RecoverFolder=%Personal%\Downloads
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% RecoverFolder=%Favorites%
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% RecoverFolder=%Desktop%
	start "" "%sandboxieDir%\sbieini.exe" set %sandboxToRunIn% BorderColor=#00FFFF,ttl


	start "" "%sandboxieDir%\start.exe" /reload
goto:eof