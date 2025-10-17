#!/usr/bin/env bash
# deploy/deploy.sh
# Usage: deploy/deploy.sh user@vps.example.com /path/to/app repo-name branch-name
# This script runs on your local machine. It will push the current branch then SSH to the VPS
# and execute the remote-deploy.sh script located in the repository on the VPS.

set -euo pipefail

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 user@vps.example.com /path/to/app repo-name branch-name"
  exit 2
fi

REMOTE="$1"
REMOTE_APP_PATH="$2"
REPO_NAME="$3"
BRANCH="$4"

# Ensure branch is pushed
git add -A
read -p "Commit message (leave empty to abort): " COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
  echo "Aborted: provide a commit message"
  exit 1
fi

git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

# SSH to remote and run remote-deploy.sh
ssh "$REMOTE" "bash -s" <<'REMOTE_SCRIPT'
set -euo pipefail
REMOTE_APP_PATH="${REMOTE_APP_PATH}"
REPO_NAME="${REPO_NAME}"
BRANCH="${BRANCH}"
# Change to app path and run remote-deploy.sh from the checked-out repo.
if [ ! -d "$REMOTE_APP_PATH" ]; then
  echo "Remote app path does not exist: $REMOTE_APP_PATH"
  exit 2
fi
cd "$REMOTE_APP_PATH"
if [ -x ./deploy/remote-deploy.sh ]; then
  ./deploy/remote-deploy.sh
else
  echo "Remote deploy script not found or not executable. Ensure deploy/remote-deploy.sh is present in the repo on the VPS."
  exit 3
fi
REMOTE_SCRIPT

echo "Remote deploy triggered."
