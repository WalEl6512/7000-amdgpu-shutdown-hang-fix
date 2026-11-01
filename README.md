# amdgpu-power-fix
## Disclaimer!!!
### This solution is entirely AI generated. After months of trying my patience to fix this on my own faded.

Fixes the **power-off hang on AMD Radeon RX 7900 XT/XTX (Navi 31)** under Linux.

## The problem

After GPU-heavy use (games, benchmarks), shutting down stops the OS, but the PC never
cuts power: the fans keep spinning and you have to switch it off at the PSU.
A shutdown works normally if the GPU wasn't used heavily, or straight after a reboot.

The driver's own power-off path hangs when the GPU is still in the state that heavy use
leaves it in. A reboot clears that state with a hardware reset, which is why
reboot → shutdown works.

## The fix

A small [systemd-shutdown hook](https://www.freedesktop.org/software/systemd/man/latest/systemd-shutdown.html)
runs just before the kernel powers off (on `poweroff`/`halt` only; reboots are left alone).
It puts the GPU into the state a reboot leaves it in:

1. Forces the lowest DPM clocks and waits for the GPU to go idle.
2. Unbinds the GPU's HDMI/DP audio function and the GPU itself from their drivers.
3. Bus-resets the GPU.

An earlier version without the bus reset (step 3) did **not** fix the hang.

## Install

```sh
git clone <this repo> && cd amdgpu-power-fix
sudo ./install.sh
```

No reboot needed. It takes effect on the next power-off.

## Uninstall

```sh
sudo ./uninstall.sh
```

## Configuration

`/etc/amdgpu-power-fix.conf` has an on/off switch for each step
(`QUIESCE_ON_POWEROFF`, `UNBIND_ON_POWEROFF`, `RESET_ON_POWEROFF`) and `VERBOSE`.
The defaults are the combination that works.

## Diagnostics

If a shutdown still hangs, run `sudo tools/diag-boot.sh on`, reboot, and watch the
screen while shutting down. The hook prints each step (`amdgpu-power-fix: ...`), and the
kernel prints one line per device it shuts down, so the last line shows where it stops.
Run `sudo tools/diag-boot.sh off` afterwards.

## Tested on

- Fedora 44 KDE, kernel 7.2.13-200.fc44, linux-firmware 20261019
- RX 7900 XT, Intel i9-10900K, ASRock B460M Pro4

## Not covered

Sleep/suspend problems on the same card (deep/S3 hangs; s2idle runs the GPU fans at
full speed) are a separate issue and are not fixed here.
