#!/usr/bin/env bash
# deploy/rsync_uploads.sh
# Usage: deploy/rsync_uploads.sh user@vps.example.com /path/to/app
# Copies local public/uploads/ to remote server's public/uploads/

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 user@vps.example.com /path/to/app"
  exit 2
fi

REMOTE="$1"
REMOTE_APP_PATH="$2"
LOCAL_UPLOADS_DIR="public/uploads/"

if [ ! -d "$LOCAL_UPLOADS_DIR" ]; then
  echo "Local uploads directory not found: $LOCAL_UPLOADS_DIR"
  exit 1
fi

# Ensure remote directory exists
ssh "$REMOTE" "mkdir -p '$REMOTE_APP_PATH/public/uploads'"

# Use rsync (preserves times and compresses)
rsync -avz --delete "$LOCAL_UPLOADS_DIR" "$REMOTE:$REMOTE_APP_PATH/public/"

echo "Uploads synced to $REMOTE:$REMOTE_APP_PATH/public/uploads"
