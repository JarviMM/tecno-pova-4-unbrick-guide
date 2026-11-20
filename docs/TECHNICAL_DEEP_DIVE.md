# Technical Architecture: Transsion MT6789 Unbrick Analysis

## 1. The BROM Lockout Problem (SP Flash Tool Failure)

Transsion devices (Tecno, Infinix, itel) running MediaTek Helio G99 (`MT6789`) enforce secure boot validation via SLA (Serial Link Authentication) and DAA (Download Agent Authentication). 

When attempting standard flashing via SP Flash Tool V6:
* Handshake completes via PreLoader VCOM (`0E8D:2000`).
* The Download Agent (`DA_BR.bin`) halts with:
  ```text
  error_msg: Server is not authenticated. Locked.
  ```
Because Transsion servers require token-based auth for MT6789, hardware-level BROM unbricking is restricted to authorized service centers unless using commercial hardware boxes.

---

## 2. Fastboot vs. Fastbootd Architecture

To bypass BROM restrictions without commercial tools, the device must be partitioned via Android's Dual Fastboot stack:

### A. Hardware Bootloader (`is-userspace: no`)
* **Hardware ID:** `USB\VID_0E8D&PID_201C` (MediaTek Bootloader).
* **Driver:** Google WinUSB (`android_winusb.inf`) bound to `Android Bootloader Interface`.
* **Writable Partitions:** Low-level static partitions (`lk`, `boot`, `vendor_boot`, `dtbo`, `tee`, `scp`, `sspm`, `gz`, `md1img`, `vbmeta`).
* **Security Controls:** Allows executing `fastboot flashing unlock`.

### B. Userspace Recovery Fastbootd (`is-userspace: yes`)
* **Hardware ID:** `USB\VID_18D1&PID_4EE0` (Google Fastboot).
* **Driver:** Android Composite ADB/Fastboot interface.
* **Writable Partitions:** Logical/Dynamic partitions container (`super.img`), containing `/system`, `/vendor`, `/product`, `/odm`, `/system_ext`.
* **Limitation:** Rejects writing to physical firmware partitions (`remote: No such file or directory`).

---

## 3. Resolving the "Orange State" 5-Second Bootloop (AVB 2.0)

When flashing custom or cross-build stock partitions on an unlocked MT6789 bootloader:
1. Little Kernel (`lk`) boots and displays:
   ```text
   Orange State: OS Not Being Verified Or Custom OS. Dismiss After 5 Seconds.
   ```
2. After 5 seconds, AVB (Android Verified Boot 2.0) attempts cryptographic verification.
3. If `vbmeta.img` points to `vbmeta_system` or `vbmeta_vendor` and the cryptographic hashes or rollback indices do not match, AVB panics the kernel or forces an immediate hardware watchdog reboot.
4. **Fix:**
   * Modify the AVB header flags at offset 120 (`0x78`) from `0x00000000` to `0x00000003` (`AVB_VBMETA_IMAGE_FLAGS_HASHTREE_DISABLED | AVB_VBMETA_IMAGE_FLAGS_VERIFICATION_DISABLED`).
   * Flash `vbmeta`, `vbmeta_system`, and `vbmeta_vendor` with `--disable-verity --disable-verification`.
   * Flash all hardware coprocessors (`scp`, `sspm`, `tee`, `gz`) to both slots (`_a` and `_b`).
