import Foundation
import UniformTypeIdentifiers

nonisolated enum CaptureURLAction: String, CaseIterable {
    case region = "capture/region"
    case fullscreen = "capture/fullscreen"
    case window = "capture/window"
    case recording = "record"
    case ocr
    case colorPicker = "color-picker"
    case settings

    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "bettershot",
              components.user == nil, components.password == nil, components.port == nil,
              components.query == nil, components.fragment == nil,
              let host = components.host else { return nil }
        self.init(rawValue: host.lowercased() + components.path)
    }
}

/// Finder's Open With and `bettershot://` links share one delegate callback.
nonisolated enum OpenedURLRouting {
    struct Route: Equatable {
        var actions: [CaptureURLAction] = []
        var images: [URL] = []
    }

    static func route(_ urls: [URL]) -> Route {
        var route = Route()
        for url in urls {
            if isEditableImage(url) {
                route.images.append(url)
            } else if let action = CaptureURLAction(url: url) {
                route.actions.append(action)
            }
        }
        return route
    }

    static func isEditableImage(_ url: URL) -> Bool {
        guard url.isFileURL, !url.pathExtension.isEmpty,
              let type = UTType(filenameExtension: url.pathExtension) else { return false }
        return type.conforms(to: .image)
    }
}
