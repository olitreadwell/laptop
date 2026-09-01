# New Machine Runbook — MacBook Pro M1 2021 16"

## Before you start

- Have 1Password ready (sign-in credentials, or unlock on phone).
- Have GitHub access (gh auth will open a browser).
- Plug in power; this takes a while.

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
   bash ~/laptop/bootstrap.sh 2>&1 | tee ~/laptop.log
   ```
   Interactive moments: 1Password sign-in (step 20), gh/claude auth
   (step 80). Rosetta 2 installs itself on Apple Silicon (step 15). If a
   step fails, fix and resume:
   ```sh
   bash ~/laptop/bootstrap.sh --from <step-name>
   ```

5. **Verify**
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
