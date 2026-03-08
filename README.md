# Recopy

A lightweight macOS menu bar app that keeps a searchable history of everything you copy to the clipboard. Select any past item to instantly paste it into your active application.

## Features

- **Clipboard Monitoring** — Automatically captures every text you copy (polled every 0.5s). Duplicates of the most recent item are ignored.
- **Global Hotkeys** — Toggle the panel with `Cmd+Ctrl+X`, navigate items globally with `Ctrl+Opt+Cmd+↑/↓`.
- **Search** — Filter your clipboard history in real time with the built-in search bar.
- **Pin Items** — Pin important items so they stay at the top and survive "Clear History".
- **Drag & Drop Reorder** — Drag items to rearrange them with smooth spring animations.
- **Instant Paste** — Click an item or press `Return` to paste it directly into the previously active app (simulates `Cmd+V`).
- **Launch at Login** — Toggle "Launch at Login" from the menu bar to start Recopy automatically on boot.
- **Menu Bar Icon** — Lives in the menu bar with options to show history, launch at login, clear history, or quit.
- **Floating Panel** — The history panel floats above all windows, appears near your mouse cursor, and hides when you click away.

## Requirements

- macOS 14+
- **Accessibility permission** — On first launch the app requests Accessibility access (System Settings → Privacy & Security → Accessibility). Required for global hotkeys and simulated paste.

## How to Use

1. **Launch the app.** It appears as a clipboard icon in the menu bar — no Dock icon.
2. **Copy text as usual** (`Cmd+C`). Each copied item is saved automatically (up to 50 unpinned items).
3. **Open the panel** with `Cmd+Ctrl+X`, or click the menu bar icon → "Show History".
4. **Find an item:**
   - Type in the search bar to filter.
   - Use `↑`/`↓` arrow keys or `Ctrl+Opt+Cmd+↑/↓` to navigate.
5. **Paste an item:** Press `Return` or click it. The panel closes, the text is copied to your clipboard, the previous app is re-activated, and `Cmd+V` is simulated.
6. **Pin an item:** Hover and click the pin button. Pinned items stay at the top and survive clear.
7. **Delete an item:** Hover and click the `✕` button.
8. **Clear history:** Click "Clear" in the footer, or menu bar → "Clear History". Pinned items are kept.
9. **Dismiss the panel:** Press `Escape` or click outside it.

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Cmd+Ctrl+X` | Toggle the clipboard history panel |
| `Ctrl+Opt+Cmd+↑` | Open panel (if closed) and navigate up |
| `Ctrl+Opt+Cmd+↓` | Open panel (if closed) and navigate down |
| `↑` / `↓` | Navigate items (when panel is focused) |
| `Return` | Paste selected item |
| `Escape` | Dismiss the panel |

## Project Structure

```
CopyHistory/
├── App/
│   ├── RecopyApp.swift             App entry point
│   └── AppDelegate.swift           Menu bar, panel management, wiring
├── Models/
│   └── ClipboardItem.swift         Data model (text, timestamp, pinned)
├── Services/
│   ├── ClipboardManager.swift      Clipboard polling, item storage, pin/delete/clear
│   ├── HotkeyManager.swift         Global hotkey registration (NSEvent + Carbon)
│   └── PasteService.swift          Paste-to-previous-app flow (Cmd+V simulation)
├── Views/
│   ├── ClipboardHistoryView.swift  Main panel: header, list, footer, drag & drop
│   ├── ClipboardItemRow.swift      Individual item row with hover actions
│   ├── SearchBar.swift             Search input field
│   ├── EmptyStateView.swift        Empty state placeholder
│   ├── CircleButton.swift          Reusable circular action button
│   └── ItemCountBadge.swift        Item count badge
├── Utilities/
│   ├── FloatingPanel.swift         NSPanel subclass (floating, transparent)
│   ├── RowDropDelegate.swift       Drag & drop reordering delegate
│   ├── KeyboardShortcuts.swift     Arrow/Return/Escape key handling modifier
│   └── Collection+Safe.swift       Safe subscript extension
└── Assets.xcassets/
```
