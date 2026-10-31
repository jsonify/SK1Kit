#if canImport(SwiftUI) && os(macOS)
import AppKit
import SwiftUI
import XCTest
import SK1Tokens
@testable import SK1UI

/// Renders `SK1Gallery` in light and dark at an iPhone's width and a Mac window's, and writes the PNGs to
/// `$SK1_SNAPSHOT_DIR` when it is set (CI uploads them as the `sk1-gallery` artifact). The images are for a person to
/// look at; the test only checks that each one rendered.
final class GallerySnapshotTests: XCTestCase {
    @MainActor
    func testGalleryRendersInLightAndDark() throws {
        let dir = ProcessInfo.processInfo.environment["SK1_SNAPSHOT_DIR"].flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0) }
        if let dir { try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true) }
        for (device, width) in [("iphone", 390.0), ("mac", 720.0)] {
            for scheme in [ColorScheme.light, .dark] {
                let name = "sk1-gallery-\(device)-\(scheme == .dark ? "dark" : "light")"
                let view = SK1Gallery(scrolls: false)
                    .frame(width: width)
                    .environment(\.colorScheme, scheme)
                let renderer = ImageRenderer(content: view)
                renderer.scale = 2
                let image = try XCTUnwrap(renderer.cgImage, "\(name) did not render")
                XCTAssertEqual(image.width, Int(width * 2), name)
                XCTAssertGreaterThan(image.height, 400, name)
                let png = try XCTUnwrap(NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]), name)
                XCTAssertFalse(png.isEmpty, name)
                if let dir { try png.write(to: dir.appendingPathComponent("\(name).png")) }
            }
        }
    }

    /// The palette follows the colour scheme, and the hex helper reads tokens as sRGB.
    func testPaletteForColorScheme() {
        XCTAssertEqual(SK1.palette(for: .light), SK1.light)
        XCTAssertEqual(SK1.palette(for: .dark), SK1.dark)
        let c = NSColor(Color(sk1Hex: 0xff8000)).usingColorSpace(.sRGB)
        XCTAssertEqual(c?.redComponent ?? 0, 1, accuracy: 0.001)
        XCTAssertEqual(c?.greenComponent ?? 0, 128.0 / 255, accuracy: 0.001)
        XCTAssertEqual(c?.blueComponent ?? 1, 0, accuracy: 0.001)
        let dim = NSColor(Color(sk1Hex: 0xffffff, brightness: 0.5)).usingColorSpace(.sRGB)
        XCTAssertEqual(dim?.redComponent ?? 0, 0.5, accuracy: 0.001)
    }

    /// The display glass's corner inside its bezel, and the seven-segment shape draws only what is asked for.
    func testGeometry() {
        XCTAssertEqual(SK1Draw.glassRadius(radius: 9, inset: 4), 6)
        XCTAssertEqual(SK1Draw.glassRadius(radius: 4, inset: 3), 3)
        let face = SK1Draw.keyFace(in: CGRect(x: 0, y: 0, width: 40, height: 30), down: false)
        XCTAssertEqual(face, CGRect(x: 0, y: 0, width: 40, height: 28))
        XCTAssertEqual(SK1Draw.keyFace(in: CGRect(x: 0, y: 0, width: 40, height: 30), down: true).minY, 2)
        let rect = CGRect(x: 0, y: 0, width: 100, height: 36)
        XCTAssertTrue(SevenSegmentShape(" ", segments: .lit).path(in: rect).isEmpty)
        XCTAssertFalse(SevenSegmentShape(" ", segments: .unlit).path(in: rect).isEmpty)
        XCTAssertFalse(SevenSegmentShape("8", segments: .lit).path(in: rect).isEmpty)
        XCTAssertTrue(SevenSegmentShape("8", segments: .unlit).path(in: rect).isEmpty)
        XCTAssertTrue(SevenSegmentShape(":", segments: .unlit).path(in: rect).isEmpty)
    }

    /// A gradient at 90° runs from the top edge to the bottom; at 0° from left to right.
    func testGradientEnds() {
        let r = CGRect(x: 0, y: 0, width: 100, height: 40)
        let (s, e) = SK1Draw.ends(of: r, degrees: 90)
        XCTAssertEqual(s.y, 0, accuracy: 0.001)
        XCTAssertEqual(e.y, 40, accuracy: 0.001)
        let (l, rr) = SK1Draw.ends(of: r, degrees: 0)
        XCTAssertEqual(l.x, 0, accuracy: 0.001)
        XCTAssertEqual(rr.x, 100, accuracy: 0.001)
    }
}
#endif
