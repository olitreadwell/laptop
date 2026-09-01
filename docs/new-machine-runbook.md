# New Machine Runbook — MacBook Pro M1 2021 16"

## Before you start

- Have 1Password ready (sign-in credentials, or unlock on phone).
- Have GitHub access (gh auth will open a browser).
- Plug in power; this takes a while.

## Pre-wipe checklist (used machine)

If the M1 is used, do this before erasing:

- [ ] **Activation Lock off** — Settings → Apple Account → Find My → off (needs the seller's Apple ID password).
- [ ] **Seller signs out** of iCloud, iMessage, and App Store (Settings → Apple Account → Sign Out).
- [ ] **FileVault password** known (or disable FileVault before erase).
- [ ] **Firmware password** off or known — otherwise the erase may be blocked.
- [ ] **Battery health check** — System Settings → Battery → Battery Health, or `system_profiler SPPowerDataType`.
- [ ] **Already factory-reset?** (setup screen shows, no Activation Lock) → skip the erase step.

Then erase: shut down → hold power button → Options → Disk Utility → erase the internal disk → Reinstall macOS.

## Fastest start (one command)

After Wi-Fi + account setup, run this at first login — it installs Xcode
CLT, clones this repo, and runs the hands-off bootstrap. A LaunchAgent
resumes automatically after a reboot mid-setup, and disables itself when
done:

```sh
curl -fsSL https://raw.githubusercontent.com/olitreadwell/laptop/main/bootstrap-first-boot.sh | bash
```

Watch progress: `tail -f ~/laptop-first-boot.log`. Then do the auth batch
(step 7 below).

## Steps

1. **Connect to Wi-Fi** — needed before anything else. The setup assistant
   asks on first boot; or from a terminal:
   ```sh
   networksetup -setairportnetwork en0 "SSID" "password"
   ```
   Keep the SSID + password in a 1Password item ("Home Wi-Fi", fields
   `SSID` + `password`) so it survives the wipe and is easy to re-enter.

2. **Update macOS** — a used machine may ship an old version; update before
   installing tools.
   ```sh
   softwareupdate -i -a --restart
   ```
   Or System Settings → General → Software Update. Reboot when done.

3. **Xcode Command Line Tools**
   ```sh
   xcode-select --install
   ```
   Finish the dialog, then verify: `xcode-select -p`.

4. **Clone this repo**
   ```sh
   git clone https://github.com/olitreadwell/laptop ~/laptop
   ```

5. **Preview the plan**
   ```sh
   bash ~/laptop/bootstrap.sh --dry-run
   ```
   Confirm the step order looks right for this machine.

6. **Run the setup**
   ```sh
   bash ~/laptop/bootstrap.sh --yes 2>&1 | tee ~/laptop.log
   ```
   `--yes` is hands-off: interactive steps (1Password sign-in, gh/claude/
   codex auth) are skipped with a warning, not failed. Without `--yes` it
   shows a colored plan and asks to confirm before running. Preflight
   checks network, disk space, and power first. Output is colored on the
   terminal, plain in `~/laptop.log`. Rosetta 2 installs itself on Apple
   Silicon (step 15). Step 45 clones your personal repos from `repos.txt`
   into `~/code` (parallel, partial clones). If a step fails, fix and
   resume:
   ```sh
   bash ~/laptop/bootstrap.sh --from <step-name>
   ```

7. **Auth batch** — do this before anything else; codex needs it to help
   with the rest of setup.
   ```sh
   # 1Password: open the app, sign in, then:
   op signin
   # gh, claude, codex auth + Ollama Cloud Pro keys 1+2 from 1Password
   # (written to ~/.config/op/secrets.env so codex works immediately):
   bash ~/laptop/core/steps/80-auth.sh
   # verify codex is ready to help:
   codex login status
   ```

8. **Verify**
   ```sh
   bash ~/laptop/core/steps/90-verify.sh
   ```

9. **Versions** — brew bundle installs latest stable formulae; runtimes are
   pinned by `~/.config/mise/config.toml` (node LTS etc.) so they play
   nicely together. After setup, catch stragglers:
   ```sh
   brew upgrade
   mise upgrade
   ```

10. **Start the improvement loop** (optional, once the machine is daily-driver)
   ```sh
   bash ~/laptop/loop/loop.sh --daemon
   ```

## If something breaks

- Read `~/laptop.log` — every step logs start/end.
- Re-run with `--from <step>`; steps are idempotent, so nothing re-does
  work already done.
- Never delete data to "fix" a step — back up first.
