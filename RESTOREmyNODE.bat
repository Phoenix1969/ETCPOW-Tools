@echo off
setlocal enabledelayedexpansion

REM Define the specific directory paths
set "dir1=C:\Program Files (x86)\ETCMC ETC NODE LAUNCHER 1024x600\ETCMC_GUI\ETCMC_GETH"
set "dir2=C:\Program Files (x86)\ETCMC ETC NODE LAUNCHER 1920x1080\ETCMC_GUI\ETCMC_GETH"

REM Checking specified directories and setting foundDir
set "foundDir="
for %%d in ("%dir1%" "%dir2%") do (
    if exist %%d (
        set "foundDir=%%d"
        goto proceed
    )
)

if not defined foundDir (
    echo Neither directory exists.
    exit /b 1
)

:proceed

REM Changing to the found directory
pushd %foundDir%
if %errorlevel% neq 0 (
    echo Failed to change directory to %foundDir%
    exit /b 1
)

REM Performing file operations
if exist "transaction_count.txt.enc" del "transaction_count.txt.enc"
if exist "transaction_count.txt.enc.bak" ren "transaction_count.txt.enc.bak" "transaction_count.txt.enc"

if exist "etcpow_balance.txt.enc" del "etcpow_balance.txt.enc"
if exist "etcpow_balance.txt.enc.bak" ren "etcpow_balance.txt.enc.bak" "etcpow_balance.txt.enc"

popd

REM Reminder to reboot and restart the node in red
echo.
echo IMPORTANT: Please reboot your system and restart your node for the changes to take effect.
echo.

pause
exit /b 0
