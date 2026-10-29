import Foundation

@main
struct OpenWithRoutingCheck {
    static func main() {
        let mixed = [
            URL(string: "bettershot://capture/region")!,
            URL(fileURLWithPath: "/tmp/one.png"),
            URL(string: "bettershot://ocr")!,
            URL(fileURLWithPath: "/tmp/two.JPEG"),
        ]
        let route = OpenedURLRouting.route(mixed)
        assert(route.actions == [.region, .ocr], "capture actions kept in order")
        assert(route.images.map(\.lastPathComponent) == ["one.png", "two.JPEG"], "images kept in order")

        for path in ["/tmp/a.png", "/tmp/a.jpg", "/tmp/a.jpeg", "/tmp/A.PNG", "/tmp/a.heic", "/tmp/a.tiff"] {
            assert(OpenedURLRouting.isEditableImage(URL(fileURLWithPath: path)), path)
        }

        // "Open With > Other…" can pass any file, so non-images must be dropped.
        for path in ["/tmp/a.mov", "/tmp/a.mp4", "/tmp/a.txt", "/tmp/a.pdf", "/tmp/a"] {
            assert(!OpenedURLRouting.isEditableImage(URL(fileURLWithPath: path)), path)
        }

        for value in ["https://example.com/a.png", "bettershot://capture/region"] {
            assert(!OpenedURLRouting.isEditableImage(URL(string: value)!), value)
        }

        let malformed = OpenedURLRouting.route([URL(string: "bettershot://unknown")!])
        assert(malformed.actions.isEmpty && malformed.images.isEmpty, "malformed link dropped")

        print("OpenWithRoutingCheck: Finder image opens and bettershot:// links route separately")
    }
}
