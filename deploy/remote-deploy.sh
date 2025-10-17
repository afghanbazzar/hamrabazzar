#!/usr/bin/env bash
# deploy/remote-deploy.sh
# Run on the VPS inside the repository root. Safe to re-run.

set -euo pipefail

echo "Running remote deploy script..."

# Ensure correct node version is available (assumes node is available on PATH)
NODE=`node -v || true`
if [ -z "$NODE" ]; then
  echo "Node not found. Please install Node.js on the VPS and re-run."
  exit 1
fi

# Default environment: adjust as needed
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Pull latest changes
echo "Fetching and resetting to origin/$BRANCH"
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

# Install dependencies
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

# Build client and server
npm run build

# Option A: systemd service example (requires `hamraman.service` unit installed)
# If using systemd, attempt to reload and restart service named hamraman
if sudo systemctl --version >/dev/null 2>&1; then
  echo "Reloading systemd and restarting hamraman.service (if exists)"
  sudo systemctl daemon-reload || true
  if sudo systemctl status hamraman.service >/dev/null 2>&1; then
    sudo systemctl restart hamraman.service
    echo "hamraman.service restarted"
  else
    echo "hamraman.service not found. You can install deploy/hamraman.service as /etc/systemd/system/hamraman.service and then enable it."
  fi
fi

# Option B: pm2 fallback
if command -v pm2 >/dev/null 2>&1; then
  echo "Restarting with pm2 (ecosystem not provided)
  pm2 restart hamraman || pm2 start --name hamraman node dist/index.js
fi

echo "Remote deploy complete. Tail logs with: journalctl -u hamraman -f or pm2 logs hamraman"
