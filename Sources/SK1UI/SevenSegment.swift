#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// Seven-segment text as a SwiftUI shape, from `SK1.SevenSegment`'s geometry (Skreener's `SevenSegment.draw`): digits,
/// "-", ":" and spaces, the digits as tall as the rect from its left edge, leaning 5° right, `spacing` between
/// characters and a narrow colon. `segments` picks the lit segments (and the colons), the unlit ones, or both; fill
/// the unlit ones at `SK1.SevenSegment.unlitOpacity` for the ghost digits.
public struct SevenSegmentShape: Shape {
    public enum Segments: Sendable, Hashable {
        case lit, unlit, all
    }

    public var text: String
    public var spacing: CGFloat
    public var segments: Segments

    public init(_ text: String, spacing: CGFloat = 2, segments: Segments = .lit) {
        self.text = text
        self.spacing = spacing
        self.segments = segments
    }

    public func path(in rect: CGRect) -> Path {
        typealias Geometry = SK1.SevenSegment
        let scale = rect.height / Geometry.height
        let lean = tan(Geometry.skew * .pi / 180)
        var path = Path()
        var x = rect.minX
        // A point of the box (y down) in the rect, leaning right toward the top.
        func point(_ p: CGPoint, _ originX: CGFloat) -> CGPoint {
            CGPoint(x: originX + p.x * scale + lean * (Geometry.height - p.y) * scale, y: rect.minY + p.y * scale)
        }
        for ch in text {
            if ch == ":" {
                if segments != .unlit {
                    for cy in [12.0, 25.0] as [CGFloat] {
                        let c = point(CGPoint(x: 3, y: cy), x)
                        path.addEllipse(in: CGRect(x: c.x - 2 * scale, y: c.y - 2 * scale, width: 4 * scale, height: 4 * scale))
                    }
                }
                x += 6 * scale + spacing
                continue
            }
            let on = Geometry.lit(ch)
            for s in Geometry.Segment.allCases {
                let isLit = on.contains(s)
                guard segments == .all || (segments == .lit) == isLit else { continue }
                path.addLines(Geometry.polygon(s).map { point($0, x) })
                path.closeSubpath()
            }
            x += Geometry.width * scale + spacing
        }
        return path
    }
}

/// Seven-segment digits in the LCD's ink with the unlit segments faintly there, `digitHeight` tall and as wide as
/// the text (Skreener's `SevenSegmentView`). VoiceOver reads the text.
///
/// ```swift
/// SKSevenSegment("12:05", digitHeight: 26, spacing: 3)
/// ```
public struct SKSevenSegment: View {
    private let text: String
    private let digitHeight: CGFloat
    private let spacing: CGFloat
    private let color: Color

    /// `color` is the LCD's ink unless given.
    public init(_ text: String, digitHeight: CGFloat = 22, spacing: CGFloat = 2, color: Color? = nil) {
        self.text = text
        self.digitHeight = digitHeight
        self.spacing = spacing
        self.color = color ?? Color(sk1Hex: SK1.lcdInk)
    }

    public var body: some View {
        ZStack {
            SevenSegmentShape(text, spacing: spacing, segments: .unlit).fill(color.opacity(SK1.SevenSegment.unlitOpacity))
            SevenSegmentShape(text, spacing: spacing, segments: .lit).fill(color)
        }
        .frame(width: ceil(SK1.SevenSegment.textWidth(text, digitHeight: digitHeight, spacing: spacing)), height: digitHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(text.trimmingCharacters(in: .whitespaces)))
    }
}
#endif
