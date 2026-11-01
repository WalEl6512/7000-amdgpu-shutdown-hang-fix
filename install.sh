#!/bin/bash
# Install amdgpu-power-fix. Usage: sudo ./install.sh
# Safe to re-run: it updates the hook and resets the config to the defaults
# (an existing, different config is backed up to /etc/amdgpu-power-fix.conf.bak).
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0" >&2; exit 1; }
here=$(cd "$(dirname "$0")" && pwd)

HOOK=/usr/lib/systemd/system-shutdown/amdgpu-power-fix
CONF=/etc/amdgpu-power-fix.conf
OLD_SLEEP_HOOK=/usr/lib/systemd/system-sleep/amdgpu-power-fix   # from an early version, not needed

if ! ls -d /sys/bus/pci/drivers/amdgpu/0000:* >/dev/null 2>&1; then
    echo "Warning: no GPU is currently bound to amdgpu; the hook will do nothing until one is." >&2
fi

install -Dm755 "$here/src/amdgpu-power-fix.shutdown" "$HOOK"

if [ -e "$CONF" ] && ! cmp -s "$here/src/amdgpu-power-fix.conf" "$CONF"; then
    cp -a "$CONF" "$CONF.bak"
    echo "Existing config backed up to $CONF.bak"
fi
install -Dm644 "$here/src/amdgpu-power-fix.conf" "$CONF"

[ -e "$OLD_SLEEP_HOOK" ] && rm -f "$OLD_SLEEP_HOOK" && echo "Removed old sleep hook $OLD_SLEEP_HOOK"

command -v restorecon >/dev/null && restorecon -F "$HOOK" "$CONF" || true

echo "Installed:"
echo "  $HOOK"
echo "  $CONF"
for d in /sys/bus/pci/drivers/amdgpu/0000:*; do
    [ -e "$d/power_dpm_force_performance_level" ] && echo "  will act on GPU ${d##*/}"
done
echo "No reboot needed; it takes effect on the next power-off."
