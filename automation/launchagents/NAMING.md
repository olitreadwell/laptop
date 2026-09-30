# LaunchAgent naming

One scheme for every Oli-owned launchd job:

    com.oli.<area>.<job>

- `com.oli` — one owner prefix. `com.olitreadwell.*`, `nz.olitreadwell.*`
  and `nz.kiwilayoffs.*` are retired spellings of the same owner.
- `<area>` — the system the job belongs to: `meta`, `career`, `oss-contrib`,
  `nz-data-lab`, `open-data`, `awesome-lists`, `kiwi-layoffs`, `kiwi-djs`,
  `wlg-house-hunt`, `remote-jobs`, `scratchpad`, `dashboards`, `system`.
- `<job>` — what the job does, kebab-case, 1 to 3 words. A job that only
  runs a report says so; a long-running server says `server`; a recurring
  sweep says `sweep` or `check`.

The `<job>` segment matches the `oli run-automation <name>` argument or the
script it runs, so the label is greppable back to its source.

Third-party agents keep their vendor labels (`com.federicoterzi.espanso`,
`com.google.keystone.*`, `homebrew.mxcl.*`). Never rename those: the vendor
reinstalls them under the original label.

## Where the files live

- `~/laptop/automation/launchagents/` is the installer's source of truth.
  `core/steps/85-automation-macos.sh` copies every `*.plist` from here into
  `~/Library/LaunchAgents` and loads it, skipping any destination that is a
  symlink.
- `~/dotfiles/Library/LaunchAgents/` owns three of them
  (`com.oli.system.dotfiles-auto-backup`, `com.oli.system.downloads-cleanup`,
  `com.oli.system.ollama-env-defaults`) and the dotfiles install links them
  into `~/Library/LaunchAgents`. The copies in this directory are a fallback
  that the installer skips while the symlink exists.
- `~/oli/meta/automations/launchd/` holds the `com.oli.meta.*` templates with
  `REPLACE_WITH_HOME` placeholders. Each template filename is its label.
- Per-project jobs live with the project: `~/code/awesome-kiwi-tech`,
  `~/code/awesome-olitreadwell`, `~/code/open-data/awesome-open-nz-data`,
  `~/code/dashboards`, `~/code/wlg-house-hunt`.
- `com.oli.retired` files in `~/Library/LaunchAgents` end in `.done` or
  `.disabled` and are never loaded. Leave the suffix on.

## Live renames

The rename map is `rename-map.tsv` (old label, tab, new label). Applying it
to a running machine means: `launchctl bootout` the old label, rename the
file, rewrite the `Label` key, `launchctl bootstrap` the new one, and
`launchctl disable` the new label if the old one was disabled. A scripted
reverse of the last live run is written to `rollback-live-rename.sh`.

Backups of earlier installs live in `~/.launchagents-archive/plist-backups`;
the installer no longer accumulates `.bak.<epoch>` files in
`~/Library/LaunchAgents`.

## Rename map

### meta — `oli` CLI automations

    com.oli.automation-health          com.oli.meta.automation-health-check
    com.oli.check-staleness            com.oli.meta.staleness-check
    com.oli.checkin                    com.oli.meta.evening-checkin
    com.oli.daily-orchestrator         com.oli.meta.daily-orchestrator
    com.oli.dashboard                  com.oli.meta.dashboard-build
    com.oli.dashboard-live             com.oli.meta.dashboard-server
    com.oli.dashboard-deploy           com.oli.meta.dashboard-deploy
    com.oli.events-notify              com.oli.meta.weekly-events-digest
    com.oli.flight-prices              com.oli.meta.flight-price-watch
    com.oli.git-hygiene                com.oli.meta.git-hygiene-sweep
    com.oli.habit-streak               com.oli.meta.habit-streak-report
    com.oli.minicam-time               com.oli.meta.minicam-clock-sync
    com.oli.morning-intent             com.oli.meta.morning-intent
    com.oli.plane-digest               com.oli.meta.plane-digest
    com.oli.relationship-checkin       com.oli.meta.relationship-reminder
    com.oli.repo-digest                com.oli.meta.repo-digest
    com.oli.stale-drafts               com.oli.meta.stale-draft-sweep
    com.oli.tomorrow-prep              com.oli.meta.tomorrow-prep
    com.oli.voice-backlog              com.oli.meta.voice-backlog-queue
    com.oli.weekly-reflection          com.oli.meta.weekly-reflection
    com.oli.weekly-review              com.oli.meta.weekly-review
    com.oli.wlg-quiz-sweep             com.oli.meta.wlg-quiz-sweep

### career — `~/.career-reporting`

    com.oli.career-nz-role-sweep             com.oli.career.nz-role-sweep
    com.olitreadwell.career-dashboard-server com.oli.career.dashboard-server
    com.olitreadwell.career-digest           com.oli.career.daily-digest
    com.olitreadwell.career-error-watch      com.oli.career.error-watch
    com.olitreadwell.career-floor-nudge      com.oli.career.floor-nudge
    com.olitreadwell.career-followup-check   com.oli.career.followup-check
    com.olitreadwell.career-health-check     com.oli.career.health-check
    com.olitreadwell.career-life-nudge       com.oli.career.life-nudge
    com.olitreadwell.career-monthly-review   com.oli.career.monthly-review
    com.olitreadwell.career-plane-sync       com.oli.career.plane-sync
    com.olitreadwell.career-stale-sweep      com.oli.career.stale-sweep
    com.olitreadwell.career-weekly-review    com.oli.career.weekly-review

### oss-contrib — `~/code/oss-contrib-pipeline`

    com.olitreadwell.oss-contrib-loop         com.oli.oss-contrib.main-loop
    com.olitreadwell.oss-contrib-loop-trivial com.oli.oss-contrib.trivial-loop
    com.olitreadwell.oss-contrib-maintenance  com.oli.oss-contrib.fork-maintenance

### data — `~/code/open-data`, `~/code/nz-data-lab`

    com.olitreadwell.nz-microsite-loop            com.oli.nz-data-lab.microsite-loop
    com.olitreadwell.uk-data-lab-grow             com.oli.nz-data-lab.uk-lab-grow
    com.olitreadwell.usa-data-lab-grow            com.oli.nz-data-lab.usa-lab-grow
    com.olitreadwell.awesome-open-uk-data-grow    com.oli.open-data.awesome-uk-grow
    com.olitreadwell.awesome-open-usa-data-grow   com.oli.open-data.awesome-usa-grow
    nz.olitreadwell.awesome-open-nz-data.links    com.oli.open-data.awesome-nz-links
    nz.olitreadwell.awesome-kiwi-tech.links       com.oli.awesome-lists.kiwi-tech-links
    nz.olitreadwell.awesome-olitreadwell.links    com.oli.awesome-lists.olitreadwell-links
    nz.kiwilayoffs.sweep                          com.oli.kiwi-layoffs.tracker-sweep

### project loops and servers

    com.olitreadwell.kiwi-djs-loop        com.oli.kiwi-djs.nightly-loop
    com.olitreadwell.wlg-house-hunt       com.oli.wlg-house-hunt.listing-finder
    com.olitreadwell.remote-sweep         com.oli.remote-jobs.sweep
    com.olitreadwell.scratchpad-api-loop  com.oli.scratchpad.api-loop
    com.olitreadwell.dashboards           com.oli.dashboards.local-server

### system

    com.olitreadwell.dotfiles-backup      com.oli.system.dotfiles-auto-backup
    com.olitreadwell.downloads-cleanup    com.oli.system.downloads-cleanup
    com.olitreadwell.ollama-env           com.oli.system.ollama-env-defaults
    com.olitreadwell.swap-alarm           com.oli.system.swap-alarm

### retired — do not reload

    com.olitreadwell.gmail-mcp            (replaced by ~/.gmail-mcp MCP)
    io.gmail.scheduler                    (same)
    com.olitreadwell.laptop-bootstrap     (one-shot first boot)
    com.olitreadwell.oli-landing-pages-loop
