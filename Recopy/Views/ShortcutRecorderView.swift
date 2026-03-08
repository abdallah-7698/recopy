import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var currentShortcut: ShortcutConfig
    var onRecord: (ShortcutConfig) -> Void
    @State private var isRecording = false
    @State private var localMonitor: Any?

    var body: some View {
        VStack(spacing: 16) {
            Text("Keyboard Shortcut")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.85))

            Button(action: { toggleRecording() }) {
                Text(isRecording ? "Press shortcut..." : currentShortcut.displayString)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(isRecording ? .orange : .primary)
                    .frame(width: 180, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isRecording ? Color.orange.opacity(0.1) : Color.primary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(
                                        isRecording ? Color.orange.opacity(0.5) : Color.primary.opacity(0.1),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .animation(.easeOut(duration: 0.15), value: isRecording)
            }
            .buttonStyle(.plain)

            if isRecording {
                Text("Press Esc to cancel")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Button("Reset to Default") {
                stopRecording()
                let def = ShortcutConfig.default
                currentShortcut = def
                onRecord(def)
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 240)
        .onDisappear { stopRecording() }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleRecordingEvent(event)
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    private func handleRecordingEvent(_ event: NSEvent) {
        if event.keyCode == 53 { // Escape
            stopRecording()
            return
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Require at least one modifier (Cmd, Ctrl, or Opt)
        let hasModifier = flags.contains(.command)
            || flags.contains(.control)
            || flags.contains(.option)
        guard hasModifier else { return }

        let newShortcut = ShortcutConfig(keyCode: event.keyCode, modifiers: flags)
        currentShortcut = newShortcut
        onRecord(newShortcut)
        stopRecording()
    }
}
