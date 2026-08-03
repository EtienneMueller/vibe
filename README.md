# Vibe

Run your agentic coding harness (Claude Code, soon OpenCode/Pi) against a git repo inside a sandboxed Docker container (with no ability to commit or push to your remote). `vibe` builds that containment once, so you don't have to think about it per-project:

- The container has *no push credentials at all*: no SSH keys, no git credential helper, no tokens. It physically can't push, so there's no permission system to trust.
- Your repo is *live bind-mounted*, so edits show up on your host immediately: no copying files out afterward.
- `~/.claude`: mounted straight through from your machine, so your existing login and any global Claude Code preferences carry into every container.
- Everything else (the sandbox image, container state, per-repo bookkeeping) lives under `~/.vibe/` on your machine. Nothing repo-side: `vibe` never creates, edits, or gitignores any file in your project.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/EtienneMueller/vibe/main/install.sh | bash
```

Requires [Docker](https://www.docker.com/products/docker-desktop/) and `git` (safe to re-run: it updates `vibe` and rebuilds the sandbox image).

## Usage

```bash
cd your-project
vibe claude
```

Launches Claude Code (with `--dangerously-skip-permissions`), running inside the container, with your repo mounted and live-editable. When you're finished:

```bash
exit
```

Come back later and pick up where you left off:

```bash
vibe resume
```

Review and ship normally (outside the container):

```bash
git diff
git add . && git commit && git push
```

## Commands

|Command|What it does|
|---|---|
|`vibe claude`|Start or resume this repo's sandbox, using Claude Code|
|`vibe resume`|Resume using whichever harness this repo was last set up with|
|`vibe opencode`|_(not implemented yet)_|
|`vibe pi`|_(not implemented yet)_|

## Notes

- One harness per repo at a time: Running a different harness command on a repo re-points it at that harness rather than running both at once.
- `--dangerously-skip-permissions` is on by default for the harness.
- Stopping the container (`exit`) frees CPU/RAM but not disk: the stopped container persists so your next `vibe resume` is fast. Run `docker rm vibe-<hash>` or `docker system prune` occasionally if that adds up.
