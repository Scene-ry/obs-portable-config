import os
import re
from pathlib import Path

# Patterns to search for
PATTERNS = {
    "Stream Key": r"(stream[_-]?key\s*=\s*.+)",
    "RTMP URL with Credentials": r"(rtmp://[^ \n]+)",
    "SRT URL with Passphrase": r"(srt://[^ \n]+)",
    "Password Field": r"(password\s*=\s*.+)",
    "Token / OAuth": r"(token\s*=\s*.+)",
    "WebSocket Password": r"(server_password\s*=\s*.+|ws_password\s*=\s*.+)",
    "Cookies": r"(cookie\s*=\s*.+)",
    "IP Address": r"(\b\d{1,3}(?:\.\d{1,3}){3}\b)",
    "Local File Paths": r"([A-Za-z]:\\\\[^ \n]+|/home/[^ \n]+)"
}

def scan_file(filepath):
    findings = []
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            for label, pattern in PATTERNS.items():
                matches = re.findall(pattern, content, flags=re.IGNORECASE)
                if matches:
                    findings.append((label, matches))
    except Exception as e:
        print(f"Could not read {filepath}: {e}")
    return findings

def scan_obs_config(base_path=None):
    if base_path is None:
        # Default OBS config path for Windows/Linux/macOS
        base_path = Path.home() / "AppData/Roaming/obs-studio"
        if not base_path.exists():
            base_path = Path.home() / ".config/obs-studio"

    print(f"Scanning OBS config at: {base_path}\n")

    for root, _, files in os.walk(base_path):
        for file in files:
            if file.endswith((".ini", ".json", ".txt")):
                full_path = Path(root) / file
                findings = scan_file(full_path)
                if findings:
                    print(f"⚠️ Sensitive data found in: {full_path}")
                    for label, matches in findings:
                        print(f"  - {label}:")
                        for m in matches:
                            print(f"      → {m[:80]}{'...' if len(m) > 80 else ''}")
                    print()

if __name__ == "__main__":
    scan_obs_config()
