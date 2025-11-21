# 📱 Wireless ADB & Scrcpy Management on Linux

This document summarizes the custom setup for reliably connecting to an Android device wirelessly via ADB and casting the screen using Scrcpy on an Ubuntu/Zsh environment. This setup avoids manual port checking and aims to stabilize the connection on port 5555.

## 📹 Preview

<video src="preview-video.mp4" controls width="100%"></video>

---

## 🛠️ I. Prerequisites

1.  **Platform Tools (`adb`):** Installed and accessible via the command line.
2.  **`nmap`:** Installed on the Linux system for port scanning (`sudo apt install nmap`).
3.  **Scrcpy:** Executable located in `/usr/bin/adb-device-cast/scrcpy`.
4.  **Wireless Debugging:** Enabled on the Android device (Developer Options).
5.  **Static IP:** The Android device should ideally have a **static/reserved IP address** on the Wi-Fi network for the script to function reliably. for give your device a local static ip check dhcp setting on your router, in my case the static ip is 192.168.0.102

---

## ⚙️ II. Core Setup Files

### A. Configuration File (`~/adb_config.conf`)

This file stores static network information used by the connection script. It should be located in your home directory (`~`).

| Variable            | Description                                            | Example Value   |
| :------------------ | :----------------------------------------------------- | :-------------- |
| `PHONE_IP`          | The device's static IP address.                        | `192.168.0.102` |
| `RANDOM_PORT_RANGE` | The expected range for random ADB ports (Android 11+). | `30000-50000`   |

**Contents:**

```bash
# Configuration for adb_server script
PHONE_IP="192.168.0.102"
RANDOM_PORT_RANGE="30000-50000"
```

### B. Connection Script (`adb-server`)

The `adb-server` script is responsible for establishing the wireless connection and stabilizing the port to `5555`.

**Location:** `/usr/bin/adb-device-cast/adb-server`

**Functionality Flow:**

1.  Starts the ADB server (`adb start-server`).
2.  Attempts to connect to the **stable port** (`5555`).
3.  If the connection fails, it uses `nmap` to **scan the random port range** (`RANDOM_PORT_RANGE`) to find the active port.
4.  Connects using the found port.
5.  **If connected on a random port**, it executes `adb tcpip 5555` to stabilize the port, disconnects from the random port, and immediately **reconnects to the stable port (`5555`)**.
    > **Note:** The `adb tcpip 5555` command requires the initial wireless connection to be active or the device to be plugged in via USB.

---

## ⚡ III. Zsh Aliases (Workflow Commands)

Aliases are defined in your `~/.zshrc` file to streamline the process.

| Alias         | Command                                           | Purpose                                                                                                          |
| :------------ | :------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------- |
| `adb-connect` | `adb start-server`                                | Only starts the ADB server (useful for manual debugging).                                                        |
| `scrcpy-only` | `/usr/bin/adb-device-cast/scrcpy`                 | Runs Scrcpy without checking the ADB server status.                                                              |
| `cast-device` | `~/adb-server && /usr/bin/adb-device-cast/scrcpy` | **Recommended:** Runs the connection script (`adb-server`) first, and upon successful completion, starts Scrcpy. |

### To Activate Aliases:

After modifying `~/.zshrc`, run:

```bash
source ~/.zshrc
```

---

## 🖥️ IV. Desktop Shortcut

A desktop shortcut (`CastDevice.desktop`) is provided for easy access to the casting functionality without using the terminal.

### Desktop Shortcut Details

**File:** `CastDevice.desktop`

**Features:**

- **Name:** Cast Device (Scrcpy)
- **Description:** Connects to wireless ADB, stabilizes port, and starts Scrcpy
- **Icon:** `/usr/bin/adb-device-cast/icon.png`
- **Category:** Utility

**Installation:**

1. **Copy the desktop file** to your applications directory:

   ```bash
   cp CastDevice.desktop ~/.local/share/applications/
   ```

2. **Make it executable** (required for "Allow launching" to be enabled):

   ```bash
   chmod +x ~/.local/share/applications/CastDevice.desktop
   ```

3. **Enable "Allow launching":**
   - Right-click the desktop file (if placed on desktop) or find it in your application menu
   - Go to Properties → Permissions
   - Check "Allow executing file as program" or "Allow launching"
   - Alternatively, the file is already executable if you've run the `chmod +x` command above

**Usage:**

- **From Desktop:** Double-click the `CastDevice.desktop` icon (if placed on desktop)
- **From Application Menu:** Search for "Cast Device (Scrcpy)" in your application launcher
- The shortcut will automatically run the `cast-device` command, which connects to your device and starts Scrcpy

**Note:** The desktop shortcut requires the `cast-device` alias to be configured in your `~/.zshrc` file (see Section III).

---

## 🚀 V. Usage Summary

- **To Connect and Start Casting:** Use the combined alias or the desktop shortcut.
  ```bash
    cast-device
  ```
- **Post-Reboot:** After rebooting the PC, run `cast-device` or use the desktop shortcut. If the device port is randomized, the script will find it, connect, and attempt to switch it back to `5555` for future stability.
