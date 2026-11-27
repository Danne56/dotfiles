#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="${HOME}/.local/bin"

log()  { printf ':: %s\n' "$*"; }
ok()   { printf '✓ %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
err()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || err "Missing required command: $1"
}

check_prereqs() {
	require_cmd stow
	require_cmd yazi
	require_cmd ya
	require_cmd curl
	require_cmd tar
}

ensure_7zz() {
	mkdir -p "$BIN_DIR"
	if command -v 7zz >/dev/null 2>&1; then
		ok "7zz found at $(command -v 7zz)"
		return
	fi
	if command -v 7z >/dev/null 2>&1; then
		local target
		target="$(command -v 7z)"
		ln -sf "$target" "$BIN_DIR/7zz"
		ok "Linked $BIN_DIR/7zz -> $target"
		return
	fi
	err "Neither 7zz nor 7z found. Install 7zip (e.g. 'sudo pacman -S 7zip' on Arch)."
}

stow_yazi() {
	log "Stowing yazi config from $DOTFILES_DIR"
	stow --dir="$DOTFILES_DIR" --target="$HOME" --restow yazi
	ok "Stowed yazi config (including vfs.toml)"
}

install_ya_plugins() {
	log "Installing yazi plugins from package.toml"
	ya pkg install
	ok "Yazi plugins installed"
}

install_zippity_helper() {
	local os arch target tag tarball url tmpdir
	os="$(uname -s)"
	arch="$(uname -m)"

	case "${os}:${arch}" in
		Linux:x86_64)  target="x86_64-unknown-linux-musl" ;;
		Darwin:arm64)  target="aarch64-apple-darwin" ;;
		*) err "Unsupported platform for zippity prebuilt binary: ${os}/${arch}" ;;
	esac

	log "Fetching latest hawkff/zippity release"
	tag="$(curl -fsSL "https://api.github.com/repos/hawkff/zippity/releases/latest" \
		| sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1)"
	[ -n "$tag" ] || err "Failed to determine latest zippity release tag"

	tarball="zippity-${tag}-${target}.tar.gz"
	url="https://github.com/hawkff/zippity/releases/download/${tag}"

	tmpdir="$(mktemp -d)"
	TMPDIR_CLEANUP="$tmpdir"
	trap 'rm -rf "${TMPDIR_CLEANUP:-}"' EXIT

	log "Downloading ${tarball} (${tag})"
	curl -fsSL -o "$tmpdir/$tarball" "${url}/${tarball}"
	curl -fsSL -o "$tmpdir/SHA256SUMS" "${url}/SHA256SUMS"

	if command -v sha256sum >/dev/null 2>&1; then
		(cd "$tmpdir" && sha256sum -c --ignore-missing SHA256SUMS)
	elif command -v shasum >/dev/null 2>&1; then
		(cd "$tmpdir" && grep " ${tarball}\$" SHA256SUMS | shasum -a 256 -c -)
	else
		warn "No sha256sum/shasum found; skipping checksum verification"
	fi

	mkdir -p "$BIN_DIR"
	tar -xzf "$tmpdir/$tarball" -C "$tmpdir"
	local bin_path
	bin_path="$(find "$tmpdir" -type f -name zippity | head -n 1)"
	[ -n "$bin_path" ] || err "zippity binary not found in archive"

	install -m 0755 "$bin_path" "$BIN_DIR/zippity"
	ok "Installed $BIN_DIR/zippity ($tag)"
}

verify_setup() {
	case ":$PATH:" in
		*":$BIN_DIR:"*) ;;
		*) warn "$BIN_DIR is not in PATH; add it to your shell config" ;;
	esac

	"$BIN_DIR/zippity" --help >/dev/null
	[ -e "$HOME/.config/yazi/vfs.toml" ] || err "Missing ~/.config/yazi/vfs.toml"
	ok "Verified zippity helper and yazi VFS config"
}

main() {
	check_prereqs
	ensure_7zz
	stow_yazi
	install_ya_plugins
	install_zippity_helper
	verify_setup
}

main "$@"
