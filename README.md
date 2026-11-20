# Tecno Pova 4 (LG7n) Unbrick Guide & AVB Bypass

Comprehensive, 100% free guide and toolkit to unbrick, unlock, and restore the **Tecno Pova 4 (TECNO-LG7n)** running the MediaTek Helio G99 (`MT6789`) chipset without paid service accounts, authorization dongles, or commercial tools (such as Pandora, UnlockTool, or Chimera).

---

## 🎯 The Challenge: Transsion MT6789 Lockout

Restoring modern Tecno / Infinix smartphones stuck in bootloops is notoriously difficult due to three barriers:
1. **BROM Server Authentication:** SP Flash Tool fails with `error_msg: Server is not authenticated. Locked.` due to Transsion SLA/DAA server requirements.
2. **Dynamic Partitions vs. Firmware Partitions:** `super.img` (4.88 GB containing `/system`, `/vendor`, `/product`) requires `fastbootd` (`18D1:4EE0`), while low-level firmware partitions (`lk`, `tee`, `md1img`, etc.) require genuine hardware `bootloader` (`0E8D:201C`).
3. **Orange State 5-Second Bootloop (AVB 2.0):** After unlocking and flashing stock images, Android Verified Boot crashes after the 5-second countdown because chained `vbmeta_system` and `vbmeta_vendor` structures are missing or have mismatched hashes.

This repository documents the exact steps and scripts to resolve all three issues.

---

## 📱 Device Specifications

* **Device:** Tecno Pova 4 (`TECNO/LG7n-GL/TECNO-LG7n`)
* **Chipset:** MediaTek Helio G99 (`MT6789`)
* **Architecture:** ARM64, A/B Dual Slot
* **Stock OS:** Android 12 (HiOS)

---

## 📁 Repository Structure

```text
tecno-pova-4-unbrick-guide/
├── docs/
│   └── TECHNICAL_DEEP_DIVE.md       # Detailed technical root cause analysis
├── scripts/
│   ├── patch_avb.py                 # Python utility to patch AVB flags (0x3)
│   ├── unlock_bootloader.bat        # Unlocks bootloader via fastboot
│   └── flash_unbrick.bat            # Flashes firmware and bypasses AVB
├── .gitignore
└── README.md
```

---

## 🛠️ Step-by-Step Recovery Procedure

### Step 1: Install Drivers
* MediaTek PreLoader USB VCOM Port (`VID_0E8D&PID_2000`).
* Google Android Bootloader Interface (`VID_0E8D&PID_201C`).
  * In Windows Device Manager, select "Update driver" -> "Browse my computer" -> "Let me pick from a list" -> "Android Device" -> "Android Bootloader Interface".

### Step 2: Unlock Bootloader
1. Power off device and boot into hardware Bootloader (Hold **Volume Down + Power**).
2. Verify connection:
   ```bash
   fastboot devices
   fastboot getvar unlock_ability
   ```
3. Execute unlock:
   ```bash
   fastboot flashing unlock
   ```
4. Confirm on the device screen by pressing **Volume Up**.

### Step 3: Flash System Image in `fastbootd`
Dynamic partitions cannot be flashed in hardware bootloader.
1. From recovery or bootloader, enter `fastbootd`:
   ```bash
   fastboot reboot fastboot
   ```
2. Verify `is-userspace: yes`.
3. Flash the complete `super.img`:
   ```bash
   fastboot flash super super.img
   ```

### Step 4: Patch AVB and Flash Firmware in Bootloader
To prevent the 5-second Orange State bootloop:
1. Return to hardware bootloader:
   ```bash
   fastboot reboot bootloader
   ```
2. Patch AVB images using `scripts/patch_avb.py`:
   ```bash
   python scripts/patch_avb.py vbmeta.img vbmeta_patched.img
   python scripts/patch_avb.py vbmeta_system.img vbmeta_system_patched.img
   python scripts/patch_avb.py vbmeta_vendor.img vbmeta_vendor_patched.img
   ```
3. Flash patched security headers and core partitions (or run `scripts/flash_unbrick.bat`):
   ```bash
   fastboot --disable-verity --disable-verification flash vbmeta vbmeta_patched.img
   fastboot --disable-verity --disable-verification flash vbmeta_a vbmeta_patched.img
   fastboot --disable-verity --disable-verification flash vbmeta_b vbmeta_patched.img
   fastboot flash vbmeta_system_a vbmeta_system_patched.img
   fastboot flash vbmeta_system_b vbmeta_system_patched.img
   fastboot flash vbmeta_vendor_a vbmeta_vendor_patched.img
   fastboot flash vbmeta_vendor_b vbmeta_vendor_patched.img
   ```
4. Flash hardware partitions (`boot`, `vendor_boot`, `dtbo`, `lk`, `tee`, `scp`, `sspm`, `gz`, `md1img`) to both slots (`_a` and `_b`).
5. Erase user data and reboot:
   ```bash
   fastboot erase userdata
   fastboot erase metadata
   fastboot set_active a
   fastboot reboot
   ```

---

## 💡 Notes & Disclaimer

* **Orange State Warning:** After unlocking the bootloader, an orange warning will display for 5 seconds on startup. This is expected behavior on MediaTek devices.
* **First Boot Duration:** The initial boot after wiping `userdata` takes between **3 to 7 minutes** while Android configures default runtime caches.
* **Disclaimer:** This guide is for educational and device recovery purposes. Use at your own risk.
