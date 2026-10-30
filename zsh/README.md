# Zsh Cheatsheet

Quick reference for custom hotkeys, widgets, global aliases, and helpers configured across `.zshrc`, `.zprofile`, `alias`, and `function`.

---

## 1. Keybindings & Hotkeys

### Command Line & Buffer
| Key | Action |
| --- | --- |
| `Ctrl + X` then `Ctrl + E` | Open current line in `$EDITOR` (`hx`) |
| `Ctrl + X` then `Ctrl + C` | Copy current command line to clipboard (`wl-copy`) |
| `Ctrl + L` | Clear screen + scrollback buffer (keeps active input) |
| `Alt + W` | Kill region (cut selected text) |

### Navigation & History
| Key | Action |
| --- | --- |
| `Up` / `Down` | Search history matching currently typed prefix |
| `Ctrl + P` / `Ctrl + N` | Previous / Next command in history |
| `Home` / `End` | Jump to beginning / end of line |
| `Shift + Tab` | Reverse menu completion |

### Quick Snippet Insertions (`Ctrl + X` prefix)
| Sequence | Inserts |
| --- | --- |
| `Ctrl + X`, `g` `c` | `git commit -m ""` (cursor placed inside quotes) |
| `Ctrl + X`, `g` `p` | `git push origin ` |
| `Ctrl + X`, `g` `s` | `git status` + Enter |
| `Ctrl + X`, `g` `l` | `git log --oneline -n 10` + Enter |
| `Ctrl + X`, `d` `u` | `docker compose up -d` |
| `Ctrl + X`, `d` `b` | `docker compose up -d --build` |
| `Ctrl + X`, `d` `d` | `docker compose down` |

---

## 2. Global Aliases (Use Anywhere in Command)

Append directly to any command:

| Alias | Expansion | Purpose | Example |
| --- | --- | --- | --- |
| `NE` | `2>/dev/null` | Silence errors | `find . -name "*.log" NE` |
| `NO` | `>/dev/null` | Silence standard output | `my-script NO` |
| `NUL` | `>/dev/null 2>&1` | Silence all output | `command NUL &` |
| `J` | `\| jq` | Pipe into jq | `curl -s api.com J` |
| `C` | `\| wl-copy` | Pipe into Wayland clipboard | `cat id_ed25519.pub C` |

---

## 3. Shell Aliases & Functions

### Navigation & Files
- `cd <path>` — Zoxide smart jump (`--cmd cd`)
- `ls` / `lsa` / `ll` — `eza` with auto icons and grouped directories
- `lt` / `lta` — Tree view (`eza --tree --level=2 --long --icons --git`)
- `ff` — Interactive file finder with `bat` syntax preview
- `y` — Launch `yazi` file manager and `cd` to current directory on exit

### System & Tools
- `syu` — Unified system update (`pacman -Syu` or `apt update && upgrade`)
- `fk` — Rerun previous command with `sudo` (`sudo !!`)
- `lzd` — Launch LazyDocker
- `cw` / `wd` — Cloudflare WARP connect / disconnect
- `alert` — Desktop notification when a long-running command completes
- `zshrc` / `zprofile` — Quick edit config in `$EDITOR`

---

## 4. `zmv` Deep Dive (Safe Batch Rename & Move)

`zmv` is Zsh’s built-in file rename tool. It pre-validates target destinations to prevent accidental overwrites or collisions before renaming any file.

### Safety Flags (Always Use First)
| Flag | What it does | Example |
| --- | --- | --- |
| `-n` | **Dry-run**: prints planned renames without executing them | `zmv -n '(*).jpeg' '$1.jpg'` |
| `-i` | **Interactive**: prompts before each individual rename | `zmv -i '(*).txt' '$1.bak'` |
| `-v` | **Verbose**: displays each rename as it happens | `zmv -v '(*).htm' '$1.html'` |
| `-f` | **Force**: overwrite existing target files without erroring | `zmv -f '(*).tmp' '$1.dat'` |

---

### Syntax & Matching Rules

1. **Quote both arguments**: Always use single quotes `'...'` so Zsh evaluates pattern variables (`$1`, `$2`) inside `zmv`, not before execution:
   ```zsh
   zmv 'pattern' 'replacement'
   ```

2. **Glob Pattern Matching**:
   - `*` matches any string; `?` matches a single character.
   - `[abc]` matches any character in the set (e.g. `[zZ]`).
   - `[0-9]` or `[a-z]` matches a character range.
   - `[^abc]` matches any character *not* in the set.
   - `(foo|bar)` alternation matches either `foo` or `bar`.
   - `<1-100>` matches a numeric range.

3. **Capture Groups `(...)` & `$1, $2, ...`**:
   Parentheses define captured substrings referenced in the target:
   ```zsh
   # photo-01.jpg -> 01-photo.jpg
   zmv '(*)-(*).jpg' '$2-$1.jpg'
   ```

4. **`-w` (Auto-Wildcard Mode)**:
   `-w` implicitly wraps each `*` and `?` in capture groups:
   ```zsh
   # Without -w: zmv '(*).txt' '$1.md'
   # With -w:
   zmv -w '*.txt' '*.md'
   ```

---

### Practical Recipes

#### A. Change File Extensions
```zsh
zmv '(*).jpeg' '$1.jpg'
zmv -w '*.htm' '*.html'
```

#### B. Replace Spaces with Underscores or Hyphens
```zsh
zmv '(* *)' '${1// /_}'
```

#### C. Lowercase / Uppercase File Names
Using Zsh parameter expansion flags:
```zsh
# Lowercase all uppercase .PNG extensions: FILE.PNG -> FILE.png
zmv '(*).PNG' '$1.png'

# Convert entire filenames to lowercase:
zmv '(*)' '${(L)1}'

# Convert entire filenames to uppercase:
zmv '(*)' '${(U)1}'
```

#### D. Recursive Renaming in Subdirectories (`**/`)
```zsh
# Rename all nested .bak files to .old
zmv '(**/)(*).bak' '$1$2.old'
```

#### E. Add Prefix or Suffix
```zsh
# Prefix all .mp4 files with "vacation_"
zmv '(*).mp4' 'vacation_$1.mp4'

# Add date prefix to all .csv files
zmv '(*).csv' "$(date +%Y%m%d)-"'${1}.csv'
```

#### F. Copy / Link Instead of Move
| Flag | Action | Example |
| --- | --- | --- |
| `-C` | Copy instead of rename (`cp`) | `zmv -C '(*).conf' '$1.conf.bak'` |
| `-L` | Hard link files (`ln`) | `zmv -L '(*).jpg' 'backup-$1.jpg'` |
| `-s` | Symbolic link (`ln -s`) | `zmv -s '(*).log' '/var/log/backup/$1.log'` |

---

## 5. Built-in Automation & Tools

- **Auto Python venv**: Automatically activates `.venv` when entering a project directory; deactivates upon leaving.
- **FZF Tab**: Press `Tab` on `cd` or `__zoxide_z` for interactive `eza` directory previews.
