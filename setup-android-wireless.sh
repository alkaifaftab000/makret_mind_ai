#!/bin/bash

# 🔌 macOS Android Wireless Debugging Setup Script
# Usage: bash setup-android-wireless.sh

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════╗"
echo "║  Android Wireless Debugging Setup for macOS            ║"
echo "║  Market Mind AI - Flutter App                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Step 1: Check if ADB is installed
echo ""
print_info "Step 1: Checking ADB installation..."

if ! command -v adb &> /dev/null; then
    print_warning "ADB not found. Installing via Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not installed. Please install from https://brew.sh"
        exit 1
    fi
    
    brew install android-platform-tools
    print_success "ADB installed successfully"
else
    print_success "ADB found: $(adb version 2>&1 | head -1)"
fi

# Step 2: Check Java version
echo ""
print_info "Step 2: Checking Java version..."

JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || true)
if [ -z "$JAVA_HOME" ]; then
    print_error "Java 17 not found. Please install Java 17 from https://www.oracle.com/java/technologies/downloads/"
    exit 1
fi
export JAVA_HOME
print_success "Java 17 found at: $JAVA_HOME"

# Step 3: Prompt for USB connection
echo ""
print_info "Step 3: USB Connection Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_warning "IMPORTANT: Connect your Android phone via USB cable"
echo ""
echo "On your phone:"
echo "  1. Go to Settings → Developer Options"
echo "  2. Enable USB Debugging"
echo "  3. Tap 'Allow' when prompted for USB Debugging permission"
echo ""
read -p "Press ENTER when USB is connected and allowed... " -r

# Step 4: Wait for device and verify USB connection
echo ""
print_info "Step 4: Waiting for USB device..."

timeout=30
counter=0
while ! adb devices | grep -q "device$"; do
    if [ $counter -ge $timeout ]; then
        print_error "Device not detected within $timeout seconds"
        echo ""
        print_info "Troubleshooting:"
        echo "  • Disconnect and reconnect USB cable"
        echo "  • Make sure USB Debugging is enabled"
        echo "  • Tap 'Allow' on your phone when prompted"
        echo "  • Try: adb kill-server && adb start-server"
        exit 1
    fi
    printf "."
    sleep 1
    ((counter++))
done

print_success "Device detected via USB!"
echo ""
echo "Connected devices:"
adb devices

# Step 5: Get device IP address
echo ""
print_info "Step 5: Getting device IP address..."

DEVICE_IP=$(adb shell ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 || true)

if [ -z "$DEVICE_IP" ]; then
    print_warning "Could not auto-detect IP address"
    echo ""
    echo "Get your IP manually:"
    echo "  1. On your phone, go to Settings → About Phone → Status"
    echo "  2. Look for 'IP Address'"
    echo ""
    read -p "Enter your device IP address (e.g., 192.168.1.100): " -r DEVICE_IP
fi

if [ -z "$DEVICE_IP" ]; then
    print_error "No IP address provided"
    exit 1
fi

print_success "Device IP: $DEVICE_IP"

# Step 6: Enable wireless debugging
echo ""
print_info "Step 6: Enabling wireless debugging..."

print_warning "Your device may display a prompt - tap 'Allow' if shown"
adb tcpip 5555
sleep 2

print_success "Wireless debugging enabled on port 5555"

# Step 7: Connect wirelessly
echo ""
print_info "Step 7: Connecting via WiFi..."

if adb connect "$DEVICE_IP:5555"; then
    print_success "Connected to $DEVICE_IP:5555"
else
    print_error "Failed to connect to $DEVICE_IP:5555"
    echo ""
    print_info "Troubleshooting:"
    echo "  • Make sure phone and Mac are on the same WiFi network"
    echo "  • Check if IP address is correct"
    echo "  • Restart wireless debugging on your phone"
    exit 1
fi

sleep 2

# Step 8: Verify wireless connection
echo ""
print_info "Step 8: Verifying connection..."

adb devices
echo ""

if adb devices | grep -q "$DEVICE_IP"; then
    print_success "✅ Wireless connection verified!"
else
    print_error "Wireless connection not found in device list"
    exit 1
fi

# Step 9: Optional - Test with Flutter
echo ""
print_info "Step 9: Checking Flutter setup..."

if command -v flutter &> /dev/null; then
    echo ""
    print_success "Flutter is installed"
    
    echo ""
    echo "Detected devices:"
    export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    flutter devices
else
    print_warning "Flutter not found. Install from https://flutter.dev/docs/get-started/install"
fi

# Step 10: Summary and next steps
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  ✅ Setup Complete!                                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

cat << 'EOF'
🎉 Your Android device is now connected wirelessly!

📱 Device Info:
EOF

echo "   IP: $DEVICE_IP"
echo "   Port: 5555"
echo ""

cat << 'EOF'
🚀 Next Steps:

1. Disconnect your USB cable (safe to do now)

2. To run the app:
   export JAVA_HOME=$(/usr/libexec/java_home -v 17)
   flutter run

3. To see device logs:
   adb logcat

4. To disconnect wireless device:
   adb disconnect

5. For future sessions, just run:
   adb connect YOUR_DEVICE_IP:5555

📝 Save this command for quick reconnection:
EOF

echo "   adb connect $DEVICE_IP:5555"
echo ""

cat << 'EOF'
⚡ Optional: Add to ~/.zshrc for faster commands:

# Add these lines to ~/.zshrc
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH

Then you can use:
  adb connect 192.168.1.100:5555
  flutter run
  adb logcat

💡 Need help? Check ANDROID_WIRELESS_SETUP.md in the project root

🎯 Happy coding!
EOF

echo ""
