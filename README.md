# Limelight setup

Public first-connection helper for invited Limelight teammates on macOS.

Open Terminal and paste:

```bash
setup_file=$(mktemp) && curl --proto '=https' --tlsv1.2 -fsSL 'https://raw.githubusercontent.com/limelighthq/limelight-onboarding-bootstrap/main/setup.sh' -o "$setup_file" && bash "$setup_file"; [ -z "${setup_file:-}" ] || rm -f "$setup_file"
```

1. Accept your team's Tailscale invitation first.
2. This script offers to install Tailscale from its official package server if it is missing. macOS may ask for your Mac password and VPN/system-extension approval.
3. Sign in to Tailscale using Google with your invited work account and connect.
4. Press Return. The script downloads and starts the private onboarding app only when the company endpoint is reachable.

No GitHub account, organization seat, Git, or GitHub token is needed. This public repository contains only the bootstrap and this guide, not the private onboarding application, database settings, or credentials. The endpoint in the script grants no access by itself.

The team-only guide and installer require company Tailscale access. If access fails, ask your onboarding admin to check your invitation and work-account connection. Do not share passwords or secret values.
