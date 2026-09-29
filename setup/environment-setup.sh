#!/usr/bin/env bash
# Example environment setup for a fresh Linux environment that will work on a
# ghul-lang repository: installs the .NET 10 SDK and the GitHub CLI, puts both
# on the PATH, and clones this guide beside the working repository.
#
# Adjust to the environment: where tools can be installed, whether sudo is
# available, and where the guide should be cloned. Every step is skipped when
# what it installs is already present, so the script is safe to run again.

set -euo pipefail

GUIDE_DIR="${GUIDE_DIR:-$HOME/ghul-agent-guide}"
DOTNET_DIR="${DOTNET_DIR:-$HOME/.dotnet}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

mkdir -p "$BIN_DIR"

# The .NET 10 SDK, from Microsoft's install script, into the user's home so
# no root access is needed.
if ! "$DOTNET_DIR/dotnet" --list-sdks 2>/dev/null | grep -q '^10\.'; then
    curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
    bash /tmp/dotnet-install.sh --channel 10.0 --install-dir "$DOTNET_DIR"
fi

# The GitHub CLI, as a release archive for the same reason.
if ! command -v gh >/dev/null 2>&1; then
    version=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
        | grep -oP '"tag_name":\s*"v\K[^"]+')
    arch=$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/')
    curl -fsSL "https://github.com/cli/cli/releases/download/v${version}/gh_${version}_linux_${arch}.tar.gz" \
        | tar -xz -C /tmp
    cp "/tmp/gh_${version}_linux_${arch}/bin/gh" "$BIN_DIR/gh"
fi

# Make both reachable from later shells, and from this one.
profile="$HOME/.bashrc"
line="export DOTNET_ROOT=\"$DOTNET_DIR\"; export PATH=\"$DOTNET_DIR:$DOTNET_DIR/tools:$BIN_DIR:\$PATH\""
grep -qxF "$line" "$profile" 2>/dev/null || echo "$line" >> "$profile"
eval "$line"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1

# The guide itself. Read its README.md before starting work. The repository is
# private, so the clone needs GitHub credentials in the environment.
if [ ! -d "$GUIDE_DIR/.git" ]; then
    git clone --depth 1 https://github.com/ghul-lang/ghul-agent-guide.git "$GUIDE_DIR"
else
    git -C "$GUIDE_DIR" pull --ff-only
fi

dotnet --version
gh --version | head -1
echo "guide: $GUIDE_DIR/README.md"
