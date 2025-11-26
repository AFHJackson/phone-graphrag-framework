#!/usr/bin/env python3
"""
Monitor phone GraphRAG processing via ADB.

Usage:
    python monitor_phone.py
    python monitor_phone.py --interval 10
"""

import subprocess
import json
import time
import argparse
from datetime import datetime


def run_adb(command: str) -> str:
    """Run an ADB command and return output."""
    try:
        result = subprocess.run(
            ['adb'] + command.split(),
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        return ""
    except FileNotFoundError:
        print("Error: ADB not found. Make sure Android SDK is installed.")
        exit(1)


def check_device_connected() -> bool:
    """Check if a device is connected via ADB."""
    output = run_adb("devices")
    lines = output.split('\n')
    for line in lines[1:]:  # Skip header
        if '\tdevice' in line:
            return True
    return False


def get_progress() -> dict:
    """Get current processing progress from phone."""
    output = run_adb("shell cat /sdcard/graphrag/progress/checkpoint.json")
    if output and not output.startswith('cat:'):
        try:
            return json.loads(output)
        except json.JSONDecodeError:
            pass
    return None


def get_last_logs(lines: int = 20) -> list:
    """Get recent GraphRAG logs."""
    output = run_adb(f"logcat -d -t {lines} -s GraphRAGProcessor:I")
    return output.split('\n') if output else []


def is_app_running() -> bool:
    """Check if GraphRAG processor app is running."""
    output = run_adb("shell pidof com.graphrag.processor")
    return bool(output and output.strip())


def format_time(seconds: int) -> str:
    """Format seconds into human-readable time."""
    if seconds < 60:
        return f"{seconds}s"
    elif seconds < 3600:
        return f"{seconds // 60}m {seconds % 60}s"
    else:
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        return f"{hours}h {minutes}m"


def monitor_loop(interval: int = 5):
    """Main monitoring loop."""
    print("Phone GraphRAG Monitor")
    print("=" * 50)
    
    if not check_device_connected():
        print("❌ No device connected. Check USB connection.")
        return
    
    print("✓ Device connected")
    
    start_time = time.time()
    last_chunk = 0
    
    try:
        while True:
            # Clear screen (optional)
            print("\033[H\033[J", end="")  # ANSI escape to clear
            
            print(f"Phone GraphRAG Monitor - {datetime.now().strftime('%H:%M:%S')}")
            print("=" * 50)
            
            # Check app status
            if is_app_running():
                print("📱 App Status: Running")
            else:
                print("📱 App Status: Not running")
            
            # Get progress
            progress = get_progress()
            if progress:
                completed = progress.get('completed', 0)
                total = progress.get('total', 0)
                percent = (completed / total * 100) if total > 0 else 0
                
                print(f"\n📊 Progress: {completed}/{total} chunks ({percent:.1f}%)")
                
                # Progress bar
                bar_width = 40
                filled = int(bar_width * completed / total) if total > 0 else 0
                bar = "█" * filled + "░" * (bar_width - filled)
                print(f"[{bar}]")
                
                # Estimate time remaining
                elapsed = time.time() - start_time
                if completed > last_chunk:
                    chunks_done_this_session = completed - last_chunk
                    time_per_chunk = elapsed / chunks_done_this_session if chunks_done_this_session > 0 else 45
                    remaining = (total - completed) * time_per_chunk
                    print(f"\n⏱️  Estimated time remaining: {format_time(int(remaining))}")
                
                last_chunk = completed
                
                if completed >= total and total > 0:
                    print("\n✅ Processing complete!")
                    break
            else:
                print("\n⏳ Waiting for processing to start...")
            
            # Show recent logs
            print("\n📝 Recent logs:")
            logs = get_last_logs(5)
            for log in logs[-5:]:
                if log.strip():
                    # Truncate long lines
                    print(f"   {log[:80]}..." if len(log) > 80 else f"   {log}")
            
            print(f"\n(Refreshing every {interval}s, Ctrl+C to stop)")
            time.sleep(interval)
            
    except KeyboardInterrupt:
        print("\n\nMonitoring stopped.")


def main():
    parser = argparse.ArgumentParser(description='Monitor phone GraphRAG processing')
    parser.add_argument('--interval', '-i', type=int, default=5, help='Refresh interval in seconds')
    parser.add_argument('--once', action='store_true', help='Run once and exit')
    
    args = parser.parse_args()
    
    if args.once:
        progress = get_progress()
        if progress:
            print(json.dumps(progress, indent=2))
        else:
            print("No progress data available")
    else:
        monitor_loop(args.interval)


if __name__ == '__main__':
    main()
