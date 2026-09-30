#!/usr/bin/env bash
# Reverse the live launchd rename: unload new label, restore old file+label.
set -uo pipefail
DIR="$HOME/Library/LaunchAgents"; DOMAIN="gui/$(id -u)"
launchctl bootout "$DOMAIN/com.oli.meta.automation-health-check" 2>/dev/null
mv "$DIR/com.oli.meta.automation-health-check.plist" "$DIR/com.oli.automation-health.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.automation-health' "$DIR/com.oli.automation-health.plist"
launchctl disable "$DOMAIN/com.oli.automation-health" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.staleness-check" 2>/dev/null
mv "$DIR/com.oli.meta.staleness-check.plist" "$DIR/com.oli.check-staleness.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.check-staleness' "$DIR/com.oli.check-staleness.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.check-staleness.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.evening-checkin" 2>/dev/null
mv "$DIR/com.oli.meta.evening-checkin.plist" "$DIR/com.oli.checkin.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.checkin' "$DIR/com.oli.checkin.plist"
launchctl disable "$DOMAIN/com.oli.checkin" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.daily-orchestrator" 2>/dev/null
mv "$DIR/com.oli.meta.daily-orchestrator.plist" "$DIR/com.oli.daily-orchestrator.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.daily-orchestrator' "$DIR/com.oli.daily-orchestrator.plist"
launchctl disable "$DOMAIN/com.oli.daily-orchestrator" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.dashboard-build" 2>/dev/null
mv "$DIR/com.oli.meta.dashboard-build.plist" "$DIR/com.oli.dashboard.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.dashboard' "$DIR/com.oli.dashboard.plist"
launchctl disable "$DOMAIN/com.oli.dashboard" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.dashboard-server" 2>/dev/null
mv "$DIR/com.oli.meta.dashboard-server.plist" "$DIR/com.oli.dashboard-live.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.dashboard-live' "$DIR/com.oli.dashboard-live.plist"
launchctl disable "$DOMAIN/com.oli.dashboard-live" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.dashboard-deploy" 2>/dev/null
mv "$DIR/com.oli.meta.dashboard-deploy.plist" "$DIR/com.oli.dashboard-deploy.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.dashboard-deploy' "$DIR/com.oli.dashboard-deploy.plist"
launchctl disable "$DOMAIN/com.oli.dashboard-deploy" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.weekly-events-digest" 2>/dev/null
mv "$DIR/com.oli.meta.weekly-events-digest.plist" "$DIR/com.oli.events-notify.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.events-notify' "$DIR/com.oli.events-notify.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.events-notify.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.flight-price-watch" 2>/dev/null
mv "$DIR/com.oli.meta.flight-price-watch.plist" "$DIR/com.oli.flight-prices.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.flight-prices' "$DIR/com.oli.flight-prices.plist"
launchctl disable "$DOMAIN/com.oli.flight-prices" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.git-hygiene-sweep" 2>/dev/null
mv "$DIR/com.oli.meta.git-hygiene-sweep.plist" "$DIR/com.oli.git-hygiene.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.git-hygiene' "$DIR/com.oli.git-hygiene.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.git-hygiene.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.habit-streak-report" 2>/dev/null
mv "$DIR/com.oli.meta.habit-streak-report.plist" "$DIR/com.oli.habit-streak.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.habit-streak' "$DIR/com.oli.habit-streak.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.habit-streak.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.minicam-clock-sync" 2>/dev/null
mv "$DIR/com.oli.meta.minicam-clock-sync.plist" "$DIR/com.oli.minicam-time.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.minicam-time' "$DIR/com.oli.minicam-time.plist"
launchctl disable "$DOMAIN/com.oli.minicam-time" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.morning-intent" 2>/dev/null
mv "$DIR/com.oli.meta.morning-intent.plist" "$DIR/com.oli.morning-intent.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.morning-intent' "$DIR/com.oli.morning-intent.plist"
launchctl disable "$DOMAIN/com.oli.morning-intent" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.plane-digest" 2>/dev/null
mv "$DIR/com.oli.meta.plane-digest.plist" "$DIR/com.oli.plane-digest.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.plane-digest' "$DIR/com.oli.plane-digest.plist"
launchctl disable "$DOMAIN/com.oli.plane-digest" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.relationship-reminder" 2>/dev/null
mv "$DIR/com.oli.meta.relationship-reminder.plist" "$DIR/com.oli.relationship-checkin.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.relationship-checkin' "$DIR/com.oli.relationship-checkin.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.relationship-checkin.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.repo-digest" 2>/dev/null
mv "$DIR/com.oli.meta.repo-digest.plist" "$DIR/com.oli.repo-digest.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.repo-digest' "$DIR/com.oli.repo-digest.plist"
launchctl disable "$DOMAIN/com.oli.repo-digest" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.stale-draft-sweep" 2>/dev/null
mv "$DIR/com.oli.meta.stale-draft-sweep.plist" "$DIR/com.oli.stale-drafts.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.stale-drafts' "$DIR/com.oli.stale-drafts.plist"
launchctl disable "$DOMAIN/com.oli.stale-drafts" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.tomorrow-prep" 2>/dev/null
mv "$DIR/com.oli.meta.tomorrow-prep.plist" "$DIR/com.oli.tomorrow-prep.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.tomorrow-prep' "$DIR/com.oli.tomorrow-prep.plist"
launchctl disable "$DOMAIN/com.oli.tomorrow-prep" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.voice-backlog-queue" 2>/dev/null
mv "$DIR/com.oli.meta.voice-backlog-queue.plist" "$DIR/com.oli.voice-backlog.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.voice-backlog' "$DIR/com.oli.voice-backlog.plist"
launchctl disable "$DOMAIN/com.oli.voice-backlog" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.weekly-reflection" 2>/dev/null
mv "$DIR/com.oli.meta.weekly-reflection.plist" "$DIR/com.oli.weekly-reflection.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.weekly-reflection' "$DIR/com.oli.weekly-reflection.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.weekly-reflection.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.weekly-review" 2>/dev/null
mv "$DIR/com.oli.meta.weekly-review.plist" "$DIR/com.oli.weekly-review.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.weekly-review' "$DIR/com.oli.weekly-review.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.weekly-review.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.meta.wlg-quiz-sweep" 2>/dev/null
mv "$DIR/com.oli.meta.wlg-quiz-sweep.plist" "$DIR/com.oli.wlg-quiz-sweep.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.wlg-quiz-sweep' "$DIR/com.oli.wlg-quiz-sweep.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.wlg-quiz-sweep.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.nz-role-sweep" 2>/dev/null
mv "$DIR/com.oli.career.nz-role-sweep.plist" "$DIR/com.oli.career-nz-role-sweep.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.oli.career-nz-role-sweep' "$DIR/com.oli.career-nz-role-sweep.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.oli.career-nz-role-sweep.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.dashboard-server" 2>/dev/null
mv "$DIR/com.oli.career.dashboard-server.plist" "$DIR/com.olitreadwell.career-dashboard-server.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-dashboard-server' "$DIR/com.olitreadwell.career-dashboard-server.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-dashboard-server" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.daily-digest" 2>/dev/null
mv "$DIR/com.oli.career.daily-digest.plist" "$DIR/com.olitreadwell.career-digest.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-digest' "$DIR/com.olitreadwell.career-digest.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-digest" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.error-watch" 2>/dev/null
mv "$DIR/com.oli.career.error-watch.plist" "$DIR/com.olitreadwell.career-error-watch.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-error-watch' "$DIR/com.olitreadwell.career-error-watch.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-error-watch" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.floor-nudge" 2>/dev/null
mv "$DIR/com.oli.career.floor-nudge.plist" "$DIR/com.olitreadwell.career-floor-nudge.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-floor-nudge' "$DIR/com.olitreadwell.career-floor-nudge.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-floor-nudge" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.followup-check" 2>/dev/null
mv "$DIR/com.oli.career.followup-check.plist" "$DIR/com.olitreadwell.career-followup-check.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-followup-check' "$DIR/com.olitreadwell.career-followup-check.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-followup-check" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.health-check" 2>/dev/null
mv "$DIR/com.oli.career.health-check.plist" "$DIR/com.olitreadwell.career-health-check.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-health-check' "$DIR/com.olitreadwell.career-health-check.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-health-check" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.life-nudge" 2>/dev/null
mv "$DIR/com.oli.career.life-nudge.plist" "$DIR/com.olitreadwell.career-life-nudge.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-life-nudge' "$DIR/com.olitreadwell.career-life-nudge.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-life-nudge" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.monthly-review" 2>/dev/null
mv "$DIR/com.oli.career.monthly-review.plist" "$DIR/com.olitreadwell.career-monthly-review.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-monthly-review' "$DIR/com.olitreadwell.career-monthly-review.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-monthly-review" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.plane-sync" 2>/dev/null
mv "$DIR/com.oli.career.plane-sync.plist" "$DIR/com.olitreadwell.career-plane-sync.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-plane-sync' "$DIR/com.olitreadwell.career-plane-sync.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-plane-sync" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.stale-sweep" 2>/dev/null
mv "$DIR/com.oli.career.stale-sweep.plist" "$DIR/com.olitreadwell.career-stale-sweep.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-stale-sweep' "$DIR/com.olitreadwell.career-stale-sweep.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-stale-sweep" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.career.weekly-review" 2>/dev/null
mv "$DIR/com.oli.career.weekly-review.plist" "$DIR/com.olitreadwell.career-weekly-review.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.career-weekly-review' "$DIR/com.olitreadwell.career-weekly-review.plist"
launchctl disable "$DOMAIN/com.olitreadwell.career-weekly-review" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.oss-contrib.main-loop" 2>/dev/null
mv "$DIR/com.oli.oss-contrib.main-loop.plist" "$DIR/com.olitreadwell.oss-contrib-loop.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.oss-contrib-loop' "$DIR/com.olitreadwell.oss-contrib-loop.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.oss-contrib-loop.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.oss-contrib.trivial-loop" 2>/dev/null
mv "$DIR/com.oli.oss-contrib.trivial-loop.plist" "$DIR/com.olitreadwell.oss-contrib-loop-trivial.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.oss-contrib-loop-trivial' "$DIR/com.olitreadwell.oss-contrib-loop-trivial.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.oss-contrib-loop-trivial.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.oss-contrib.fork-maintenance" 2>/dev/null
mv "$DIR/com.oli.oss-contrib.fork-maintenance.plist" "$DIR/com.olitreadwell.oss-contrib-maintenance.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.oss-contrib-maintenance' "$DIR/com.olitreadwell.oss-contrib-maintenance.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.oss-contrib-maintenance.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.nz-data-lab.microsite-loop" 2>/dev/null
mv "$DIR/com.oli.nz-data-lab.microsite-loop.plist" "$DIR/com.olitreadwell.nz-microsite-loop.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.nz-microsite-loop' "$DIR/com.olitreadwell.nz-microsite-loop.plist"
launchctl disable "$DOMAIN/com.olitreadwell.nz-microsite-loop" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.nz-data-lab.uk-lab-grow" 2>/dev/null
mv "$DIR/com.oli.nz-data-lab.uk-lab-grow.plist" "$DIR/com.olitreadwell.uk-data-lab-grow.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.uk-data-lab-grow' "$DIR/com.olitreadwell.uk-data-lab-grow.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.uk-data-lab-grow.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.nz-data-lab.usa-lab-grow" 2>/dev/null
mv "$DIR/com.oli.nz-data-lab.usa-lab-grow.plist" "$DIR/com.olitreadwell.usa-data-lab-grow.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.usa-data-lab-grow' "$DIR/com.olitreadwell.usa-data-lab-grow.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.usa-data-lab-grow.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.open-data.awesome-uk-grow" 2>/dev/null
mv "$DIR/com.oli.open-data.awesome-uk-grow.plist" "$DIR/com.olitreadwell.awesome-open-uk-data-grow.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.awesome-open-uk-data-grow' "$DIR/com.olitreadwell.awesome-open-uk-data-grow.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.awesome-open-uk-data-grow.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.open-data.awesome-usa-grow" 2>/dev/null
mv "$DIR/com.oli.open-data.awesome-usa-grow.plist" "$DIR/com.olitreadwell.awesome-open-usa-data-grow.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.awesome-open-usa-data-grow' "$DIR/com.olitreadwell.awesome-open-usa-data-grow.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.awesome-open-usa-data-grow.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.open-data.awesome-nz-links" 2>/dev/null
mv "$DIR/com.oli.open-data.awesome-nz-links.plist" "$DIR/nz.olitreadwell.awesome-open-nz-data.links.plist"
/usr/libexec/PlistBuddy -c 'Set :Label nz.olitreadwell.awesome-open-nz-data.links' "$DIR/nz.olitreadwell.awesome-open-nz-data.links.plist"
launchctl bootstrap "$DOMAIN" "$DIR/nz.olitreadwell.awesome-open-nz-data.links.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.awesome-lists.kiwi-tech-links" 2>/dev/null
mv "$DIR/com.oli.awesome-lists.kiwi-tech-links.plist" "$DIR/nz.olitreadwell.awesome-kiwi-tech.links.plist"
/usr/libexec/PlistBuddy -c 'Set :Label nz.olitreadwell.awesome-kiwi-tech.links' "$DIR/nz.olitreadwell.awesome-kiwi-tech.links.plist"
launchctl bootstrap "$DOMAIN" "$DIR/nz.olitreadwell.awesome-kiwi-tech.links.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.awesome-lists.olitreadwell-links" 2>/dev/null
mv "$DIR/com.oli.awesome-lists.olitreadwell-links.plist" "$DIR/nz.olitreadwell.awesome-olitreadwell.links.plist"
/usr/libexec/PlistBuddy -c 'Set :Label nz.olitreadwell.awesome-olitreadwell.links' "$DIR/nz.olitreadwell.awesome-olitreadwell.links.plist"
launchctl bootstrap "$DOMAIN" "$DIR/nz.olitreadwell.awesome-olitreadwell.links.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.kiwi-layoffs.tracker-sweep" 2>/dev/null
mv "$DIR/com.oli.kiwi-layoffs.tracker-sweep.plist" "$DIR/nz.kiwilayoffs.sweep.plist"
/usr/libexec/PlistBuddy -c 'Set :Label nz.kiwilayoffs.sweep' "$DIR/nz.kiwilayoffs.sweep.plist"
launchctl bootstrap "$DOMAIN" "$DIR/nz.kiwilayoffs.sweep.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.kiwi-djs.nightly-loop" 2>/dev/null
mv "$DIR/com.oli.kiwi-djs.nightly-loop.plist" "$DIR/com.olitreadwell.kiwi-djs-loop.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.kiwi-djs-loop' "$DIR/com.olitreadwell.kiwi-djs-loop.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.kiwi-djs-loop.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.wlg-house-hunt.listing-finder" 2>/dev/null
mv "$DIR/com.oli.wlg-house-hunt.listing-finder.plist" "$DIR/com.olitreadwell.wlg-house-hunt.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.wlg-house-hunt' "$DIR/com.olitreadwell.wlg-house-hunt.plist"
launchctl disable "$DOMAIN/com.olitreadwell.wlg-house-hunt" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.remote-jobs.sweep" 2>/dev/null
mv "$DIR/com.oli.remote-jobs.sweep.plist" "$DIR/com.olitreadwell.remote-sweep.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.remote-sweep' "$DIR/com.olitreadwell.remote-sweep.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.remote-sweep.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.scratchpad.api-loop" 2>/dev/null
mv "$DIR/com.oli.scratchpad.api-loop.plist" "$DIR/com.olitreadwell.scratchpad-api-loop.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.scratchpad-api-loop' "$DIR/com.olitreadwell.scratchpad-api-loop.plist"
launchctl bootstrap "$DOMAIN" "$DIR/com.olitreadwell.scratchpad-api-loop.plist" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.dashboards.local-server" 2>/dev/null
mv "$DIR/com.oli.dashboards.local-server.plist" "$DIR/com.olitreadwell.dashboards.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.dashboards' "$DIR/com.olitreadwell.dashboards.plist"
launchctl disable "$DOMAIN/com.olitreadwell.dashboards" 2>/dev/null
launchctl bootout "$DOMAIN/com.oli.system.swap-alarm" 2>/dev/null
mv "$DIR/com.oli.system.swap-alarm.plist" "$DIR/com.olitreadwell.swap-alarm.plist"
/usr/libexec/PlistBuddy -c 'Set :Label com.olitreadwell.swap-alarm' "$DIR/com.olitreadwell.swap-alarm.plist"
launchctl disable "$DOMAIN/com.olitreadwell.swap-alarm" 2>/dev/null
