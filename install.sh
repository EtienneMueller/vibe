#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/EtienneMueller/vibe.git"
VIBE_HOME="$HOME/.vibe"
VIBE_REPO_DIR="$VIBE_HOME/repo"
BIN_DIR="$HOME/.local/bin"

echo "==> checking prerequisites"

command -v docker >/dev/null 2>&1 || {
  echo "Docker not found. Install Docker Desktop first: https://www.docker.com/products/docker-desktop/" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || {
  echo "git not found. Install git first, then re-run this installer." >&2
  exit 1
}

mkdir -p "$VIBE_HOME" "$BIN_DIR"

if [[ -d "$VIBE_REPO_DIR/.git" ]]; then
  echo "==> updating existing install"
  git -C "$VIBE_REPO_DIR" checkout -- . 2>/dev/null || true
  git -C "$VIBE_REPO_DIR" pull --quiet
else
  echo "==> installing"
  git clone --quiet "$REPO_URL" "$VIBE_REPO_DIR"
fi

ln -sf "$VIBE_REPO_DIR/vibe" "$BIN_DIR/vibe"
chmod +x "$VIBE_REPO_DIR/vibe"

echo "==> building sandbox image (this may take a minute)"
docker build \
  --build-arg HOST_UID="$(id -u)" \
  -t vibe-sandbox:latest "$VIBE_REPO_DIR"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo ""
    echo "NOTE: $BIN_DIR isn't on your PATH yet. Add this to your shell config"
    echo "(~/.zshrc or ~/.bashrc) and restart your terminal:"
    echo ""
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    ;;
esac

echo "==> done. try: cd into a git repo, then run 'vibe claude'"