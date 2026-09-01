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

## Steps

1. **Xcode Command Line Tools**
   ```sh
   xcode-select --install
   ```
   Finish the dialog, then verify: `xcode-select -p`.

2. **Clone this repo**
   ```sh
   git clone https://github.com/olitreadwell/laptop ~/laptop
   ```

3. **Preview the plan**
   ```sh
   bash ~/laptop/bootstrap.sh --dry-run
   ```
   Confirm the step order looks right for this machine.

4. **Run the setup**
   ```sh
   bash ~/laptop/bootstrap.sh --yes 2>&1 | tee ~/laptop.log
   ```
   `--yes` is hands-off: interactive steps (1Password sign-in, gh/claude/
   codex auth) are skipped with a warning, not failed. Rosetta 2 installs
   itself on Apple Silicon (step 15). If a step fails, fix and resume:
   ```sh
   bash ~/laptop/bootstrap.sh --from <step-name>
   ```

5. **Auth batch** — do this before anything else; codex needs it to help
   with the rest of setup.
   ```sh
   # 1Password: open the app, sign in, then:
   op signin
   # gh, claude, codex — runs each auth interactively (browser opens):
   bash ~/laptop/core/steps/80-auth.sh
   # verify codex is ready to help:
   codex login status
   ```

6. **Verify**
   ```sh
   bash ~/laptop/core/steps/90-verify.sh
   ```

7. **Start the improvement loop** (optional, once the machine is daily-driver)
   ```sh
   bash ~/laptop/loop/loop.sh --daemon
   ```

## If something breaks

- Read `~/laptop.log` — every step logs start/end.
- Re-run with `--from <step>`; steps are idempotent, so nothing re-does
  work already done.
- Never delete data to "fix" a step — back up first.
