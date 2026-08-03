FROM node:20-bookworm-slim

# Basic dev tooling. Add more here over time as prototyping needs grow —
# this is intentionally minimal to start.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    build-essential \
    less \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Claude Code. No API key / credentials baked in here — auth is handled
# entirely via the ~/.claude mount at container-run time (see the `vibe`
# script), never at image-build time.
RUN npm install -g @anthropic-ai/claude-code

# Claude Code refuses --dangerously-skip-permissions when run as root/sudo,
# regardless of container isolation — so a non-root user is required here
# purely to satisfy that check, not because it changes anything about the
# sandbox's actual security properties (those come from the lack of
# credentials and the mount boundaries, not from the Linux user id).
#
# Only UID is matched to the host (not GID) — UID is what actually
# determines bind-mount file ownership in the common case, and matching
# GID too risks colliding with a GID the base image or OS already reserves
# (e.g. macOS assigns GID 20/"staff" to most users by default, which
# collides with Debian's own use of low GIDs).
ARG HOST_UID=1000
RUN useradd --create-home --shell /bin/bash --uid "$HOST_UID" vibe
USER vibe
WORKDIR /home/vibe/workspace

# No ENTRYPOINT/CMD here on purpose — the `vibe` script decides what to run
# (a shell, or `claude --dangerously-skip-permissions` directly) at `docker run`
# time, so the image itself stays a plain, reusable base.
