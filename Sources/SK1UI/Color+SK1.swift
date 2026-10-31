#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

extension SK1 {
    /// The palette for a SwiftUI colour scheme: `SK1.dark` for `.dark`, `SK1.light` otherwise. Read the scheme with
    /// `@Environment(\.colorScheme)`.
    public static func palette(for scheme: ColorScheme) -> Palette { palette(dark: scheme == .dark) }
}

extension Color {
    /// An SK-1 token (0xRRGGBB, sRGB) as a colour, with an optional opacity.
    public init(sk1Hex hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xff) / 255, green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255, opacity: opacity)
    }

    /// `hex` scaled toward black by `brightness` (1 leaves it as it is): the LCD's glass in Dark Mode
    /// (`Palette.lcdBrightness`), as Skreener's `Retro.color(_:brightness:)`.
    public init(sk1Hex hex: UInt32, brightness: Double) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xff) / 255 * brightness,
                  green: Double((hex >> 8) & 0xff) / 255 * brightness, blue: Double(hex & 0xff) / 255 * brightness,
                  opacity: 1)
    }
}
#endif
