#!/usr/bin/env bash
# Mobile (Flutter/Android/iOS): emulador e simulador ligados consomem muita RAM/CPU.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/_common.sh
. "$here/_common.sh"
root="${1:-.}"
has_file "$root" 'pubspec.yaml' 'AndroidManifest.xml' '*.xcodeproj' 'Podfile' || exit 0

if command -v adb >/dev/null 2>&1; then
  adb devices 2>/dev/null | awk '$1 ~ /^emulator-/ && $2=="device" {print $1}' | while IFS= read -r s; do
    row mobile "$s" "emulador Android ligado ($s)" "adb -s $s emu kill"
  done
elif [[ -n "$(pids 'qemu-system')" ]]; then
  row mobile android-emulator "emulador Android ligado (pid $(pids 'qemu-system'); sem adb no PATH)" "pkill -f qemu-system"
fi

# só chama o simctl se houver Xcode (sem ele, o xcrun pode abrir o instalador)
if [[ "$(xcode-select -p 2>/dev/null)" == *Xcode*.app* ]]; then
  xcrun simctl list devices booted 2>/dev/null |
    sed -nE 's/^ +(.+) \(([0-9A-F-]{36})\) \(Booted\).*/\2\t\1/p' | while IFS=$'\t' read -r udid name; do
    row mobile "$udid" "simulador iOS ligado ($name)" "xcrun simctl shutdown $udid"
  done
fi
exit 0
