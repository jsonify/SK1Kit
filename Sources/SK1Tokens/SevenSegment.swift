import Foundation

extension SK1 {
    /// The seven-segment digits of the timer's LCD: each digit is a 20 × 36 box of segments 3.6 thick with 0.7 gaps, the
    /// row skewed 5° to the right, and the segments that are off still faintly there.
    public enum SevenSegment {
        public enum Segment: String, CaseIterable, Sendable {
            case a, b, c, d, e, f, g
        }

        public static let width: CGFloat = 20, height: CGFloat = 36, thickness: CGFloat = 3.6, gap: CGFloat = 0.7
        /// The lean, in degrees (to the right, like italics).
        public static let skew: CGFloat = 5
        /// How strongly an unlit segment shows.
        public static let unlitOpacity: CGFloat = 0.07

        /// The segments lit for `c`: a digit, "-" or a space (nothing lit); anything else lights nothing.
        public static func lit(_ c: Character) -> Set<Segment> {
            let map: [Character: String] = ["0": "abcdef", "1": "bc", "2": "abged", "3": "abgcd", "4": "fgbc", "5": "afgcd",
                                            "6": "afgedc", "7": "abc", "8": "abcdefg", "9": "abcdfg", "-": "g"]
            return Set((map[c] ?? "").compactMap { Segment(rawValue: String($0)) })
        }

        /// The segment's outline in a `width` × `height` box, y down (as in the timer's SVG).
        public static func polygon(_ s: Segment) -> [CGPoint] {
            let h = thickness / 2, l = thickness / 2, r = width - thickness / 2, m = height / 2
            func across(_ cy: CGFloat, _ x1: CGFloat, _ x2: CGFloat) -> [CGPoint] {
                [CGPoint(x: x1, y: cy), CGPoint(x: x1 + h, y: cy - h), CGPoint(x: x2 - h, y: cy - h), CGPoint(x: x2, y: cy),
                 CGPoint(x: x2 - h, y: cy + h), CGPoint(x: x1 + h, y: cy + h)]
            }
            func down(_ cx: CGFloat, _ y1: CGFloat, _ y2: CGFloat) -> [CGPoint] {
                [CGPoint(x: cx, y: y1), CGPoint(x: cx + h, y: y1 + h), CGPoint(x: cx + h, y: y2 - h), CGPoint(x: cx, y: y2),
                 CGPoint(x: cx - h, y: y2 - h), CGPoint(x: cx - h, y: y1 + h)]
            }
            switch s {
            case .a: return across(h, l + gap, r - gap)
            case .g: return across(m, l + gap, r - gap)
            case .d: return across(height - h, l + gap, r - gap)
            case .f: return down(l, h + gap, m - gap)
            case .b: return down(r, h + gap, m - gap)
            case .e: return down(l, m + gap, height - h - gap)
            case .c: return down(r, m + gap, height - h - gap)
            }
        }

        /// `value` right-aligned in `cells` digits, blank cells in front (a blank shows only unlit segments); too big
        /// a value shows as dashes.
        public static func cells(_ value: Int, count: Int) -> String {
            let s = String(max(value, 0))
            guard s.count <= count else { return String(repeating: "-", count: count) }
            return String(repeating: " ", count: count - s.count) + s
        }

        /// How wide `text` is drawn `digitHeight` tall with `spacing` between characters (a ":" is narrow).
        public static func textWidth(_ text: String, digitHeight: CGFloat, spacing: CGFloat) -> CGFloat {
            let scale = digitHeight / height
            let widths = text.map { $0 == ":" ? 6 * scale : width * scale }
            return widths.reduce(0, +) + spacing * CGFloat(max(text.count - 1, 0)) + tan(skew * .pi / 180) * digitHeight
        }
    }
}
