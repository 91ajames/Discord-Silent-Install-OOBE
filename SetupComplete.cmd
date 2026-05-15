@echo off
setlocal EnableDelayedExpansion

:: ==================================================
:: SetupComplete Main Log
:: ==================================================
set "LOG=C:\SetupComplete_Log.txt"

if not exist "C:\" mkdir "C:\"

(
echo ==================================================
echo %DATE% %TIME% - SetupComplete Started
echo ==================================================
) >> "%LOG%"

:: --------------------------------------------------
:: Load Default User Hive (Safe Guarded)
:: --------------------------------------------------
(
echo Loading Default User Hive...
reg load HKU\DefaultUser "C:\Users\Default\NTUSER.DAT"
if !errorlevel! EQU 0 (
    reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
     /v TaskbarAl /t REG_DWORD /d 0 /f
    echo Unloading Default User Hive...
    reg unload HKU\DefaultUser
) else (
    echo ERROR: Failed to load Default User Hive.
)
) >> "%LOG%" 2>&1

:: --------------------------------------------------
:: Enable Classic Context Menu (Win11)
:: --------------------------------------------------
(
echo Enabling Classic Context Menu...
reg add "HKLM\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
) >> "%LOG%" 2>&1

:: --------------------------------------------------
:: Enable Windows Photo Viewer
:: --------------------------------------------------
if exist "C:\EnablePhotoViewer.reg" (
    (
    echo Importing Windows Photo Viewer registry...
    reg import "C:\EnablePhotoViewer.reg"
    del /f /q "C:\EnablePhotoViewer.reg"
    ) >> "%LOG%" 2>&1
) else (
    echo Photo Viewer REG file not found. >> "%LOG%"
)

:: --------------------------------------------------
:: Schedule FirstLoginUser.vbs (Guarded)
:: --------------------------------------------------
if exist "C:\FirstLoginUser.vbs" (
    (
    echo Setting RunOnce for FirstLoginUser.vbs...
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" ^
     /v InstallApps ^
     /t REG_SZ ^
     /d "wscript.exe \"C:\FirstLoginUser.vbs\"" ^
     /f
    ) >> "%LOG%" 2>&1
) else (
    echo FirstLoginUser.vbs not found. >> "%LOG%"
)

:: --------------------------------------------------
:: Finish
:: --------------------------------------------------
(
echo ==================================================
echo %DATE% %TIME% - SetupComplete Finished
echo ==================================================
) >> "%LOG%"

exit /b 0