# Handoff: bring papaya up to date with durian (2026-11-24)

durian (XPS 9320 laptop) was reconciled with this repo on 2026-11-24. papaya
(desktop) is behind. **Read this before running `chezmoi update` on papaya** —
several changes alter papaya's behaviour, and papaya may have local edits that
should be captured first. Delete this file once papaya is done.

Read it without applying anything:

    git -C ~/.local/share/chezmoi fetch && git -C ~/.local/share/chezmoi show origin/main:HANDOFF-papaya.md

## 0. Before pulling

- `chezmoi status` and `chezmoi diff` on papaya. papaya's last push was
  2026-10-20 ("Pull in local edits..."). Anything edited since then is
  uncommitted and `chezmoi update` would overwrite it. Capture what's worth
  keeping (`chezmoi re-add`, or hand-merge templates) before pulling.
- GPG: Neil's key was extended to **2027-07-07** (old expiry 2026-05-20). If
  papaya's keyring is stale, signing will fail. Refresh first:
  `gpg --auto-key-locate clear,nodefault,wkd --locate-external-keys neil@spladug.net`
- DevPod is gone (see §4). Stop any DevPod workspaces first.

## 1. What changed in the repo (commits 1d82a9d..0dac768)

- **GPG keys**: `gpg/neil.asc` and `gpg/hashicorp.asc` refreshed. The
  gpg-import script now also gives Neil's key **ultimate owner trust**. Without
  it, `chezmoi add --encrypt` fails on a machine that only imported the public
  key; durian had never been able to encrypt.
- **ghostty**: `keybind = ctrl+enter=unbind`.
- **git**: `gh` installed everywhere (moved from work.toml to shell.toml).
  `git/config.tmpl` uses `gh auth git-credential` for github.com/gist.
  Ignore `**/.claude/.cc-writes/`.
- **Tailnets inverted** (§2) and **Chromium launch chain** now chezmoi-managed (§3).
- **start.sh** is one template: Chromium restore-bubble patch for all profiles,
  Personal profile on workspace 0, WattCarbon on workspace 1 (work machines
  only), 1Password, Obsidian, then Slack/Discord/Signal on workspace 9.
  **No Firefox. No Cider** (§5).
- **ssh**: `~/.ssh/config` is now only `pi` + `dragonfruit` (DevPod blocks and
  the `streets.devpod` LocalForward removed). `known_hosts` is the union of both
  machines, minus `[localhost]:2222` (key differs per machine) and keyscan
  comment lines.
- **Apply fixes**:
  - `run_once_after_install-paru` now exits early if paru exists. Its content
    changed in the libalpm16 commit, so it would rerun on papaya, fail on the
    existing clone, and abort the whole apply.
  - Default browser is set with `xdg-mime`, not `xdg-settings`. xdg-settings
    rewrote the chromium.desktop override and moved MimeType into the incognito
    action group.
  - `PYTHON_HISTORY` is set, because the Python 3.13+ REPL ignored startup.py
    and kept recreating `~/.python_history`.
- **heptane**: bare `heptane` is now a **dry run**; `heptane apply` makes
  changes after typing YES. Package groups were updated; there is a new
  `family-archive.toml`.
- **fzf.vim** is a pinned git submodule at
  `home/dot_config/vim/external_pack/spladug/start/fzf.vim` (fe5f1fd), same as
  commentary. It replaces AUR `vim-fzf-git`. If `:Files`/`:Rg` are missing in
  vim after the update, run `git -C ~/.local/share/chezmoi submodule update --init`
  and apply again.
- **durian-only** (behind a hostname check in `.chezmoiignore`): libcamera
  ov01a10 tuning and WirePlumber routing (§6).

## 2. Tailnet layout (papaya needs migrating)

New model, on every machine:
- **Personal tailnet** `personal-tailnet.ts.net`: the rootful system
  `tailscaled.service`, joined with `tailscale up --operator=$USER`.
- **WattCarbon tailnet** `tailXXXX.ts.net`: on **work machines only**
  (chezmoi `.work.email` set), as a userspace user unit
  `tailscale-wattcarbon.service`. It runs a SOCKS5/HTTP proxy on
  `127.0.0.1:1055`, and its CLI is `tswattcarbon`. Only Chromium uses it, via
  `~/.config/chromium-proxy.pac`, which matches `*.tailXXXX.ts.net` only.
  Neil accepted losing CLI/ssh access to the work tailnet.

papaya currently shows up in **both** tailnets, so find out how first:
`tailscale status`, `systemctl --user list-unit-files 'tailscale*'`,
`ss -ltn | grep 1055`. If it has the old durian layout (system = work, plus a
userspace `tailscale-personal.service` and `tspersonal`), migrate in this order:

1. `systemctl --user disable --now tailscale-personal.service`, which frees port 1055.
2. `chezmoi update`. The enable script then starts `tailscale-wattcarbon`.
3. Neil runs `tswattcarbon up` and logs into WattCarbon.
4. Neil runs `sudo tailscale logout && sudo tailscale up --operator=$USER` and
   logs into the personal tailnet. Both logins are interactive.
5. Verify: `tailscale status` shows personal-tailnet; `tswattcarbon ping <portal host>`
   succeeds; port 1055 is listening.
6. Remove the old pieces: the `tailscale-personal` unit, `tspersonal`,
   `~/.local/state/tailscale-personal`, `~/.cache/tailscale-personal`.
7. Each tailnet will end up with a stale `papaya` node and a new `papaya-1`.
   Neil deletes the old one in each admin console and renames.

Never broaden the PAC to `*.ts.net` or 100.64/10, because both tailnets share
them. The unit deliberately has no `tailscaled --cleanup` ExecStopPost, since
that would flush the system daemon's nftables rules and routes.

## 3. Chromium profiles

Chain: `chromium.desktop` override → `~/.local/bin/chromium-tailnet` (adds the
PAC if present) → `~/.local/bin/chromium-profile`. Profile routing now uses
**display names**, looked up in `~/.config/chromium/Local State`, so the same
rules work on any machine:
- Work profile must be named exactly **`WattCarbon`**, personal **`Personal`**
  (one word each).
- Rename with Chromium **closed**: set
  `.profile.info_cache.<dir>.name` in `Local State` (back it up first), or use
  Chromium's UI.
- Rules: `~/.config/chromium-profile-rules`. First match wins, fallback is
  Personal. If a name doesn't resolve, nothing is passed and the link opens in
  the last-used profile. Never pass a guessed `--profile-directory`: Chromium
  silently creates a new empty profile.
- Verify: `xdg-open https://github.com` → WattCarbon, `xdg-open https://youtube.com` → Personal.
- `BROWSER=xdg-open` (environment.d) needs a re-login to take effect.

## 4. DevPod → Claude Code cloud sessions

Neil replaced DevPod with Claude Code cloud sessions. DevPod is not declared
in heptane, so `heptane` will list it for removal; that's intended. papaya's
DevPod-generated ssh blocks are gone from the shared ssh config.

## 5. Cider

Removed from `apps.toml`. The AUR `cider` package is v1, while Neil uses v2,
which is paid. He'll work out how v2 gets installed, so don't reinstall the AUR
package. start.sh no longer launches it.

## 6. Audio (WirePlumber): reconcile deliberately

durian's 4 files are in the repo, but **chezmoi skips them on any host other than durian**:
- `50-hide-unwanted-audio.conf`: disables DisplayLink dock audio and sof_sdw HDMI sinks.
- `51-audio-priorities.conf`: AirPods 2000 > speakers 1000; Insta360 2000 > built-in mics 1000.
- `52-airpods-a2dp-only.conf`: `bluetooth.autoswitch-to-headset-profile = false`.
- `53-insta360-quirks.conf`: soft-mixer for the Insta360 Link's broken UAC mixer.

Every rule matches by device name, so none of them would break papaya. Neil
wants papaya's own audio config compared with these before deciding what to
share. Shareable candidates: the AirPods A2DP-only setting, the bluez priority,
and the Insta360 rules if that camera is plugged into papaya. If they're shared,
change the hostname-gated `.config/wireplumber` ignore rule accordingly.

WirePlumber trap: choosing a device in GNOME Settings writes
`default.configured.*` to `~/.local/state/wireplumber/default-nodes`, which
overrides all priority rules. To clear it, stop wireplumber, delete the file,
then start it again.

## 7. heptane on papaya

Run `heptane` (now a dry run) and go through the drift with Neil before
`heptane apply`. Don't remove packages wholesale. durian's drift held mostly
real tools that had never been declared. papaya-specific hardware packages go
in the `papaya` branch of `hardware.toml.tmpl`. `wireless-regdb` is now
declared for every machine.

## Decided / open

- Firefox stays installed as an option (`apps.toml`, `50-firefox.conf`); it is
  just no longer launched by start.sh. Don't remove it.
- `pkgbuilds/gnome-shell-extension-pop-shell-git/` is untracked build output on
  durian (the PKGBUILD was dropped 2026-10-20). Delete it there and on papaya if present.
