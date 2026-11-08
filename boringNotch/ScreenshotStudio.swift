//
//  ScreenshotStudio.swift
//  Lunotch
//
//  A separate, opt-in screenshot workflow. The music notch never changes size.
//

import AppKit
import ScreenCaptureKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class ScreenshotStudio: NSObject, NSWindowDelegate {
    static let shared = ScreenshotStudio()

    var isEditorVisible: Bool { editorWindow?.isVisible == true }

    private enum Preference {
        static let folder = "LunotchScreenshotFolderBookmark"
        static let preview = "LunotchScreenshotAutoPreview"
    }

    var autoPreview: Bool = UserDefaults.standard.object(forKey: Preference.preview) as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(autoPreview, forKey: Preference.preview)
            configureMonitoring()
        }
    }

    private var screenshotFolder: URL?
    private var folderAccessGranted = false
    private var monitor: Timer?
    private var knownScreenshots: [URL: Date] = [:]
    private var pendingScreenshots: [URL: Date] = [:]
    private var previewPanel: NSPanel?
    private var previewDismissal: Task<Void, Never>?
    private var editorWindow: NSWindow?
    private var editorState: ScreenshotEditorState?
    private var selectionPanel: ScreenshotSelectionPanel?
    private var captureInProgress = false

    func start() {
        restoreScreenshotFolder()
        configureMonitoring()
    }

    func stop() {
        monitor?.invalidate()
        monitor = nil
        selectionPanel?.close()
        selectionPanel = nil
        previewDismissal?.cancel()
        previewPanel?.close()
        editorWindow?.close()
        if folderAccessGranted {
            screenshotFolder?.stopAccessingSecurityScopedResource()
        }
        folderAccessGranted = false
    }

    /// The native capture path avoids macOS 26's unreliable screencapture region
    /// CLI while keeping the system Command-Shift-4 shortcut untouched.
    func captureSelection() {
        guard !captureInProgress, selectionPanel == nil else { return }
        captureInProgress = true
        Task { [weak self] in
            await self?.beginNativeSelection()
        }
    }

    private func beginNativeSelection() async {
        defer { captureInProgress = false }
        // Request access only after the user chooses Capture Selection. The
        // CoreGraphics preflight can lag behind ScreenCaptureKit (especially
        // after permission changes), so let the actual capture decide whether
        // access works instead of immediately showing a permission alert.
        if !CGPreflightScreenCaptureAccess() {
            _ = CGRequestScreenCaptureAccess()
        }

        do {
            let content = try await SCShareableContent.excludingDesktopWindows(
                false, onScreenWindowsOnly: true
            )
            let mouse = NSEvent.mouseLocation
            let hoveredScreen = NSScreen.screens.first(where: { $0.frame.contains(mouse) })
            let candidates = [hoveredScreen, NSScreen.main].compactMap { $0 } + NSScreen.screens
            guard let (screen, display) = candidates.compactMap({ screen -> (NSScreen, SCDisplay)? in
                guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
                      let display = content.displays.first(where: { $0.displayID == number.uint32Value }) else {
                    return nil
                }
                return (screen, display)
            }).first else {
                showError("No display is available for capture. Unlock the Mac and try again.")
                return
            }

            let filter = SCContentFilter(display: display, excludingWindows: [])
            let configuration = SCStreamConfiguration()
            configuration.width = display.width
            configuration.height = display.height
            configuration.showsCursor = false
            configuration.capturesAudio = false
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter, configuration: configuration
            )
            showSelectionPanel(image: image, on: screen)
        } catch {
            if !CGPreflightScreenCaptureAccess() {
                showCapturePermissionHelp(captureError: error)
            } else {
                showError("Could not capture this display: \(error.localizedDescription). Try again, or use Open Image or Edit Image from Clipboard.")
            }
        }
    }

    private func showSelectionPanel(image: CGImage, on screen: NSScreen) {
        let panel = ScreenshotSelectionPanel(
            contentRect: screen.frame, styleMask: [.borderless],
            backing: .buffered, defer: false
        )
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = true
        panel.backgroundColor = .black
        panel.hasShadow = false

        let view = ScreenshotSelectionView(image: image, frame: NSRect(origin: .zero, size: screen.frame.size))
        view.onCancel = { [weak self] in self?.dismissSelection() }
        view.onSelect = { [weak self, weak view] rect in
            guard let view else { return }
            self?.dismissSelection()
            let xScale = CGFloat(image.width) / view.bounds.width
            let yScale = CGFloat(image.height) / view.bounds.height
            let pixelRect = CGRect(
                x: rect.minX * xScale,
                y: (view.bounds.maxY - rect.maxY) * yScale,
                width: rect.width * xScale,
                height: rect.height * yScale
            ).integral.intersection(CGRect(x: 0, y: 0, width: image.width, height: image.height))
            guard pixelRect.width > 0, pixelRect.height > 0,
                  let crop = image.cropping(to: pixelRect) else { return }
            self?.showPreview(NSImage(cgImage: crop, size: NSSize(width: pixelRect.width, height: pixelRect.height)))
        }
        panel.contentView = view
        selectionPanel = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeFirstResponder(view)
    }

    private func dismissSelection() {
        selectionPanel?.close()
        selectionPanel = nil
    }

    private func showCapturePermissionHelp(captureError: Error) {
        let alert = NSAlert()
        alert.messageText = "Lunotch can't capture the screen yet"
        alert.informativeText = "macOS rejected this capture (\(captureError.localizedDescription)). If Lunotch is already allowed in Screen & System Audio Recording, its permission may belong to an older app build. Quit Lunotch, then run this in Terminal to reset only its screen-capture permission:\n\ntccutil reset ScreenCapture dev.ryandeniega.lunotch\n\nReopen this signed Lunotch build and allow screen recording again. You can still use Edit Image from Clipboard or Open Image."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open System Settings")
        if alert.runModal() == .alertSecondButtonReturn,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    func chooseScreenshotFolder() {
        let panel = NSOpenPanel()
        panel.message = "Choose the folder where macOS saves screenshots. Lunotch watches only this folder."
        panel.prompt = "Watch Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = screenshotFolder ?? FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            let hasAccess = url.startAccessingSecurityScopedResource()
            guard hasAccess else {
                showError("macOS did not grant access to this folder. Please choose it again.")
                return
            }
            if folderAccessGranted { screenshotFolder?.stopAccessingSecurityScopedResource() }
            screenshotFolder = url
            folderAccessGranted = true
            UserDefaults.standard.set(bookmark, forKey: Preference.folder)
            configureMonitoring()
        } catch {
            showError("Could not remember the screenshot folder: \(error.localizedDescription)")
        }
    }

    private func restoreScreenshotFolder() {
        guard let data = UserDefaults.standard.data(forKey: Preference.folder) else { return }
        do {
            var stale = false
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale)
            guard url.startAccessingSecurityScopedResource() else { return }
            screenshotFolder = url
            folderAccessGranted = true
            if stale, let renewed = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
                UserDefaults.standard.set(renewed, forKey: Preference.folder)
            }
        } catch {
            NSLog("Lunotch Screenshot Studio: folder bookmark could not be restored: %@", error.localizedDescription)
        }
    }

    private func configureMonitoring() {
        monitor?.invalidate()
        monitor = nil
        pendingScreenshots.removeAll()
        guard autoPreview, folderAccessGranted, let folder = screenshotFolder else { return }
        // Establish a baseline so enabling monitoring never opens old files.
        knownScreenshots = screenshotDates(in: folder)
        monitor = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.pollScreenshotFolder() }
        }
    }

    private func screenshotDates(in folder: URL) -> [URL: Date] {
        let keys: Set<URLResourceKey> = [.contentModificationDateKey, .isRegularFileKey]
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: Array(keys), options: [.skipsHiddenFiles]
        ) else { return [:] }
        var dates: [URL: Date] = [:]
        for url in files {
            let filename = url.deletingPathExtension().lastPathComponent.lowercased()
            guard filename.hasPrefix("screenshot ") || filename.hasPrefix("screen shot ") ||
                    filename.hasPrefix("screenshot-") || filename.hasPrefix("screen shot-") else { continue }
            guard ["png", "jpg", "jpeg", "heic"].contains(url.pathExtension.lowercased()),
                  let values = try? url.resourceValues(forKeys: keys),
                  values.isRegularFile == true,
                  let date = values.contentModificationDate else { continue }
            dates[url] = date
        }
        return dates
    }

    private func pollScreenshotFolder() {
        guard let folder = screenshotFolder else { return }
        let current = screenshotDates(in: folder)
        for (url, date) in current where knownScreenshots[url] != date {
            // Wait for one unchanged poll before reading a possibly in-flight PNG.
            pendingScreenshots[url] = date
        }
        for (url, date) in pendingScreenshots {
            guard let unchanged = current[url], unchanged == date else {
                pendingScreenshots.removeValue(forKey: url)
                continue
            }
            if knownScreenshots[url] == date {
                pendingScreenshots.removeValue(forKey: url)
                if let image = NSImage(contentsOf: url) {
                    showPreview(image)
                }
            }
        }
        knownScreenshots = current
    }

    func openImage() {
        let panel = NSOpenPanel()
        panel.message = "Select a screenshot or image to edit."
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let image = NSImage(contentsOf: url) else {
            showError("Could not open this image.")
            return
        }
        showEditor(image)
    }

    func editClipboard() {
        let board = NSPasteboard.general
        if let image = NSImage(pasteboard: board) {
            showEditor(image)
        } else if let data = board.data(forType: .png), let image = NSImage(data: data) {
            showEditor(image)
        } else {
            showError("No image found on the clipboard. Copy an image or use Open Image.")
        }
    }

    private func showPreview(_ image: NSImage) {
        previewDismissal?.cancel()
        previewPanel?.close()
        let size = NSSize(width: 340, height: 146)
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.contentView = NSHostingView(rootView: ScreenshotPreview(
            image: image,
            edit: { [weak self] in self?.hidePreview(); self?.showEditor(image) },
            copy: { [weak self] in
                if let png = ScreenshotEditorState(image: image).renderPNG() {
                    self?.copyPNG(png)
                }
                self?.hidePreview()
            },
            dismiss: { [weak self] in self?.hidePreview() }
        ))
        let screen = NSScreen.main ?? NSScreen.screens.first
        if let frame = screen?.visibleFrame {
            let preferredX = frame.midX + 210
            let x = min(max(preferredX, frame.minX + 12), frame.maxX - size.width - 12)
            panel.setFrameOrigin(NSPoint(x: x, y: frame.maxY - size.height - 18))
        } else {
            panel.center()
        }
        previewPanel = panel
        panel.orderFrontRegardless()
        previewDismissal = Task { [weak self] in
            try? await Task.sleep(for: .seconds(14))
            guard !Task.isCancelled else { return }
            self?.hidePreview()
        }
    }

    private func hidePreview() {
        previewDismissal?.cancel()
        previewDismissal = nil
        previewPanel?.close()
        previewPanel = nil
    }

    private func showEditor(_ image: NSImage) {
        hidePreview()
        editorWindow?.close()
        let state = ScreenshotEditorState(image: image)
        editorState = state
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 980, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        window.title = "Lunotch Screenshot Studio"
        window.minSize = NSSize(width: 660, height: 490)
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.managed, .fullScreenAuxiliary]
        window.delegate = self
        window.contentView = NSHostingView(rootView: ScreenshotEditorView(
            state: state,
            copy: { [weak self] in
                guard let data = state.renderPNG() else { return false }
                self?.copyPNG(data)
                return true
            },
            save: { [weak self] in self?.saveEditedImage(from: state) ?? false }
        ))
        editorWindow = window
        NSApp.setActivationPolicy(.regular)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func copyPNG(_ data: Data) {
        let board = NSPasteboard.general
        board.clearContents()
        board.setData(data, forType: .png)
    }

    private func saveEditedImage(from state: ScreenshotEditorState) -> Bool {
        guard let png = state.renderPNG() else {
            showError("Could not render the edited image.")
            return false
        }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "Lunotch-Edited-\(Date().formatted(.dateTime.year().month().day().hour().minute())).png"
        guard panel.runModal() == .OK, let url = panel.url else { return false }
        do {
            try png.write(to: url, options: .atomic)
            return true
        } catch {
            showError("Could not save the image: \(error.localizedDescription)")
            return false
        }
    }

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == editorWindow {
            editorWindow = nil
            editorState = nil
            if SettingsWindowController.shared.window?.isVisible != true
                && !WorkMode.shared.isVisible {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Screenshot Studio"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

/// An ephemeral full-screen view over the selected display, with the image
/// captured *before* the overlay appears. No extra screen reads occur while
/// dragging, and nothing is written to disk unless the user later exports.
@MainActor
private final class ScreenshotSelectionPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
private final class ScreenshotSelectionView: NSView {
    var onSelect: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private let screenshot: NSImage
    private var dragStart: CGPoint?
    private var dragEnd: CGPoint?

    init(image: CGImage, frame: NSRect) {
        screenshot = NSImage(cgImage: image, size: frame.size)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError("Use init(image:frame:)") }
    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.invalidateCursorRects(for: self)
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .crosshair)
    }

    private var selectedRect: CGRect? {
        guard let dragStart, let dragEnd else { return nil }
        return CGRect(
            x: min(dragStart.x, dragEnd.x), y: min(dragStart.y, dragEnd.y),
            width: abs(dragStart.x - dragEnd.x), height: abs(dragStart.y - dragEnd.y)
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        screenshot.draw(in: bounds)
        NSColor.black.withAlphaComponent(0.28).setFill()
        bounds.fill()

        if let selection = selectedRect, !selection.isEmpty {
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(rect: selection).addClip()
            screenshot.draw(in: bounds)
            NSGraphicsContext.restoreGraphicsState()
            NSColor.white.setStroke()
            let border = NSBezierPath(rect: selection)
            border.lineWidth = 1.5
            border.stroke()
        }

        let hint = "Drag to select  ·  Esc to cancel"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: NSColor.white,
            .shadow: {
                let shadow = NSShadow()
                shadow.shadowColor = .black
                shadow.shadowBlurRadius = 5
                return shadow
            }()
        ]
        let hintSize = (hint as NSString).size(withAttributes: attrs)
        (hint as NSString).draw(
            at: CGPoint(x: bounds.midX - hintSize.width / 2, y: bounds.maxY - 65),
            withAttributes: attrs
        )
    }

    private func location(for event: NSEvent) -> CGPoint {
        let point = convert(event.locationInWindow, from: nil)
        return CGPoint(
            x: max(bounds.minX, min(bounds.maxX, point.x)),
            y: max(bounds.minY, min(bounds.maxY, point.y))
        )
    }

    override func mouseDown(with event: NSEvent) {
        dragStart = location(for: event)
        dragEnd = dragStart
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        dragEnd = location(for: event)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        dragEnd = location(for: event)
        guard let rect = selectedRect, rect.width >= 4, rect.height >= 4 else {
            dragStart = nil
            dragEnd = nil
            needsDisplay = true
            return
        }
        onSelect?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onCancel?()
        } else {
            super.keyDown(with: event)
        }
    }
}

private struct ScreenshotPreview: View {
    let image: NSImage
    let edit: () -> Void
    let copy: () -> Void
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 122, height: 102)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 11) {
                Text("Screenshot ready")
                    .font(.system(size: 13, weight: .semibold))
                Button(action: edit) {
                    Label("Edit screenshot", systemImage: "pencil.tip.crop.circle")
                }
                Button(action: copy) {
                    Label("Copy image", systemImage: "document.on.document")
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 12))
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                Button(action: dismiss) { Image(systemName: "xmark.circle.fill") }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(14)
        .frame(width: 340, height: 146)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.14)))
    }
}

private enum ScreenshotTool: String, CaseIterable, Identifiable {
    case crop = "Crop"
    case pen = "Pen"
    case highlighter = "Highlight"
    case arrow = "Arrow"
    case rectangle = "Rectangle"
    case ellipse = "Ellipse"
    case text = "Text"
    case redact = "Redact"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .crop: "crop.rotate"
        case .pen: "pencil.tip"
        case .highlighter: "highlighter"
        case .arrow: "arrow.up.right"
        case .rectangle: "rectangle"
        case .ellipse: "circle"
        case .text: "textformat"
        case .redact: "rectangle.fill"
        }
    }
}

private struct ScreenshotMark {
    let tool: ScreenshotTool
    let points: [CGPoint]      // Image-relative coordinates in [0, 1].
    let color: NSColor
    let text: String
}

@MainActor
private final class ScreenshotEditorState: ObservableObject {
    @Published var image: NSImage
    @Published var marks: [ScreenshotMark] = []
    @Published var tool: ScreenshotTool = .crop
    @Published var ink: Color = .cyan
    @Published var textToAdd = "Note"
    @Published var dragPoints: [CGPoint] = []

    private var undoStack: [(NSImage, [ScreenshotMark])] = []
    private var redoStack: [(NSImage, [ScreenshotMark])] = []

    init(image: NSImage) { self.image = image }

    var imageSize: CGSize {
        guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return image.size }
        return CGSize(width: cg.width, height: cg.height)
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func beginDrag(_ location: CGPoint, size: CGSize) {
        dragPoints = [normalize(location, size: size)]
    }

    func updateDrag(_ location: CGPoint, size: CGSize) {
        guard !dragPoints.isEmpty else { return }
        let point = normalize(location, size: size)
        if tool == .pen || tool == .highlighter {
            dragPoints.append(point)
        } else {
            dragPoints = [dragPoints[0], point]
        }
    }

    func endDrag() {
        guard let start = dragPoints.first else { return }
        defer { dragPoints.removeAll() }
        let end = dragPoints.last ?? start
        if tool == .crop {
            crop(from: start, to: end)
            return
        }
        if tool != .text, tool != .pen, tool != .highlighter,
           hypot(end.x - start.x, end.y - start.y) < 0.004 { return }
        if tool == .text && textToAdd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
        pushUndo()
        marks.append(ScreenshotMark(
            tool: tool, points: dragPoints, color: NSColor(ink),
            text: tool == .text ? textToAdd : ""
        ))
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append((image, marks))
        if redoStack.count > 25 { redoStack.removeFirst() }
        image = previous.0
        marks = previous.1
        dragPoints = []
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append((image, marks))
        if undoStack.count > 25 { undoStack.removeFirst() }
        image = next.0
        marks = next.1
        dragPoints = []
    }

    func clearMarks() {
        guard !marks.isEmpty else { return }
        pushUndo()
        marks = []
    }

    private func pushUndo() {
        undoStack.append((image, marks))
        if undoStack.count > 25 { undoStack.removeFirst() }
        redoStack.removeAll()
    }

    private func normalize(_ point: CGPoint, size: CGSize) -> CGPoint {
        CGPoint(
            x: min(1, max(0, point.x / max(1, size.width))),
            y: min(1, max(0, point.y / max(1, size.height)))
        )
    }

    private func crop(from start: CGPoint, to end: CGPoint) {
        let size = imageSize
        let left = min(start.x, end.x)
        let top = min(start.y, end.y)
        let width = abs(start.x - end.x)
        let height = abs(start.y - end.y)
        guard width > 0.01, height > 0.01,
              let png = renderPNG(),
              let cg = NSBitmapImageRep(data: png)?.cgImage else { return }
        let pixelRect = CGRect(
            x: floor(left * size.width), y: floor(top * size.height),
            width: max(1, floor(width * size.width)),
            height: max(1, floor(height * size.height))
        ).intersection(CGRect(origin: .zero, size: size)).integral
        guard let cropped = cg.cropping(to: pixelRect), pixelRect.width > 0, pixelRect.height > 0 else { return }
        pushUndo()
        image = NSImage(cgImage: cropped, size: NSSize(width: cropped.width, height: cropped.height))
        marks = []
    }

    /// Flatten annotations at source pixel resolution, for both clipboard and PNG export.
    func renderPNG() -> Data? {
        let size = imageSize
        let w = Int(size.width)
        let h = Int(size.height)
        guard w > 0, h > 0,
              let bitmap = NSBitmapImageRep(
                bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                isPlanar: false, colorSpaceName: .deviceRGB,
                bytesPerRow: 0, bitsPerPixel: 0
              ),
              let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        image.draw(in: CGRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1)
        for mark in marks { draw(mark, in: size) }
        context.flushGraphics()
        NSGraphicsContext.restoreGraphicsState()
        return bitmap.representation(using: .png, properties: [:])
    }

    private func draw(_ mark: ScreenshotMark, in size: CGSize) {
        guard let first = mark.points.first else { return }
        let toPixel: (CGPoint) -> CGPoint = {
            CGPoint(x: $0.x * size.width, y: (1 - $0.y) * size.height)
        }
        let start = toPixel(first)
        let end = toPixel(mark.points.last ?? first)
        let bounds = CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
                            width: abs(start.x - end.x), height: abs(start.y - end.y))
        let baseWidth = max(2, min(size.width, size.height) / 380)
        if mark.tool == .text {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: max(18, size.width / 48), weight: .semibold),
                .foregroundColor: mark.color
            ]
            (mark.text as NSString).draw(at: CGPoint(x: start.x, y: start.y - max(18, size.width / 48)), withAttributes: attributes)
            return
        }
        if mark.tool == .redact {
            NSColor.black.setFill()
            NSBezierPath(rect: bounds).fill()
            return
        }
        (mark.tool == .highlighter ? mark.color.withAlphaComponent(0.36) : mark.color).setStroke()
        let path = NSBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = mark.tool == .highlighter ? baseWidth * 8 : baseWidth
        switch mark.tool {
        case .pen, .highlighter:
            path.move(to: start)
            for point in mark.points.dropFirst() { path.line(to: toPixel(point)) }
        case .arrow:
            path.move(to: start)
            path.line(to: end)
            let angle = atan2(end.y - start.y, end.x - start.x)
            let length = baseWidth * 9
            for offset in [-CGFloat.pi / 6, CGFloat.pi / 6] {
                path.move(to: end)
                path.line(to: CGPoint(x: end.x - length * cos(angle + offset),
                                      y: end.y - length * sin(angle + offset)))
            }
        case .rectangle:
            path.appendRect(bounds)
        case .ellipse:
            path.appendOval(in: bounds)
        case .crop, .text, .redact:
            break
        }
        path.stroke()
    }
}

private struct ScreenshotEditorView: View {
    @ObservedObject var state: ScreenshotEditorState
    let copy: () -> Bool
    let save: () -> Bool
    @State private var feedback = "Drag on the image to apply the selected tool."
    @State private var zoom: Double = 1

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(ScreenshotTool.allCases) { tool in
                        Button {
                            state.tool = tool
                            state.dragPoints = []
                        } label: {
                            Label(tool.rawValue, systemImage: tool.symbol)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 7)
                                .foregroundStyle(state.tool == tool ? Color.white : Color.primary)
                                .background(
                                    state.tool == tool ? Color.accentColor : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 7)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 52)

            HStack(spacing: 14) {
                if state.tool == .text {
                    TextField("Text", text: $state.textToAdd)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 180)
                }
                if state.tool != .crop && state.tool != .redact {
                    ColorPicker("Color", selection: $state.ink, supportsOpacity: false)
                        .frame(width: 105)
                }
                Spacer()
                Button("Undo", systemImage: "arrow.uturn.backward") { state.undo() }
                    .disabled(!state.canUndo)
                    .keyboardShortcut("z", modifiers: .command)
                Button("Redo", systemImage: "arrow.uturn.forward") { state.redo() }
                    .disabled(!state.canRedo)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                Button("Clear Marks") { state.clearMarks() }
                    .disabled(state.marks.isEmpty)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 10)

            GeometryReader { available in
                let size = state.imageSize
                let scale = min(
                    max(1, available.size.width - 34) / max(1, size.width),
                    max(1, available.size.height - 34) / max(1, size.height)
                )
                let imageFrame = CGSize(
                    width: size.width * scale * zoom,
                    height: size.height * scale * zoom
                )
                ScrollView([.horizontal, .vertical]) {
                    ScreenshotCanvas(state: state)
                        .frame(width: imageFrame.width, height: imageFrame.height)
                        .background(.black)
                        .shadow(color: .black.opacity(0.28), radius: 14, y: 7)
                        .frame(minWidth: available.size.width, minHeight: available.size.height)
                }
                .frame(width: available.size.width, height: available.size.height)
            }
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.75))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 12) {
                Text("\(Int(state.imageSize.width)) × \(Int(state.imageSize.height)) px")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                Button("Fit") { zoom = 1 }
                    .help("Fit image inside the editor")
                Slider(value: $zoom, in: 0.5...4)
                    .frame(width: 104)
                    .accessibilityLabel("Image zoom relative to fit")
                Text("\(Int(zoom * 100))%")
                    .font(.system(size: 11, design: .monospaced))
                    .frame(width: 40, alignment: .trailing)
                Text(feedback)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Button("Copy PNG", systemImage: "document.on.document") {
                    feedback = copy() ? "Copied PNG to clipboard." : "Could not copy image."
                }
                Button("Save PNG…", systemImage: "square.and.arrow.down") {
                    feedback = save() ? "Saved PNG." : "Save cancelled or failed."
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(14)
        }
        .frame(minWidth: 660, minHeight: 490)
    }
}

private struct ScreenshotCanvas: View {
    @ObservedObject var state: ScreenshotEditorState

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(nsImage: state.image)
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Canvas { context, size in
                    for mark in state.marks {
                        draw(mark, in: &context, size: size)
                    }
                    if !state.dragPoints.isEmpty {
                        draw(
                            ScreenshotMark(
                                tool: state.tool, points: state.dragPoints,
                                color: NSColor(state.ink), text: state.textToAdd
                            ),
                            in: &context, size: size
                        )
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if state.dragPoints.isEmpty {
                                state.beginDrag(value.startLocation, size: geometry.size)
                            }
                            state.updateDrag(value.location, size: geometry.size)
                        }
                        .onEnded { _ in state.endDrag() }
                )
            }
        }
    }

    private func draw(_ mark: ScreenshotMark, in context: inout GraphicsContext, size: CGSize) {
        guard let first = mark.points.first else { return }
        let toView: (CGPoint) -> CGPoint = {
            CGPoint(x: $0.x * size.width, y: $0.y * size.height)
        }
        let start = toView(first)
        let end = toView(mark.points.last ?? first)
        let rect = CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
                          width: abs(start.x - end.x), height: abs(start.y - end.y))
        if mark.tool == .text {
            context.draw(
                Text(mark.text).font(.system(size: max(12, size.width / 48), weight: .semibold))
                    .foregroundColor(Color(nsColor: mark.color)),
                at: start, anchor: .topLeading
            )
            return
        }
        if mark.tool == .redact {
            context.fill(Path(rect), with: .color(.black))
            return
        }
        var path = Path()
        switch mark.tool {
        case .pen, .highlighter:
            path.move(to: start)
            for p in mark.points.dropFirst() { path.addLine(to: toView(p)) }
        case .arrow:
            path.move(to: start)
            path.addLine(to: end)
            let angle = atan2(end.y - start.y, end.x - start.x)
            let length: CGFloat = 12
            for offset in [-CGFloat.pi / 6, CGFloat.pi / 6] {
                path.move(to: end)
                path.addLine(to: CGPoint(x: end.x - length * cos(angle + offset),
                                         y: end.y - length * sin(angle + offset)))
            }
        case .rectangle: path.addRect(rect)
        case .ellipse: path.addEllipse(in: rect)
        case .crop:
            path.addRect(rect)
            context.fill(path, with: .color(.white.opacity(0.13)))
            context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            return
        case .text, .redact: break
        }
        context.stroke(
            path,
            with: .color(Color(nsColor: mark.color).opacity(mark.tool == .highlighter ? 0.36 : 1)),
            style: StrokeStyle(lineWidth: mark.tool == .highlighter ? 13 : 2.5,
                               lineCap: .round, lineJoin: .round)
        )
    }
}
