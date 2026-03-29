# 🚀 Quick Start - Connect & Run Your Android Device

## TL;DR - Fastest Way to Get Started

### First Time Only (One-Time Setup)

```bash
# 1. Connect phone via USB
# 2. Enable USB Debugging on your phone (Settings → Developer Options)
# 3. Run the automated setup script:

bash setup-android-wireless.sh

# Follow the prompts - it will handle everything!
```

### Daily Usage (After First Setup)

```bash
# Simply connect wirelessly:
adb connect YOUR_DEVICE_IP:5555

# Then run the app:
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
flutter run
```

---

## What's Your Device IP?

**Easy way to find it:**
1. On your Android phone, go to **Settings → Developer Options → Wireless Debugging**
2. Your IP will be displayed there (format: `192.168.x.x`)

---

## Troubleshooting

### Device not showing up?
```bash
# Restart ADB
adb kill-server
adb start-server

# Reconnect
adb connect YOUR_IP:5555

# Check connection
adb devices
```

### Still not working?
```bash
# Fall back to USB (always works)
# Just connect via USB and run:
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
flutter run
```

### Java error?
```bash
# Make sure Java 17 is set
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
flutter run
```

---

## Files in This Project

| File | Purpose |
|------|---------|
| `setup-android-wireless.sh` | 🤖 Automated setup script |
| `ANDROID_WIRELESS_SETUP.md` | 📖 Detailed guide |
| `SETUP_GUIDE.md` | 📋 General project setup |
| `QUICK_REFERENCE.md` | ⚡ Daily command reference |

---

## Your Current Status

✅ Branch: `sharma-ui`  
✅ Dependencies: Installed  
✅ Build System: Ready (Java 17)  
✅ ADB: Available  

**Next Step:** Run the setup script!

```bash
bash setup-android-wireless.sh
```

---

**Questions?** Check the detailed guides above! 🎉
