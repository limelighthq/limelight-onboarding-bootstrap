#!/bin/bash
# Public entry point. No GitHub account, credentials, or database settings.
set -euo pipefail
PRIVATE_SETUP_URL='http://lunas-mac-mini.tail9e8551.ts.net:4445/onboarding/latest/setup.sh'
CANONICAL_SETUP_URL='http://lunas-mac-mini.tail9e8551.ts.net:4445/onboarding/latest/setup.sh'
if [[ "$(uname -s)" != Darwin ]]; then echo 'Please run this on a Mac.' >&2; exit 1; fi
if [[ ! -t 0 ]]; then echo 'Download this file first, then run it with bash in Terminal.' >&2; exit 1; fi
if [[ "$PRIVATE_SETUP_URL" != "$CANONICAL_SETUP_URL" ]]; then echo 'Installer endpoint is not configured.' >&2; exit 1; fi
printf '\n  LIMELIGHT\n  Connect your Mac. Then make it yours.\n\n'
printf 'You need a team Tailscale invitation and your work Google account.\n'
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
TAILSCALE_APP='/Applications/Tailscale.app'
if [[ ! -d "$TAILSCALE_APP" && -d "$HOME/Applications/Tailscale.app" ]]; then TAILSCALE_APP="$HOME/Applications/Tailscale.app"; fi
if [[ ! -d "$TAILSCALE_APP" ]]; then
  read -r -p 'Install Tailscale from its official package? [y/N] ' answer
  case "$answer" in y|Y|yes|YES) ;; *) echo 'Tailscale is required. Run this again when ready.'; exit 0;; esac
  PACKAGE_URL='https://pkgs.tailscale.com/stable/Tailscale-latest-macos.pkg'
  curl --proto '=https' --proto-redir '=https' --tlsv1.2 -fL --retry 2 "$PACKAGE_URL" -o "$WORK_DIR/Tailscale.pkg"
  /usr/sbin/pkgutil --check-signature "$WORK_DIR/Tailscale.pkg"
  /usr/sbin/spctl --assess --type install "$WORK_DIR/Tailscale.pkg"
  printf '\nmacOS will ask for your Mac password to install Tailscale.\n'
  sudo /usr/sbin/installer -pkg "$WORK_DIR/Tailscale.pkg" -target /
fi
open "$TAILSCALE_APP"
printf '\nIn Tailscale, approve the VPN/system extension if prompted.\nSign in with Google using your invited work account and connect.\n'
while true; do
  read -r -p 'When connected, press Return to continue (or type q to stop): ' answer
  [[ "$answer" != q && "$answer" != Q ]] || exit 0
  META=''
  if META=$(curl --proto '=http' --proto-redir '=http' --max-redirs 0 --connect-timeout 10 --max-time 30 -fsS --write-out '%{http_code}\n%{url_effective}\n%{redirect_url}' "$PRIVATE_SETUP_URL" -o "$WORK_DIR/setup.sh"); then
    STATUS=$(printf '%s\n' "$META" | sed -n '1p')
    EFFECTIVE=$(printf '%s\n' "$META" | sed -n '2p')
    REDIRECT=$(printf '%s\n' "$META" | sed -n '3p')
    if [[ "$STATUS" == 200 && "$EFFECTIVE" == "$PRIVATE_SETUP_URL" && -z "$REDIRECT" ]]; then break; fi
  fi
  printf '\nThe private installer is not reachable yet. Check your Tailscale connection,\nwork account, and invitation. Ask your admin if access is still denied.\n\n'
done
printf '\nConnected. Starting your private onboarding…\n'
bash "$WORK_DIR/setup.sh" "$@"
