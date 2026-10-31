import Foundation

extension SK1 {
    /// An sRGB colour with components from 0 to 255.
    public struct RGB: Equatable, Sendable {
        public var r: Double, g: Double, b: Double

        public init(r: Double, g: Double, b: Double) {
            self.r = r; self.g = g; self.b = b
        }

        /// From 0xRRGGBB.
        public init(hex: UInt32) {
            self.init(r: Double((hex >> 16) & 0xff), g: Double((hex >> 8) & 0xff), b: Double(hex & 0xff))
        }

        /// WCAG 2 relative luminance (linear-light, 0 for black, 1 for white).
        public var luminance: Double {
            func lin(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
            return 0.2126 * lin(r / 255) + 0.7152 * lin(g / 255) + 0.0722 * lin(b / 255)
        }
    }

    /// The WCAG 2 contrast ratio, 1 to 21 (the order of the colours does not matter).
    public static func contrast(_ a: RGB, _ b: RGB) -> Double {
        let la = a.luminance, lb = b.luminance
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }

    /// The WCAG 2 contrast ratio between two 0xRRGGBB colours.
    public static func contrast(_ a: UInt32, _ b: UInt32) -> Double { contrast(RGB(hex: a), RGB(hex: b)) }
}
