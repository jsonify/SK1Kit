import Foundation

extension SK1 {
    /// A font weight, as the system font's names for it.
    public enum Weight: String, CaseIterable, Sendable {
        case regular, medium, semibold, bold
    }

    /// A type style as plain numbers: the SwiftUI and AppKit layers turn it into a font. Sizes are in points, `kern`
    /// is the tracking in points. Body text is the system font in the palette's ink; `monospaced` is the system
    /// monospaced font.
    public struct TextStyle: Equatable, Sendable {
        public var size: CGFloat
        public var weight: Weight
        public var kern: CGFloat
        public var uppercase: Bool
        public var monospaced: Bool

        public init(size: CGFloat, weight: Weight, kern: CGFloat = 0, uppercase: Bool = false, monospaced: Bool = false) {
            self.size = size; self.weight = weight; self.kern = kern
            self.uppercase = uppercase; self.monospaced = monospaced
        }
    }

    /// The type styles.
    public enum TypeScale {
        /// Captions under trays and before controls: small, bold, upper case and tracked.
        public static let caption = TextStyle(size: 9, weight: .semibold, kern: 0.8, uppercase: true)
        /// A toggle's or an indicator's caption.
        public static let indicator = TextStyle(size: 9.5, weight: .bold, kern: 0.6, uppercase: true)
        /// A settings row's title.
        public static let rowTitle = TextStyle(size: 12.5, weight: .medium)
        /// A note or hint under a row or a tray.
        public static let hint = TextStyle(size: 11, weight: .regular)
        /// The LCD's and the legends' type.
        public static let lcdMono = TextStyle(size: 11, weight: .semibold, kern: 0.3, monospaced: true)
    }
}
