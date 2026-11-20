@echo off
setlocal enabledelayedexpansion
title Tecno Pova 4 (LG7n) Unbrick Tool
color 0A

echo ========================================================
echo   Tecno Pova 4 (LG7n / MT6789) Unbrick Procedure
echo ========================================================
echo.

set "FASTBOOT=fastboot.exe"
where %FASTBOOT% >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] fastboot.exe not found in PATH.
    echo Place platform-tools in PATH or in this folder.
    pause
    exit /b 1
)

echo Checking connected device...
%FASTBOOT% devices
echo.

echo [1/5] Disabling AVB verification (vbmeta)...
%FASTBOOT% --disable-verity --disable-verification flash vbmeta vbmeta_patched.img
%FASTBOOT% --disable-verity --disable-verification flash vbmeta_a vbmeta_patched.img
%FASTBOOT% --disable-verity --disable-verification flash vbmeta_b vbmeta_patched.img
%FASTBOOT% flash vbmeta_system_a vbmeta_system_patched.img
%FASTBOOT% flash vbmeta_system_b vbmeta_system_patched.img
%FASTBOOT% flash vbmeta_vendor_a vbmeta_vendor_patched.img
%FASTBOOT% flash vbmeta_vendor_b vbmeta_vendor_patched.img

echo.
echo [2/5] Flashing core boot images...
%FASTBOOT% flash boot_a boot.img
%FASTBOOT% flash boot_b boot.img
%FASTBOOT% flash vendor_boot_a vendor_boot.img
%FASTBOOT% flash vendor_boot_b vendor_boot.img
%FASTBOOT% flash dtbo_a dtbo.img
%FASTBOOT% flash dtbo_b dtbo.img

echo.
echo [3/5] Flashing baseband and firmware...
%FASTBOOT% flash lk_a lk.img
%FASTBOOT% flash lk_b lk.img
%FASTBOOT% flash tee_a tee.img
%FASTBOOT% flash tee_b tee.img
%FASTBOOT% flash gz_a gz.img
%FASTBOOT% flash gz_b gz.img
%FASTBOOT% flash scp_a scp.img
%FASTBOOT% flash scp_b scp.img
%FASTBOOT% flash sspm_a sspm.img
%FASTBOOT% flash sspm_b sspm.img
%FASTBOOT% flash spmfw_a spmfw.img
%FASTBOOT% flash spmfw_b spmfw.img
%FASTBOOT% flash mcupm_a mcupm.img
%FASTBOOT% flash mcupm_b mcupm.img
%FASTBOOT% flash dpm_a dpm.img
%FASTBOOT% flash dpm_b dpm.img
%FASTBOOT% flash pi_img_a pi_img.img
%FASTBOOT% flash pi_img_b pi_img.img
%FASTBOOT% flash md1img_a md1img.img
%FASTBOOT% flash md1img_b md1img.img
%FASTBOOT% flash logo_a logo.bin
%FASTBOOT% flash logo_b logo.bin

echo.
echo [4/5] Clearing user data and setting active slot...
%FASTBOOT% erase userdata
%FASTBOOT% erase metadata
%FASTBOOT% set_active a

echo.
echo [5/5] Rebooting to Android...
%FASTBOOT% reboot

echo.
echo Done! First boot may take 3 to 7 minutes.
pause
