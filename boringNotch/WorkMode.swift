//
//  WorkMode.swift
//  Lunotch
//
//  Optional productivity tools in their own window, leaving the music notch small.
//

import AppKit
import Combine
import Darwin
import SwiftUI

struct WorkModeBrowser: Identifiable, Hashable {
    let id: pid_t
    let name: String
    let bundleID: String
}

@MainActor
final class WorkMode: NSObject, ObservableObject, NSWindowDelegate {
    static let shared = WorkMode()

    @Published private(set) var focusMinutes = 25
    @Published private(set) var remainingSeconds = 25 * 60
    @Published private(set) var focusRunning = false
    @Published private(set) var focusFinished = false
    @Published private(set) var memoryUsedGB: Double?
    @Published private(set) var browsers: [WorkModeBrowser] = []
    @Published var selectedBrowserPIDs: Set<pid_t> = []
    @Published var researchTitle = ""
    @Published var researchURL = ""
    @Published var researchNotes = ""
    @Published private(set) var researchStatus = ""
    @Published private(set) var browserStatus = ""

    let memoryTotalGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824

    private var window: NSWindow?
    private var focusTimer: Timer?
    private var focusDeadline: Date?

    var isVisible: Bool { window?.isVisible == true }

    var focusProgress: Double {
        1 - Double(remainingSeconds) / Double(max(1, focusMinutes * 60))
    }

    func show() {
        if let window {
            NSApp.setActivationPolicy(.regular)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            refreshSystem()
            return
        }

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 790, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "Lunotch Work Mode"
        newWindow.minSize = NSSize(width: 680, height: 560)
        newWindow.isReleasedWhenClosed = false
        newWindow.collectionBehavior = [.managed, .fullScreenAuxiliary]
        newWindow.delegate = self
        newWindow.contentView = NSHostingView(rootView: WorkModeView(mode: self))
        window = newWindow
        NSApp.setActivationPolicy(.regular)
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        refreshSystem()
    }

    func windowWillClose(_ notification: Notification) {
        guard let closing = notification.object as? NSWindow, closing == window else { return }
        window = nil
        if !ScreenshotStudio.shared.isEditorVisible
            && SettingsWindowController.shared.window?.isVisible != true {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    func chooseFocusDuration(_ minutes: Int) {
        guard [15, 25, 45, 60].contains(minutes) else { return }
        stopTicking()
        focusMinutes = minutes
        remainingSeconds = minutes * 60
        focusFinished = false
    }

    func startOrPauseFocus() {
        if focusRunning {
            tickFocus()
            stopTicking()
            return
        }
        if remainingSeconds == 0 {
            remainingSeconds = focusMinutes * 60
        }
        focusFinished = false
        focusRunning = true
        focusDeadline = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        focusTimer?.invalidate()
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tickFocus() }
        }
    }

    func resetFocus() {
        stopTicking()
        remainingSeconds = focusMinutes * 60
        focusFinished = false
    }

    private func tickFocus() {
        guard focusRunning, let focusDeadline else { return }
        remainingSeconds = max(0, Int(ceil(focusDeadline.timeIntervalSinceNow)))
        guard remainingSeconds == 0 else { return }
        stopTicking()
        focusFinished = true
        NSSound.beep()
    }

    private func stopTicking() {
        focusTimer?.invalidate()
        focusTimer = nil
        focusDeadline = nil
        focusRunning = false
    }

    func refreshSystem() {
        refreshMemory()
        refreshBrowsers()
    }

    func refreshMemory() {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride
        )
        let status = withUnsafeMutablePointer(to: &stats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        var pageSize: vm_size_t = 0
        guard status == KERN_SUCCESS,
              host_page_size(mach_host_self(), &pageSize) == KERN_SUCCESS,
              pageSize > 0 else {
            memoryUsedGB = nil
            return
        }
        // Approximation of active + wired + compressed RAM, not memory pressure.
        let pages = Double(stats.active_count) + Double(stats.wire_count)
            + Double(stats.compressor_page_count)
        memoryUsedGB = min(memoryTotalGB, pages * Double(pageSize) / 1_073_741_824)
    }

    func refreshBrowsers() {
        let knownIDs: Set<String> = [
            "com.apple.Safari", "com.apple.SafariTechnologyPreview",
            "com.google.Chrome", "com.google.Chrome.canary",
            "com.brave.Browser", "org.mozilla.firefox", "org.mozilla.firefoxdeveloperedition",
            "com.microsoft.edgemac", "company.thebrowser.Browser",
            "com.kagi.kagimacOS", "com.operasoftware.Opera",
            "com.vivaldi.Vivaldi", "com.browser.Dia"
        ]
        browsers = NSWorkspace.shared.runningApplications.compactMap { app in
            guard !app.isTerminated,
                  let id = app.bundleIdentifier,
                  knownIDs.contains(id) else { return nil }
            return WorkModeBrowser(
                id: app.processIdentifier,
                name: app.localizedName ?? id,
                bundleID: id
            )
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        selectedBrowserPIDs.formIntersection(Set(browsers.map(\.id)))
    }

    func closeSelectedBrowsers() {
        // Revalidate selected PIDs and bundle IDs before requesting termination.
        let approved = NSWorkspace.shared.runningApplications.filter { app in
            selectedBrowserPIDs.contains(app.processIdentifier)
                && browsers.contains(where: {
                    $0.id == app.processIdentifier && $0.bundleID == app.bundleIdentifier
                })
        }
        guard !approved.isEmpty else {
            browserStatus = "Select a running browser first."
            refreshBrowsers()
            return
        }

        let alert = NSAlert()
        alert.messageText = "Close \(approved.count) selected browser\(approved.count == 1 ? "" : "s")?"
        alert.informativeText = "Unsaved work and active downloads may be interrupted. macOS or the browser may ask you to save your tabs."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Close Selected")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        // A browser may exit and another instance may launch while the modal is open.
        // Only request termination of a currently running, still-selected match.
        let current = NSWorkspace.shared.runningApplications
        let stillApproved = current.filter { app in
            !app.isTerminated && selectedBrowserPIDs.contains(app.processIdentifier)
                && approved.contains(where: {
                    $0.processIdentifier == app.processIdentifier
                        && $0.bundleIdentifier == app.bundleIdentifier
                })
        }
        let requests = stillApproved.filter { $0.terminate() }.count
        browserStatus = "Sent close request to \(requests) browser\(requests == 1 ? "" : "s")."
        refreshBrowsers()
    }

    func importURLFromClipboard() {
        guard let text = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              Self.isWebURL(text) else {
            researchStatus = "Clipboard does not contain a web link."
            return
        }
        researchURL = text
        researchStatus = "Link imported from clipboard."
    }

    private static func isWebURL(_ text: String) -> Bool {
        guard !text.contains(where: \.isWhitespace),
              let components = URLComponents(string: text),
              ["http", "https"].contains(components.scheme?.lowercased() ?? ""),
              let host = components.host, !host.isEmpty else { return false }
        return true
    }

    func copySourceReference() {
        let title = researchTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = researchURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty || !source.isEmpty else {
            researchStatus = "Enter a title or source link first."
            return
        }
        guard source.isEmpty || Self.isWebURL(source) else {
            researchStatus = "Enter a valid http:// or https:// source link."
            return
        }
        let reference = [title, source].filter { !$0.isEmpty }.joined(separator: " — ")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(reference, forType: .string)
        researchStatus = "Source reference copied."
    }

    private var researchFileURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("Lunotch", isDirectory: true)
            .appendingPathComponent("ResearchNotes.md")
    }

    func saveResearch() {
        let title = researchTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = researchURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let notes = researchNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !notes.isEmpty else {
            researchStatus = "Add a title and some notes before saving."
            return
        }
        guard source.isEmpty || Self.isWebURL(source) else {
            researchStatus = "Enter a valid http:// or https:// source link."
            return
        }

        // Keep Markdown headings and single-line URLs predictable.
        let safeTitle = title.replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        let safeSource = source.replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        let date = ISO8601DateFormatter().string(from: Date())
        let entry = "\n## \(safeTitle)\n\n- Saved: \(date)\n"
            + (safeSource.isEmpty ? "" : "- Source: \(safeSource)\n")
            + "\n\(notes)\n"

        do {
            let target = researchFileURL
            try FileManager.default.createDirectory(
                at: target.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            let data = Data(entry.utf8)
            if FileManager.default.fileExists(atPath: target.path) {
                let file = try FileHandle(forWritingTo: target)
                defer { try? file.close() }
                try file.seekToEnd()
                try file.write(contentsOf: data)
            } else {
                try Data(("# Lunotch Research Notes\n" + entry).utf8)
                    .write(to: target, options: .atomic)
            }
            researchStatus = "Saved to ResearchNotes.md."
            researchNotes = ""
        } catch {
            researchStatus = "Could not save notes: \(error.localizedDescription)"
        }
    }

    func revealResearchFile() {
        let target = researchFileURL
        guard FileManager.default.fileExists(atPath: target.path) else {
            researchStatus = "Save your first note to create the file."
            return
        }
        NSWorkspace.shared.activateFileViewerSelecting([target])
    }
}

private struct WorkModeCard<Content: View>: View {
    let title: String
    let subtitle: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.cyan)
                    .frame(width: 34, height: 34)
                    .background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08))
        }
    }
}

private struct WorkModeView: View {
    @ObservedObject var mode: WorkMode
    private let refreshTimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

    private var focusClock: String {
        String(format: "%02d:%02d", mode.remainingSeconds / 60, mode.remainingSeconds % 60)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Label("WORKSPACE", systemImage: "moon.stars.fill")
                        .font(.caption.weight(.bold)).tracking(2)
                        .foregroundStyle(.cyan)
                    Text("Work Mode").font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("A quiet place for focus, system awareness and research.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.bottom, 3)

                HStack(alignment: .top, spacing: 16) {
                    focusCard
                    memoryCard
                }
                browserCard
                researchCard
            }
            .padding(24)
        }
        .frame(minWidth: 680, minHeight: 540)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.dark)
        .onAppear { mode.refreshSystem() }
        .onReceive(refreshTimer) { _ in
            if mode.isVisible { mode.refreshMemory() }
        }
    }

    private var focusCard: some View {
        WorkModeCard(
            title: "Focus Session",
            subtitle: "A timer that keeps counting when this window is hidden.",
            symbol: "timer"
        ) {
            Text(focusClock)
                .font(.system(size: 42, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            ProgressView(value: mode.focusProgress)
                .tint(.cyan)
            HStack(spacing: 5) {
                ForEach([15, 25, 45, 60], id: \.self) { minutes in
                    Button("\(minutes)m") { mode.chooseFocusDuration(minutes) }
                        .buttonStyle(.bordered)
                        .tint(mode.focusMinutes == minutes ? .cyan : .gray)
                        .controlSize(.small)
                }
            }
            HStack {
                Button {
                    mode.startOrPauseFocus()
                } label: {
                    Label(mode.focusRunning ? "Pause" : "Start", systemImage: mode.focusRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                Button("Reset") { mode.resetFocus() }
                    .buttonStyle(.bordered)
            }
            if mode.focusFinished {
                Label("Session complete.", systemImage: "checkmark.circle.fill")
                    .font(.caption).foregroundStyle(.green)
            }
        }
    }

    private var memoryCard: some View {
        WorkModeCard(
            title: "Memory Overview",
            subtitle: "Approximate active, wired and compressed RAM.",
            symbol: "memorychip"
        ) {
            if let used = mode.memoryUsedGB {
                Text(String(format: "%.1f GB", used))
                    .font(.system(size: 33, weight: .medium, design: .rounded))
                    .monospacedDigit()
                Text(String(format: "of %.1f GB physical memory", mode.memoryTotalGB))
                    .font(.caption).foregroundStyle(.secondary)
                ProgressView(value: used, total: max(1, mode.memoryTotalGB))
                    .tint(.teal)
            } else {
                Text("Memory data unavailable").foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text("This view does not clean or reserve memory. macOS manages RAM automatically.")
                .font(.caption).foregroundStyle(.secondary)
            Button("Refresh") { mode.refreshSystem() }
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
    }

    private var browserCard: some View {
        WorkModeCard(
            title: "Browser Break",
            subtitle: "Choose browsers to close when you want fewer distractions.",
            symbol: "macwindow.on.rectangle"
        ) {
            if mode.browsers.isEmpty {
                Text("No supported browsers are currently running.")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(mode.browsers) { browser in
                    Toggle(isOn: Binding(
                        get: { mode.selectedBrowserPIDs.contains(browser.id) },
                        set: { selected in
                            if selected { mode.selectedBrowserPIDs.insert(browser.id) }
                            else { mode.selectedBrowserPIDs.remove(browser.id) }
                        }
                    )) {
                        Text(browser.name)
                        Text("PID \(browser.id)")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    .toggleStyle(.checkbox)
                }
            }
            HStack {
                Button("Refresh browsers") { mode.refreshBrowsers() }
                    .buttonStyle(.bordered)
                Button("Close selected…") { mode.closeSelectedBrowsers() }
                    .buttonStyle(.borderedProminent)
                    .disabled(mode.selectedBrowserPIDs.isEmpty)
            }
            if !mode.browserStatus.isEmpty {
                Text(mode.browserStatus).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var researchCard: some View {
        WorkModeCard(
            title: "Research Notes",
            subtitle: "Capture sources and ideas into one local Markdown file.",
            symbol: "books.vertical"
        ) {
            TextField("Paper, article or idea title", text: $mode.researchTitle)
                .textFieldStyle(.roundedBorder)
            HStack(spacing: 8) {
                TextField("Source URL (optional)", text: $mode.researchURL)
                    .textFieldStyle(.roundedBorder)
                Button {
                    mode.importURLFromClipboard()
                } label: {
                    Image(systemName: "link.badge.plus")
                }
                .help("Paste a link from clipboard")
                .buttonStyle(.bordered)
            }
            TextEditor(text: $mode.researchNotes)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(7)
                .frame(height: 112)
                .background(.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 9))
                .overlay(alignment: .topLeading) {
                    if mode.researchNotes.isEmpty {
                        Text("Key findings, citations, next experiments…")
                            .font(.subheadline).foregroundStyle(.tertiary)
                            .padding(.leading, 12).padding(.top, 15)
                            .allowsHitTesting(false)
                    }
                }
            HStack(spacing: 9) {
                Button("Save note") { mode.saveResearch() }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                Button("Copy source") { mode.copySourceReference() }
                    .buttonStyle(.bordered)
                Button("Show notes in Finder") { mode.revealResearchFile() }
                    .buttonStyle(.bordered)
            }
            if !mode.researchStatus.isEmpty {
                Text(mode.researchStatus)
                    .font(.caption).foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
    }
}
