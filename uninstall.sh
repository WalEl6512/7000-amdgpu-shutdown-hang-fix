#!/bin/bash
# Remove amdgpu-power-fix. Usage: sudo ./uninstall.sh
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0" >&2; exit 1; }
rm -fv /usr/lib/systemd/system-shutdown/amdgpu-power-fix \
       /usr/lib/systemd/system-sleep/amdgpu-power-fix \
       /etc/amdgpu-power-fix.conf /etc/amdgpu-power-fix.conf.bak
