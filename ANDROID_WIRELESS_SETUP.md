# 🔌 Android Wireless Device Connection on macOS

## Prerequisites
- Android phone with USB Debugging enabled
- macOS with ADB (Android Debug Bridge) installed
- Same WiFi network on both Mac and Android phone
- Flutter properly installed

---

## Step-by-Step Setup

### Step 1: Install ADB (if not installed)

```bash
# Install using Homebrew
brew install android-platform-tools

# Verify installation
adb version
```

### Step 2: Connect Phone via USB First (Required!)

**Important:** You MUST connect via USB first to enable wireless debugging.

1. Connect your Android phone to Mac via USB cable
2. On your phone, tap **Allow** when prompted for USB Debugging permission
3. On your Mac, verify connection:

```bash
adb devices
```

You should see:
```
List of attached devices
DEVICE_ID                          device
```

### Step 3: Enable Wireless Debugging on Phone

**Android 11+:**
1. Settings → Developer Options
2. Scroll down to find **Wireless Debugging** (or **Wireless Device Connection**)
3. Toggle it **ON**
4. Tap **Allow** when prompted

**Android 10 and below:**
Wireless debugging may not be available. Use USB connection instead.

### Step 4: Get Your Phone's IP Address

**Option A - From Developer Options (Recommended):**
1. Go to Settings → Developer Options → Wireless Debugging
2. Your IP will be shown (format: `192.168.x.x:port`)

**Option B - From your phone:**
1. Settings → About Phone → Status
2. Look for "IP Address"

### Step 5: Set Up Wireless Connection

```bash
# Replace YOUR_PHONE_IP with your actual IP from Step 4
# Default port is 5555, but check your Wireless Debugging screen

adb connect YOUR_PHONE_IP:5555

# Example:
# adb connect 192.168.1.100:5555
```

You should see:
```
connected to 192.168.1.100:5555
```

### Step 6: Disconnect USB Cable

Once connected wirelessly, you can safely disconnect the USB cable.

### Step 7: Verify Connection

```bash
adb devices
```

You should see:
```
List of attached devices
192.168.1.100:5555                 device
```

### Step 8: Run Flutter App

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
cd "/Users/anuragsharma/Workspace/Projects/APP Development/Flutter/makret_mind_ai"
flutter run
```

---

## Automated Setup Script

Save this as `.macos` in your project root or run directly:

```bash
#!/bin/bash

# macOS Android Wireless Debug Setup Script

echo "🔧 Setting up Android Wireless Debugging..."

# Step 1: Check if ADB is installed
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Installing..."
    brew install android-platform-tools
fi

echo "✅ ADB installed: $(adb version | head -1)"

# Step 2: Prompt for phone connection via USB
echo ""
echo "📱 Connect your Android phone via USB cable and enable USB Debugging"
echo "Press ENTER when ready..."
read -r

# Step 3: Wait for device
echo "⏳ Waiting for device..."
adb wait-for-device
echo "✅ Device found!"

# Step 4: List connected devices
echo ""
echo "📋 Connected devices:"
adb devices

# Step 5: Get device IP
echo ""
echo "🌐 Getting device IP address..."
DEVICE_IP=$(adb shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)

if [ -z "$DEVICE_IP" ]; then
    echo "⚠️  Could not auto-detect IP. Please enter manually:"
    read -p "Enter device IP (e.g., 192.168.1.100): " DEVICE_IP
fi

echo "✅ Device IP: $DEVICE_IP"

# Step 6: Enable wireless debugging
echo ""
echo "📡 Setting up wireless debugging on port 5555..."
adb tcpip 5555

# Step 7: Connect wirelessly
echo ""
echo "🔗 Connecting wirelessly..."
adb connect "$DEVICE_IP:5555"

# Step 8: Disconnect USB
echo ""
echo "✂️  You can now disconnect the USB cable"

# Step 9: Verify
echo ""
echo "✅ Final device list:"
adb devices

# Step 10: Set Java version and run
echo ""
echo "🚀 Ready to run Flutter app!"
echo ""
echo "Use this command to run the app:"
echo "export JAVA_HOME=\$(/usr/libexec/java_home -v 17)"
echo "flutter run"
```

---

## Troubleshooting

### Phone not detected via USB?
```bash
# Check if device is recognized
adb devices

# If not showing:
# 1. Disconnect and reconnect USB
# 2. Revoke USB debugging: Settings → Developer Options → Revoke USB Debugging Authorizations
# 3. Tap Allow on your phone again
```

### Can't find Wireless Debugging option?
```bash
# Your Android version may not support it
# Use USB connection instead, or update your phone
adb devices  # Shows USB connection
```

### Connection keeps dropping?
```bash
# Restart ADB daemon
adb kill-server
adb start-server

# Reconnect wirelessly
adb connect YOUR_PHONE_IP:5555
```

### Device shows "offline"?
```bash
# Check if same WiFi network
# Restart wireless debugging on phone
# Reconnect:
adb disconnect YOUR_PHONE_IP:5555
adb connect YOUR_PHONE_IP:5555
```

### Device not found by Flutter?
```bash
# Set Java version first
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Check devices
flutter devices

# Then run
flutter run
```

---

## Quick Commands Reference

```bash
# List all connected devices
adb devices

# Connect wirelessly
adb connect 192.168.1.100:5555

# Disconnect wireless device
adb disconnect 192.168.1.100:5555

# Restart ADB
adb kill-server
adb start-server

# Get device IP via ADB
adb shell ip addr show wlan0

# Forward port (if needed)
adb forward tcp:8080 tcp:8080

# See device logs
adb logcat

# See Flutter logs only
adb logcat | grep flutter
```

---

## Complete Workflow

1. **First time setup:**
   ```bash
   # Connect via USB
   adb devices
   
   # Get IP from phone settings
   # Enable Wireless Debugging on phone
   
   # Set up wireless connection
   adb tcpip 5555
   adb connect YOUR_IP:5555
   ```

2. **Daily usage (phone already set up):**
   ```bash
   # Simply connect wirelessly
   adb connect YOUR_PHONE_IP:5555
   
   # Check connection
   adb devices
   
   # Run app
   export JAVA_HOME=$(/usr/libexec/java_home -v 17)
   flutter run
   ```

3. **Troubleshoot if connection lost:**
   ```bash
   adb disconnect
   adb kill-server
   adb start-server
   adb connect YOUR_PHONE_IP:5555
   ```

---

## Environment Setup (.zshrc or .bash_profile)

To make it easier, add this to your shell profile:

```bash
# Add to ~/.zshrc (if using zsh) or ~/.bash_profile (if using bash)

# Set Java 17 for Flutter/Gradle
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Add Android SDK to PATH
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH

# Flutter function for wireless connection
alias adb-wireless="adb tcpip 5555 && adb connect"
alias flutter-run-wireless="export JAVA_HOME=\$(/usr/libexec/java_home -v 17) && flutter run"
```

Then reload your shell:
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

Now you can use:
```bash
# Connect device
adb-wireless 192.168.1.100:5555

# Run app
flutter-run-wireless
```

---

## ✅ You're All Set!

Your Android phone should now appear in:
```bash
flutter devices
```

And you can run:
```bash
flutter run
```

Happy coding! 🚀
