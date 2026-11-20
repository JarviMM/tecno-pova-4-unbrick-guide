@echo off
title Tecno Pova 4 - Unlock Bootloader
color 0E

echo ========================================================
echo   Tecno Pova 4 Bootloader Unlock
echo ========================================================
echo.
echo Make sure device is connected in Bootloader mode (VID 0E8D PID 201C).
echo.

fastboot devices
fastboot getvar unlocked
echo.
echo Requesting unlock... (Look at the phone screen to confirm with Volume Up)
fastboot flashing unlock
echo.
pause
