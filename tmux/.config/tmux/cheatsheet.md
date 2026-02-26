# tmux cheatsheet

**Prefix:** `Ctrl+Space`

---

## Sessions

| Key                  | Action            |
| -------------------- | ----------------- |
| `tmux new -s name`   | New named session |
| `tmux ls`            | List sessions     |
| `tmux a -t name`     | Attach to session |
| `Prefix + $`         | Rename session    |
| `Prefix + d`         | Detach            |
| `Prefix + s`         | Browse sessions   |

---

## Windows

| Key            | Action                  |
| -------------- | ----------------------- |
| `Prefix + c`   | New window (keeps path) |
| `Prefix + ,`   | Rename window           |
| `Prefix + &`   | Kill window             |
| `Prefix + w`   | Browse windows          |
| `Prefix + 1-9` | Go to window N          |
| `Alt + p`      | Previous window         |
| `Alt + n`      | Next window             |

---

## Panes

| Key           | Action                        |
| ------------- | ----------------------------- |
| `Prefix + \|` | Split horizontal (keeps path) |
| `Prefix + -`  | Split vertical (keeps path)   |
| `Prefix + x`  | Kill pane                     |
| `Prefix + z`  | Zoom/unzoom pane              |
| `Prefix + R`  | Respawn pane                  |

### Navigate (no prefix)

| Key       | Action |
| --------- | ------ |
| `Alt + h` | Left   |
| `Alt + l` | Right  |
| `Alt + k` | Up     |
| `Alt + j` | Down   |

### Resize (hold prefix, repeatable)

| Key          | Action       |
| ------------ | ------------ |
| `Prefix + H` | Shrink left  |
| `Prefix + L` | Expand right |
| `Prefix + K` | Expand up    |
| `Prefix + J` | Shrink down  |

### Move / Swap

| Key          | Action                |
| ------------ | --------------------- |
| `Prefix + m` | Mark pane             |
| `Prefix + S` | Swap with marked pane |
| `Prefix + <` | Move pane up/left     |
| `Prefix + >` | Move pane down/right  |

---

## Copy Mode (vi)

| Key              | Action              |
| ---------------- | ------------------- |
| `Prefix + Enter` | Enter copy mode     |
| `v`              | Begin selection     |
| `Ctrl + v`       | Rectangle selection |
| `y`              | Copy and exit       |
| `q`              | Quit copy mode      |

---

## Misc

| Key          | Action               |
| ------------ | -------------------- |
| `Prefix + r` | Reload config        |
| `Prefix + Y` | Toggle pane sync     |
| `Prefix + t` | Show clock           |
| `Prefix + ?` | List all keybindings |
