# Phone Setup Guide

## Overview

This guide covers setting up your Android phone to run the GraphRAG processor. The phone acts as a GPU processing engine for entity extraction using the Gemma 3n E4B model.

## Supported Devices

### Tested
- **Samsung Galaxy S25 Ultra** - Snapdragon 8 Elite, Adreno 830 GPU ✅

### Recommended Specifications
- **SoC**: Snapdragon 8 Gen 2 or newer (or Exynos 2400+)
- **RAM**: 12 GB minimum
- **Storage**: 10 GB free for model
- **Android**: 14 or newer
- **GPU**: Adreno 700-series or Mali-G720+

## Prerequisites

### 1. Enable Developer Options
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. Enter PIN if prompted
4. "Developer mode enabled" will appear

### 2. Enable USB Debugging
1. Go to **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. (Optional) Enable **Stay Awake** - keeps screen on while charging

### 3. Install ADB on Laptop
```powershell
# Windows (winget)
winget install Google.PlatformTools

# Or download from:
# https://developer.android.com/tools/releases/platform-tools

# Verify installation
adb version
# Should show: Android Debug Bridge version X.X.XX
```

### 4. Connect Phone
```powershell
# Connect phone via USB
adb devices
# Should show:
# List of devices attached
# R5CXC213RHA    device

# If shows "unauthorized", check phone for USB debugging prompt
```

## Model Setup

### Download Gemma 3n E4B Model

**Option 1: Direct Download (Recommended)**
1. Go to: https://huggingface.co/google/gemma-3n-E4B-it-litert-lm
2. Accept Gemma license agreement
3. Download: `gemma-3n-E4B-it-int4.litertlm` (~4.3 GB)

**Option 2: Hugging Face CLI**
```bash
pip install huggingface_hub
huggingface-cli download google/gemma-3n-E4B-it-litert-lm --local-dir ./models
```

### Push Model to Phone
```powershell
# Create directory on phone
adb shell mkdir -p /data/local/tmp

# Push model (takes 5-10 minutes over USB)
adb push gemma-3n-E4B-it-int4.litertlm /data/local/tmp/

# Verify
adb shell ls -lh /data/local/tmp/gemma-3n-E4B-it-int4.litertlm
# Should show ~4.3G
```

### Verify Model Permissions
```powershell
adb shell chmod 644 /data/local/tmp/gemma-3n-E4B-it-int4.litertlm
```

## App Installation

### Build from Source
```powershell
cd phone-app

# Build debug APK
./gradlew assembleDebug

# Install
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### Grant Permissions
```powershell
# Storage permissions (for /sdcard/graphrag access)
adb shell pm grant com.graphrag.processor android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.graphrag.processor android.permission.WRITE_EXTERNAL_STORAGE

# For Android 11+ (MANAGE_EXTERNAL_STORAGE)
adb shell appops set com.graphrag.processor MANAGE_EXTERNAL_STORAGE allow
```

### Create Data Directories
```powershell
adb shell mkdir -p /sdcard/graphrag/input
adb shell mkdir -p /sdcard/graphrag/output
adb shell mkdir -p /sdcard/graphrag/progress
```

## Verification

### Test Model Loading
```powershell
# Clear logs
adb logcat -c

# Launch app
adb shell am start -n com.graphrag.processor/.MainActivity

# Check logs (wait 30-60 seconds for model load)
adb logcat -d | Select-String "LiteRT|Gemma|GPU"
```

**Expected Success Output:**
```
I LiteRTEngine: 🔄 Initializing LiteRT engine...
I LiteRTEngine: 📁 Model path: /data/local/tmp/gemma-3n-E4B-it-int4.litertlm
I LiteRTEngine: 📊 Model size: 4.3 GB
I LiteRTEngine: ⚡ Using GPU backend (Adreno 830)
I LiteRTEngine: ✅ Model loaded successfully (0.65s)
I MainActivity: 🎉 LiteRT GPU ready for processing
```

### Test Entity Extraction
```powershell
# Create test chunk
@'
{
  "chunks": [
    {
      "id": "test_001",
      "content": "John Smith is the CEO of Acme Corporation, headquartered in New York City. The company received $50 million in funding from Venture Capital Partners."
    }
  ]
}
'@ | Out-File -Encoding UTF8 test_chunk.json

# Push to phone
adb push test_chunk.json /sdcard/graphrag/input/chunks.json

# Clear previous output
adb shell rm -f /sdcard/graphrag/output/results.json

# Launch app (will auto-process)
adb shell am start -n com.graphrag.processor/.MainActivity

# Monitor
adb logcat -s GraphRAGProcessor:I

# Wait for completion, then pull results
adb pull /sdcard/graphrag/output/results.json
Get-Content results.json
```

**Expected Entities:**
- John Smith (PERSON)
- Acme Corporation (ORGANIZATION)
- New York City (LOCATION)
- Venture Capital Partners (ORGANIZATION)
- $50 million (BUDGET_ITEM or METRIC)

**Expected Relationships:**
- John Smith → CEO_OF → Acme Corporation
- Acme Corporation → LOCATED_IN → New York City
- Venture Capital Partners → FUNDS → Acme Corporation

## Performance Tuning

### Battery Settings
1. **Settings** → **Battery** → **Background usage limits**
2. Add GraphRAG Processor to "Never sleeping" apps
3. Disable battery optimization for the app

### Thermal Management
- Keep phone on cool surface during processing
- Use USB connection (not wireless charging) to reduce heat
- Consider small fan for multi-hour processing sessions

### Memory Optimization
```powershell
# Close all background apps before processing
adb shell am kill-all

# Check available memory
adb shell cat /proc/meminfo | Select-String "MemAvailable"
# Should show >4GB available
```

## Troubleshooting

### Model Not Found
```powershell
# Check file exists
adb shell ls -la /data/local/tmp/*.litertlm

# Check permissions
adb shell stat /data/local/tmp/gemma-3n-E4B-it-int4.litertlm
```

### GPU Initialization Failed
```powershell
# Check OpenCL support
adb shell ls /system/vendor/lib64/libOpenCL*

# Check GPU status
adb shell cat /sys/class/kgsl/kgsl-3d0/gpubusy
```

### Out of Memory
```powershell
# Check memory
adb shell dumpsys meminfo com.graphrag.processor

# Force garbage collection
adb shell am gc com.graphrag.processor

# Kill and restart
adb shell am force-stop com.graphrag.processor
adb shell am start -n com.graphrag.processor/.MainActivity
```

### App Crashes (Native)
```powershell
# Check tombstones
adb shell ls -la /data/tombstones/

# Get crash log
adb shell cat /data/tombstones/tombstone_00

# Usually indicates:
# - Problematic chunk content (dense tables)
# - Memory pressure
# - Thermal throttling
```

## Phone Specifications Template

Save your device specs for reference:

```json
{
  "device": {
    "manufacturer": "Samsung",
    "model": "Galaxy S25 Ultra",
    "codename": "SM-S938U",
    "serial": "R5CXC213RHA"
  },
  "soc": {
    "name": "Snapdragon 8 Elite",
    "manufacturer": "Qualcomm",
    "process": "3nm TSMC"
  },
  "gpu": {
    "name": "Adreno 830",
    "openclVersion": "3.0",
    "vramMb": 4096
  },
  "memory": {
    "ramGb": 12,
    "storageGb": 256
  },
  "android": {
    "version": "15",
    "apiLevel": 35,
    "securityPatch": "2025-10-01"
  },
  "performance": {
    "modelLoadTimeSec": 0.65,
    "prefillTokSec": 1876,
    "decodeTokSec": 45,
    "perChunkTimeSec": 40
  }
}
```
