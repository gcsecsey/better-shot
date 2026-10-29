import AppKit

/// Bridges BetterShot's preview-stack call sites onto BetterShot's single-card
/// PreviewOverlay: collapsing hides the card under the editor, and the stack
/// bookkeeping the editor expects (apply, dismiss) needs no counterpart here.
final class ScreenshotPreviewStack {
    static let shared = ScreenshotPreviewStack()

    func collapse() {
        PreviewOverlay.shared.hide()
    }

    func expand() {}

    @discardableResult
    func applyAnnotation(originalURL: URL, historyURL: URL) -> Bool {
        true
    }

    func dismissRecordingSession(_ directoryURL: URL) {}
}

/// Layout constant from BetterShot's preview peek pill; the editors reserve
/// bottom clearance against it even though BetterShot has no floating pill.
enum PreviewPeekTab {
    static let pillHeight: CGFloat = 42
}

final class PreviewPanelPresenter {
    static let shared = PreviewPanelPresenter()

    var onAnnotate: ((URL) -> Void)? { didSet { flushPendingEditors() } }
    var onEditVideo: ((URL) -> Void)? { didSet { flushPendingEditors() } }

    /// Files opened at launch arrive before the scene installs the handlers.
    private var pendingEditorURLs: [URL] = []

    func show(displayID: CGDirectDisplayID?) {}

    func openEditor(for url: URL) {
        let ext = url.pathExtension.lowercased()
        let handler = (ext == "mov" || ext == "mp4") ? onEditVideo : onAnnotate
        guard let handler else {
            pendingEditorURLs.append(url)
            return
        }
        handler(url)
    }

    private func flushPendingEditors() {
        guard !pendingEditorURLs.isEmpty else { return }
        let urls = pendingEditorURLs
        pendingEditorURLs.removeAll()
        for url in urls { openEditor(for: url) }
    }
}
