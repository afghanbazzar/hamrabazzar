Hamraman deploy kit

This folder contains small helper scripts and instructions to deploy the app to your VPS using git and rsync.

Overview

- deploy/deploy.sh - Run locally to push the current branch to origin, then SSH into the VPS and run the remote deploy script.
- deploy/remote-deploy.sh - Example script to run on the VPS to pull, install, build and restart the service.
- deploy/rsync_uploads.sh - Helper to sync `public/uploads/` to your VPS (recommended for image assets if you don't commit them to git).
- deploy/hamraman.service - systemd unit file example for running the built server in production.

Prerequisites

- A remote VPS with SSH access and a user with permissions to pull from your git repository (or add your SSH deploy key).
- Node >= 18 (or the version your project requires) installed on the VPS.
- git installed on the VPS.
- If using systemd: ability to create a unit file and manage services (sudo).

Quick start (two options)

Option A: Push + pull (recommended if repository contains built assets only when running build on VPS)

1. On your development machine:

   - Commit your changes and push the branch to origin.
   - Run:

```bash
bash deploy/deploy.sh user@your-vps.example.com /path/to/app repo-name branch-name
```

2. The script will SSH into the VPS and run `deploy/remote-deploy.sh` to pull, install and build.

Option B: rsync uploads only (if you prefer not to commit images)

1. Commit and push code as usual.
2. Run:

```bash
bash deploy/rsync_uploads.sh user@your-vps.example.com /path/to/app
```

Files

- deploy.sh: local helper to trigger a remote deploy after push.
- remote-deploy.sh: remote script to be executed on the VPS (idempotent, safe to re-run).
- rsync_uploads.sh: copies `public/uploads/` to the remote server's `public/uploads/`.
- hamraman.service: systemd unit example to run the production server using `node dist/index.js` (adjust path and user).

Security note

Do not store secrets or .env files in git. Use environment variables or a secrets manager. The remote script expects you to place a `.env` in the app root on the VPS containing `DATABASE_URL` and other secrets.

Support

If you want, I can also:
- Create a deploy key and add a GitHub Actions workflow for CI/CD.
- Create a pm2 ecosystem file instead of systemd.
- Help run the deployment if you provide SSH access.
