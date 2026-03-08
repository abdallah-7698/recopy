# Recopy

A lightweight macOS menu bar app that keeps a searchable history of everything you copy to the clipboard. Select any past item to instantly paste it into your active application.

## Features

- **Clipboard Monitoring** — Automatically captures every text you copy (polled every 0.5s). Duplicates of the most recent item are ignored.
- **Global Hotkey** — Toggle the history panel with a customizable shortcut (default `Cmd+Ctrl+X`).
- **Customizable Shortcut** — Change the toggle hotkey to any key combination via "Change Shortcut..." in the menu bar, with a reset-to-default option.
- **Search** — Filter your clipboard history in real time with the built-in search bar.
- **Pin Items** — Pin important items so they stay at the top and survive "Clear History".
- **Instant Paste** — Click an item or press `Return` to paste it directly into the previously active app (simulates `Cmd+V`).
- **Launch at Login** — Toggle "Launch at Login" from the menu bar to start Recopy automatically on boot.
- **Menu Bar Icon** — Lives in the menu bar with options to show history, change shortcut, launch at login, clear history, or quit.
- **Floating Panel** — The history panel floats above all windows, appears near your mouse cursor, and hides when you click away.

## Download & Install

1. Go to the [Releases](https://github.com/abdallah-7698/recopy/releases/latest) page.
2. Download **Recopy.dmg**.
3. Open the DMG and drag **Recopy** into your **Applications** folder.
4. Launch Recopy from Applications. It will appear as a clipboard icon in your menu bar.
5. When prompted, grant **Accessibility** permission (System Settings > Privacy & Security > Accessibility) — this is required for the app to work.

## Requirements

- macOS 14+
- **Accessibility permission** — On first launch the app requests Accessibility access (System Settings > Privacy & Security > Accessibility). Required for global hotkeys and simulated paste.

## How to Use

1. **Launch the app.** It appears as a clipboard icon in the menu bar — no Dock icon.
2. **Copy text as usual** (`Cmd+C`). Each copied item is saved automatically (up to 50 unpinned items).
3. **Open the panel** with `Cmd+Ctrl+X` (or your custom shortcut), or click the menu bar icon > "Show History".
4. **Find an item:**
   - Type in the search bar to filter.
   - Use `Up`/`Down` arrow keys to navigate.
5. **Paste an item:** Press `Return` or click it. The panel closes, the text is copied to your clipboard, the previous app is re-activated, and `Cmd+V` is simulated.
6. **Pin an item:** Hover and click the pin button. Pinned items stay at the top and survive clear.
7. **Delete an item:** Hover and click the delete button.
8. **Clear history:** Click "Clear" in the footer, or menu bar > "Clear History". Pinned items are kept.
9. **Change shortcut:** Menu bar > "Change Shortcut..." > click the button and press your desired key combination.
10. **Dismiss the panel:** Press `Escape` or click outside it.

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Cmd+Ctrl+X` (default, customizable) | Toggle the clipboard history panel |
| `Up` / `Down` | Navigate items (when panel is open) |
| `Return` | Paste selected item |
| `Escape` | Dismiss the panel |

## Project Structure

```
Recopy/
├── App/
│   ├── RecopyApp.swift             App entry point
│   └── AppDelegate.swift           Menu bar, panel management, wiring
├── Models/
│   ├── ClipboardItem.swift         Data model (text, timestamp, pinned)
│   └── ShortcutConfig.swift        Shortcut persistence, display, Carbon modifiers
├── Services/
│   ├── ClipboardManager.swift      Clipboard polling, item storage, pin/delete/clear
│   ├── HotkeyManager.swift         Global hotkey registration (NSEvent + Carbon)
│   └── PasteService.swift          Paste-to-previous-app flow (Cmd+V simulation)
├── Views/
│   ├── ClipboardHistoryView.swift  Main panel: header, list, footer
│   ├── ClipboardItemRow.swift      Individual item row with hover actions
│   ├── ShortcutRecorderView.swift  Shortcut recording UI
│   ├── SearchBar.swift             Search input field
│   ├── EmptyStateView.swift        Empty state placeholder
│   ├── CircleButton.swift          Reusable circular action button
│   └── ItemCountBadge.swift        Item count badge
├── Utilities/
│   ├── FloatingPanel.swift         NSPanel subclass (floating, transparent)
│   ├── KeyboardShortcuts.swift     Arrow/Return/Escape key handling modifier
│   └── Collection+Safe.swift       Safe subscript extension
├── Assets.xcassets/
└── scripts/
    └── build-dmg.sh                DMG packaging script
RecopyTests/
├── ClipboardItemTests.swift
├── ClipboardManagerTests.swift
├── CollectionSafeTests.swift
└── ShortcutConfigTests.swift
```
