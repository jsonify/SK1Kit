import XCTest
@testable import SK1Tokens

final class SK1TokensTests: XCTestCase {
    func testSevenSegmentDigits() {
        let expected: [Character: String] = ["0": "abcdef", "1": "bc", "2": "abdeg", "3": "abcdg", "4": "bcfg", "5": "acdfg",
                                             "6": "acdefg", "7": "abc", "8": "abcdefg", "9": "abcdfg", "-": "g", " ": ""]
        for (c, segments) in expected {
            let lit = SK1.SevenSegment.lit(c).map(\.rawValue).sorted().joined()
            XCTAssertEqual(lit, segments, "\(c)")
        }
        XCTAssertTrue(SK1.SevenSegment.lit("x").isEmpty)
    }

    func testSegmentsFitTheirBox() {
        for s in SK1.SevenSegment.Segment.allCases {
            let points = SK1.SevenSegment.polygon(s)
            XCTAssertEqual(points.count, 6, "\(s)")
            for p in points {
                XCTAssertTrue((0...SK1.SevenSegment.width).contains(p.x) && (0...SK1.SevenSegment.height).contains(p.y), "\(s) \(p)")
            }
        }
        // The top and bottom bars are level and span the digit between the gaps.
        let a = SK1.SevenSegment.polygon(.a)
        XCTAssertEqual(a.map(\.y).min(), 0)
        XCTAssertEqual(SK1.SevenSegment.polygon(.d).map(\.y).max(), SK1.SevenSegment.height)
    }

    func testZoomCells() {
        XCTAssertEqual(SK1.SevenSegment.cells(100, count: 3), "100")
        XCTAssertEqual(SK1.SevenSegment.cells(25, count: 3), " 25")
        XCTAssertEqual(SK1.SevenSegment.cells(800, count: 3), "800")
        XCTAssertEqual(SK1.SevenSegment.cells(1200, count: 3), "---")
        XCTAssertEqual(SK1.SevenSegment.cells(-5, count: 3), "  0")
    }

    func testPaletteFollowsTheAppearance() {
        XCTAssertEqual(SK1.palette(dark: false), SK1.light)
        XCTAssertEqual(SK1.palette(dark: true), SK1.dark)
        XCTAssertEqual(SK1.light.chassis, 0xebe8e1)
        XCTAssertEqual(SK1.dark.chassis, 0x2b2a27)
        XCTAssertLessThan(SK1.dark.lcdBrightness, 1)
    }

    /// The values are Skreener's (`Retro.light` / `Retro.dark`) until Skreener adopts the package.
    func testPaletteMatchesSkreener() {
        XCTAssertFalse(SK1.light.dark)
        XCTAssertTrue(SK1.dark.dark)
        XCTAssertEqual(SK1.light.ink, 0x2b2a27)
        XCTAssertEqual(SK1.dark.ink, 0xece8df)
        XCTAssertEqual(SK1.light.inkSoft, 0x67635a)
        XCTAssertEqual(SK1.dark.inkSoft, 0xa8a397)
        XCTAssertEqual(SK1.light.keyTop, 0xfdfcfa)
        XCTAssertEqual(SK1.dark.keyTop, 0x4a4843)
        XCTAssertEqual(SK1.light.chassisGlow, 0.55)
        XCTAssertEqual(SK1.dark.lcdBrightness, 0.86)
        XCTAssertEqual(SK1.glassTop, 0xd3d9be)
        XCTAssertEqual(SK1.orange, 0xff5c1c)
        XCTAssertEqual(SK1.lcdInk, 0x1e2318)
        XCTAssertEqual(SK1.teal, 0x1f9e86)
        XCTAssertEqual(SK1.recRed, 0xe0402f)
    }

    /// Text in both palettes is at least 4.5:1 against what it sits on.
    func testTextContrast() {
        func ratio(_ a: UInt32, _ b: UInt32) -> Double { SK1.contrast(SK1.RGB(hex: a), SK1.RGB(hex: b)) }
        for p in [SK1.light, SK1.dark] {
            let mode = p.dark ? "dark" : "light"
            XCTAssertGreaterThanOrEqual(ratio(p.ink, p.chassis), 4.5, "caption on chassis, \(mode)")
            XCTAssertGreaterThanOrEqual(ratio(p.inkSoft, p.chassis), 4.5, "soft ink on chassis, \(mode)")
            XCTAssertGreaterThanOrEqual(ratio(p.keyInk, p.keyBottom), 4.5, "key ink, \(mode)")
            XCTAssertGreaterThanOrEqual(ratio(p.keyInk, p.keyDownBottom), 4.5, "pressed key ink, \(mode)")
            XCTAssertGreaterThanOrEqual(ratio(p.trackInk, p.track), 4.5, "segment ink, \(mode)")
            XCTAssertGreaterThanOrEqual(ratio(SK1.charcoalInk, p.charcoalTop), 4.5, "charcoal key ink, \(mode)")
        }
        XCTAssertGreaterThanOrEqual(ratio(SK1.charcoalInk, SK1.segmentTop), 4.5, "selected segment")
        XCTAssertGreaterThanOrEqual(ratio(SK1.lcdInk, SK1.glassBottom), 4.5, "LCD")
        XCTAssertGreaterThanOrEqual(ratio(SK1.lcdInk, SK1.chipBottom), 4.5, "LCD chip")
    }

    func testContrastMaths() {
        let black = SK1.RGB(hex: 0x000000), white = SK1.RGB(hex: 0xffffff)
        XCTAssertEqual(SK1.contrast(black, white), 21, accuracy: 0.001)
        XCTAssertEqual(SK1.contrast(white, black), 21, accuracy: 0.001)
        XCTAssertEqual(SK1.contrast(white, white), 1, accuracy: 0.001)
        XCTAssertEqual(SK1.RGB(hex: 0xff8000), SK1.RGB(r: 255, g: 128, b: 0))
    }

    /// A blinking lamp (the REC lamp, the editor's LIVE lamp) is lit for the first half of each second.
    func testBlinkSteps() {
        XCTAssertTrue(SK1.blinkLit(0))
        XCTAssertTrue(SK1.blinkLit(0.49))
        XCTAssertFalse(SK1.blinkLit(0.5))
        XCTAssertFalse(SK1.blinkLit(0.99))
        XCTAssertTrue(SK1.blinkLit(1))
        XCTAssertFalse(SK1.blinkLit(61.7))
        XCTAssertTrue(SK1.blinkLit(-2), "a clock that went back shows the lamp lit")
    }

    func testTypeScaleAndMetrics() {
        XCTAssertEqual(SK1.TypeScale.caption, SK1.TextStyle(size: 9, weight: .semibold, kern: 0.8, uppercase: true))
        XCTAssertTrue(SK1.TypeScale.lcdMono.monospaced)
        XCTAssertFalse(SK1.TypeScale.hint.uppercase)
        XCTAssertEqual(SK1.Metrics.trayRadius, SK1.Metrics.keyRadius + 3)
        XCTAssertEqual(SK1.Metrics.keyHeight - SK1.Metrics.keySkirt, 28, "a 28 pt face on its skirt")
    }
}
