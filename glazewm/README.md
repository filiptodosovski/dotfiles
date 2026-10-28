# GlazeWM: the AeroSpace setup on Windows

`config.yaml` translates the Mac config at `../aerospace/aerospace.toml` for
GlazeWM 3.10.1. It needs no helper scripts, WSL commands, or Zebar installation.
The AeroSpace file and the running Mac configuration are unchanged.

## Install and transfer

Run in **Windows PowerShell**, not Ubuntu:

```powershell
winget install GlazeWM
```

1. Launch GlazeWM once from Start, then exit it through its tray icon.
2. Press Win+R and open `%USERPROFILE%\.glzr\glazewm`.
3. Back up the existing `config.yaml`. Copy this folder's `config.yaml` there.
   Keep that exact filename; it must not become `config.yaml.txt`.
4. Start GlazeWM again. No repository checkout or WSL setup is required.

If the destination folder doesn't exist, create it. This is the **Windows** user
profile, for example `C:\Users\Filip\.glzr\glazewm\config.yaml`, not `/home/filip`.
For automatic startup, press Win+R, open `shell:startup`, and put a shortcut to
the installed GlazeWM application there. Configure only one startup entry.

## Shortcuts

Use a QWERTY keyboard layout when comparing punctuation with the Mac bindings.
The YAML uses GlazeWM's Windows OEM key names for `/`, `;`, `-`, `=`, and backtick.
These refer to physical Windows keys; printed symbols differ on other layouts.

| Shortcut | Action |
| --- | --- |
| Alt+H/J/K/L | Focus left/down/up/right |
| Alt+Shift+H/J/K/L | Move the focused window |
| Alt+1 through Alt+9 | Switch numbered workspace |
| Alt+B/D/I/M/O/R/T/V/W | Switch named workspace |
| Alt+Shift+workspace key | Send the window there without following it |
| Alt+/ | Toggle the local horizontal/vertical tiling direction |
| Alt+Shift+- / Alt+Shift+= | Decrease/increase width by 50px |
| Alt+Shift+F | Toggle fullscreen |
| Alt+Tab or Alt+backtick | Switch to the previously focused workspace |
| Alt+Shift+Tab | Move this workspace to the monitor on the right |
| Alt+Shift+; | Enter service mode; release the keys before the next command |
| Ctrl+Alt+Shift+R | Reload configuration |
| Alt+Shift+P | Pause/resume GlazeWM, including while in either mode |

Service mode: **Esc** leaves and reloads, **Enter** leaves, **F** toggles the
focused window's floating/tiling state, **R** redraws windows, and the **arrow keys**
move the workspace to a monitor in that direction. **S** enters resize mode:
H/L change width, J/K decrease/increase height, and Esc/Enter exits.
While a mode is active, its bindings replace the normal bindings.

Alt+Tab is intentionally taken over to match your Mac. Remove `alt+tab` from
that binding's list if you prefer Windows application switching; Alt+backtick
remains available. A system/app shortcut may still take precedence on your PC.

## Workspaces and app rules

All 18 Mac workspace names are declared with `keep_alive: true`, keeping visited
workspaces alive after their last window closes. Inner and outer gaps are 10px,
scaled with display DPI. New windows tile and the cursor follows window focus.

| Workspace | New Windows app windows |
| --- | --- |
| T | WezTerm |
| W | Chrome, Firefox, Edge |
| D | VS Code, VS Code Insiders, WebStorm |
| B | Slack, Discord |
| M | Zoom |

Rules use Windows process names without `.exe`, case-insensitively. They run
once on initial management so manually moving an app doesn't get undone by a
title change. They don't launch apps automatically. Reopen an app if needed to
test its rule. `glazewm query windows` in PowerShell shows the process metadata
for diagnosing a rule that doesn't match your installed app variant.

Raycast, Zebar, PowerToys Run/Command Palette overlays, and browser
picture-in-picture windows are ignored so they keep their own positioning.
No extra bar is launched by this configuration.

## Differences from AeroSpace

GlazeWM uses a different layout tree. This config keeps the supported behavior
and makes these substitutions explicit:

- **Alt+comma / accordion and its 30px padding:** unavailable; left unbound.
- **Alt+slash:** toggles local tiling direction, rather than reproducing
  AeroSpace's full layout cycle or automatic root orientation.
- **Smart resize:** width changes on the original shortcut; service -> S gives
  width and height control. There is no automatic smart-axis selection here.
- **Monitor cycling:** Alt+Shift+Tab moves right without wrapping. Service-mode
  arrows let you select other directions; on one monitor these do nothing.
- **Service R / flatten tree:** redraw only; it doesn't reset split structure.
- **Service Alt+Shift+H/J/K/L / join-with and Backspace / close all others:**
  no direct commands; left unbound. Close individual windows with normal Windows
  controls when needed.
- **Start at login:** use the Windows startup shortcut described above.
- AeroSpace's normalization and macOS hidden-app settings have no config
  equivalents here. Only one cursor-jump trigger is available; window focus is
  used instead of separate window and monitor callbacks.

YAML structure, workspace coverage, shortcut uniqueness, and command names were
checked locally against the released source. Actual window behavior and shortcut
conflicts still need testing on the Windows laptop. If startup fails, run
`glazewm start` in an existing PowerShell window to keep the error visible.

Sources: [GlazeWM](https://github.com/glzr-io/glazewm),
[released config schema](https://github.com/glzr-io/glazewm/blob/v3.10.1/packages/wm-common/src/parsed_config.rs),
[released commands](https://github.com/glzr-io/glazewm/blob/v3.10.1/packages/wm-common/src/app_command.rs).

## Raycast

[Raycast itself is available for Windows](https://www.raycast.com/windows).
Install in Windows PowerShell with `winget install raycast`, then launch it from
Start and choose its activation shortcut. Keep it distinct from GlazeWM's keys.
Start with app search, calculator, clipboard history, snippets, and quicklinks.
Windows feature/extension support can differ from macOS.
