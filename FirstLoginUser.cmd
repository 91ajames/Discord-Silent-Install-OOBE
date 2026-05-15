@echo off
setlocal EnableDelayedExpansion

set "LOG=C:\FirstLogin_Log.txt"
set "SCRIPT_START=%TIME%"
set "REBOOT_REQUIRED=0"

echo ================================================== >> "%LOG%"
echo %DATE% %TIME% - FirstLogin Script Started >> "%LOG%"
echo ================================================== >> "%LOG%"

:: --------------------------------------------------
:: Prevent execution in Audit Mode
:: --------------------------------------------------
reg query HKLM\SYSTEM\Setup /v SystemSetupInProgress | find "0x1" >nul
if %errorlevel%==0 exit /b

:: --------------------------------------------------
:: Allow Windows login to settle
:: --------------------------------------------------
echo Waiting 10 seconds for Windows login to settle... >> "%LOG%"
timeout /t 10 >nul

:: --------------------------------------------------
:: Delete SetupComplete
:: --------------------------------------------------
:: del /f /q "C:\Scripts.lnk"
rd /s /q "C:\Windows\Setup\Scripts"

:: ==================================================
:: NOTEPAD++ INSTALL
:: ==================================================
:: set "NPP_INSTALLER=C:\npp.8.9.2.Installer.x64.exe"
:: if exist "%NPP_INSTALLER%" (
::    echo Installing Notepad++... >> "%LOG%"
::    start /wait "" "%NPP_INSTALLER%" /S >> "%LOG%" 2>&1

    :: Delete Notepad++ temp files
::    echo Cleaning Notepad++ temp files... >> "%LOG%"
::    for /r "%ProgramFiles%\Notepad++" %%T in (*.tmp) do (
::        del /f "%%T" >> "%LOG%" 2>&1
::        if exist "%%T" (
::            echo FAILED to delete %%T >> "%LOG%"
::        ) else (
::            echo Deleted %%T >> "%LOG%"
::        )
::    )

::    del "%NPP_INSTALLER%" /f /q
::    echo Notepad++ Installed and temp files cleared >> "%LOG%"
::)

:: ==================================================
:: REG FILE IMPORTS (PowerISO & ClassicShell)
:: ==================================================
set "POWERISO_REG=C:\PowerISO.reg"
if exist "%POWERISO_REG%" (
    echo Importing PowerISO license... >> "%LOG%"
    reg import "%POWERISO_REG%" >> "%LOG%" 2>&1
    if %errorlevel% EQU 0 (
        echo PowerISO license imported successfully >> "%LOG%"
        del "%POWERISO_REG%" /f /q
        echo Deleted PowerISO.reg >> "%LOG%"
    ) else (
        echo PowerISO license import FAILED >> "%LOG%"
    )
)

set "CLASSICSHELL_REG=C:\ClassicShell.reg"
if exist "%CLASSICSHELL_REG%" (
    echo Importing ClassicShell settings... >> "%LOG%"
    reg import "%CLASSICSHELL_REG%" >> "%LOG%" 2>&1
    if %errorlevel% EQU 0 (
        echo ClassicShell settings imported successfully >> "%LOG%"
        del "%CLASSICSHELL_REG%" /f /q
        echo Deleted ClassicShell.reg >> "%LOG%"
    ) else (
        echo ClassicShell import FAILED >> "%LOG%"
    )
)

:: ==================================================
:: Classic Shell Part 2
:: ==================================================
"C:\Program Files\Open-Shell\StartMenu.exe" -xml C:\ClassicShell.xml
    echo Importing ClassicShell settings Part 2... >> "%LOG%"
    del "C:\ClassicShell.xml" /f /q
    echo Deleted ClassicShell.xml >> "%LOG%"

:: ==================================================
:: DISCORD INSTALL
:: ==================================================
set "DISCORD_INSTALLER=C:\DiscordSetup.exe"
set "DISCORD_APPFOLDER=%LOCALAPPDATA%\Discord"
set "USER_STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Discord Inc"
set "USER_SHORTCUT=%USER_STARTMENU%\Discord.lnk"
set "ALLUSERS_STARTMENU=C:\ProgramData\Microsoft\Windows\Start Menu\Programs"

if exist "%DISCORD_INSTALLER%" (
    echo Launching Discord installer... >> "%LOG%"
    start "" "%DISCORD_INSTALLER%" --silent >> "%LOG%" 2>&1

    :: Wait for Discord install folder
    set FOUND=
    set /a ELAPSED=0
    set /a MAX_WAIT=920
    :WaitDiscordInstall
    for /d %%D in ("%DISCORD_APPFOLDER%\app-*") do set FOUND=1
    if defined FOUND goto DiscordInstalled
    if !ELAPSED! GEQ !MAX_WAIT! goto DiscordTimeout
    timeout /t 2 >nul
    set /a ELAPSED+=2
    goto WaitDiscordInstall

    :DiscordInstalled
    echo Discord install detected after !ELAPSED! seconds >> "%LOG%"

    :: Wait for Start Menu shortcut
    set FOUND=
    set /a SHORTCUT_WAIT=0
    set /a SHORTCUT_MAX=920
    :WaitDiscordShortcut
    if exist "%USER_SHORTCUT%" set FOUND=1
    if defined FOUND goto MoveDiscordShortcut
    if !SHORTCUT_WAIT! GEQ !SHORTCUT_MAX! goto SkipShortcutMove
    timeout /t 2 >nul
    set /a SHORTCUT_WAIT+=2
    goto WaitDiscordShortcut

    :MoveDiscordShortcut
    echo Discord shortcut detected after !SHORTCUT_WAIT! seconds >> "%LOG%"
    move "%USER_SHORTCUT%" "%ALLUSERS_STARTMENU%" >nul 2>&1
    echo Moved Discord shortcut to All Users Start Menu >> "%LOG%"
    if exist "%USER_STARTMENU%" (
        rd /s /q "%USER_STARTMENU%" >nul 2>&1
        echo Removed user Discord Inc folder >> "%LOG%"
    )
    goto DiscordCleanup

    :SkipShortcutMove
    echo Discord shortcut not found within timeout window >> "%LOG%"
    goto DiscordCleanup

    :DiscordTimeout
    echo Discord install not detected within 7 minutes >> "%LOG%"
    goto DiscordCleanup

    :DiscordCleanup
    :: Delete Discord temp files
    echo Cleaning Discord temp files... >> "%LOG%"
    for /r "%DISCORD_APPFOLDER%" %%T in (*.tmp) do (
        del /f "%%T" >> "%LOG%" 2>&1
        if exist "%%T" (
            echo FAILED to delete %%T >> "%LOG%"
        ) else (
            echo Deleted %%T >> "%LOG%"
        )
    )
    del "%DISCORD_INSTALLER%" /f /q >nul 2>&1
    echo Deleted Discord installer and temp files >> "%LOG%"
)

echo ================================================== >> "%LOG%"
echo %DATE% %TIME% - FirstLogin Script Finished >> "%LOG%"
echo ================================================== >> "%LOG%"

echo Self-Erase Script >> "%LOG%"
echo Delete FirstLoginUser.cmd >> "%LOG%"
echo Delete FirstLoginUser.vbs >> "%LOG%"
echo Delete 5 Sec _final_cleanup.cmd >> "%LOG%"

:: --- SELF-ERASE SCRIPT ---
set "CLEANUP_SCRIPT=C:\_final_cleanup.cmd"
(
echo @echo off
echo ping 127.0.0.1 -n 8 ^>nul
echo del /f /q "C:\FirstLoginUser.cmd" 2^>nul
echo del /f /q "C:\FirstLoginUser.vbs" 2^>nul
echo del /f /q "%CLEANUP_SCRIPT%" 2^>nul
) > "%CLEANUP_SCRIPT%"

start "" /b cmd.exe /c "%CLEANUP_SCRIPT%"