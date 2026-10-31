#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// Olive LCD glass filling the view (Skreener's `Retro.drawGlass`): darker toward the bottom (dimmed in Dark Mode by
/// the palette's `lcdBrightness`), a sheen at the top left, a pixel grid every 2 pt, a 2 pt inner shadow and a dark
/// edge. `.chip` is a small chip's glass (`Retro.drawChipGlass`): lighter, with no grid and a shallower shadow.
///
/// ```swift
/// Text("42").padding(6).background(SKGlass(.chip))
/// ```
public struct SKGlass: View {
    public enum Kind: Sendable, Hashable {
        /// A display's glass, with the pixel grid.
        case display
        /// A small chip's glass.
        case chip
    }

    private let kind: Kind
    private let radius: CGFloat

    /// `radius` is the glass's corner: by default a display's inside its bezel (6), or a chip's (3).
    public init(_ kind: Kind = .display, radius: CGFloat? = nil) {
        self.kind = kind
        self.radius = radius ?? (kind == .display
            ? SK1Draw.glassRadius(radius: SK1.Metrics.lcdRadius, inset: SK1.Metrics.lcdInset) : 3)
    }

    public var body: some View {
        SK1Canvas { ctx, rect, p in
            switch kind {
            case .display: SK1Draw.glass(ctx, rect, radius: radius, brightness: p.lcdBrightness)
            case .chip: SK1Draw.chipGlass(ctx, rect, radius: radius, brightness: p.lcdBrightness)
            }
        }
    }
}

/// An LCD: olive glass in a sunken bezel (Skreener's `Retro.drawLCD`), with `content` on the glass. The bezel's light
/// lip takes the view's bottom point; the glass sits `inset` inside the rest, and `content` fills the glass (pad it
/// yourself).
///
/// ```swift
/// SKLCD { Text("READY").padding(.horizontal, 8) }.frame(height: 30)
/// ```
public struct SKLCD<Content: View>: View {
    private let radius: CGFloat
    private let inset: CGFloat
    private let content: Content

    public init(radius: CGFloat = SK1.Metrics.lcdRadius, inset: CGFloat = SK1.Metrics.lcdInset,
                @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.inset = inset
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, inset)
            .padding(.top, inset)
            .padding(.bottom, inset + 1)
            .background(SK1Canvas { ctx, rect, p in
                let outer = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: max(rect.height - 1, 0))
                SK1Draw.lcd(ctx, in: outer, radius: radius, inset: inset, palette: p)
            })
    }
}

/// The LCD's ink with the faint shadow its type casts on the glass (Skreener's `LCDDisplay` "ghost").
extension View {
    func sk1LCDInk(_ alpha: Double = 1) -> some View {
        foregroundStyle(Color(sk1Hex: SK1.lcdInk, opacity: alpha))
            .shadow(color: Color(sk1Hex: SK1.lcdInk, opacity: 0.15), radius: 0, x: 1, y: 1)
    }
}

/// One line of mono ink on LCD glass in a small bezel (radius 7, the glass 3 pt in), cut short at the end when it
/// does not fit (Skreener's `LCDReadout`), 30 pt tall by default. VoiceOver reads the text.
///
/// ```swift
/// SKReadout("Scrolling… 4 frames")
/// ```
public struct SKReadout: View {
    private let text: String
    private let height: CGFloat

    public init(_ text: String, height: CGFloat = 30) {
        self.text = text
        self.height = height
    }

    public var body: some View {
        SKLCD(radius: 7, inset: 3) {
            Text(text)
                .font(.sk1(SK1.TypeScale.lcdMono))
                .tracking(SK1.TypeScale.lcdMono.kern)
                .foregroundStyle(Color(sk1Hex: SK1.lcdInk))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(text))
    }
}

/// A small olive LCD chip with mono text that only shows (Skreener's `LCDChip`): 20 pt tall, at least 44 pt wide,
/// 10 pt bold mono tracked 0.5, 7 pt either side. VoiceOver reads the text.
///
/// ```swift
/// SKChip("100%")
/// ```
public struct SKChip: View {
    private let text: String
    private let minWidth: CGFloat
    private let height: CGFloat

    public init(_ text: String, minWidth: CGFloat = 44, height: CGFloat = 20) {
        self.text = text
        self.minWidth = minWidth
        self.height = height
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(0.5)
            .foregroundStyle(Color(sk1Hex: SK1.lcdInk))
            .lineLimit(1)
            .padding(.horizontal, 7)
            .frame(minWidth: minWidth, minHeight: height, maxHeight: height)
            .background(SKGlass(.chip, radius: 3))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(text))
    }
}

/// A status display after Skreener's editor (`LCDDisplay`): on olive glass, what is in use (`title`, with `detail`
/// under it) in a column at the left, the main line (`message`) in mono, an optional `number` in seven-segment digits
/// with its `unit`, and a lamp with "LIVE" (blinking) or "IDLE" at the right. The title column is at least 150 pt,
/// more for a long title, up to a third of the display. 46 pt tall by default. Reduce Motion keeps the lamp lit.
///
/// ```swift
/// SKDisplay(title: "Rectangle", detail: "Key R", message: "Drag to draw", number: 100, unit: "%", live: false)
/// ```
public struct SKDisplay: View {
    private let title: String
    private let detail: String
    private let message: String
    private let number: Int?
    private let digits: Int
    private let unit: String?
    private let live: Bool
    private let height: CGFloat

    /// `number` shows in `digits` seven-segment cells (too big a number shows dashes), `unit` after it.
    public init(title: String, detail: String = "", message: String, number: Int? = nil, digits: Int = 3,
                unit: String? = nil, live: Bool = false, height: CGFloat = 46) {
        self.title = title
        self.detail = detail
        self.message = message
        self.number = number
        self.digits = digits
        self.unit = unit
        self.live = live
        self.height = height
    }

    public var body: some View {
        // The glass is the display less the bezel's 4 pt and the lip's 1 pt.
        let glassHeight = height - 2 * SK1.Metrics.lcdInset - 1
        let digitHeight = max(min(22, glassHeight - 14), 8)
        SKLCD {
            SKDisplayRow {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title.uppercased())
                        .font(.system(size: 9.5, weight: .heavy))
                        .tracking(1.1)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .sk1LCDInk()
                    if !detail.isEmpty {
                        Text(detail.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(1)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .sk1LCDInk(0.75)
                    }
                }
                Text(message)
                    .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                    .tracking(0.2)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .sk1LCDInk()
                HStack(spacing: 0) {
                    if let number {
                        HStack(alignment: .bottom, spacing: 3) {
                            SKSevenSegment(SK1.SevenSegment.cells(number, count: digits), digitHeight: digitHeight)
                                .shadow(color: Color(sk1Hex: SK1.lcdInk, opacity: 0.15), radius: 0, x: 1, y: 1)
                            if let unit {
                                Text(unit).font(.system(size: 10, weight: .heavy)).sk1LCDInk()
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    SK1BlinkingLamp(blinking: live) { lit in
                        let ink = Color(sk1Hex: SK1.lcdInk)
                        SKLampDot(color: ink, lit: live && lit, unlit: ink.opacity(0.15), glow: 0, size: 5)
                    }
                    .padding(.trailing, 4)
                    Text(live ? "LIVE" : "IDLE")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(1)
                        .sk1LCDInk()
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(SK1.Format.displayAccessibilityValue(title: title, message: message, live: live)))
    }
}

/// `SKDisplay`'s row: the title column (at least 150 pt, more for a long title, at most a third), the message after
/// it 16 pt on, and the number and lamp at the right, the message stopping 16 pt short of them.
struct SKDisplayRow: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let h = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        return CGSize(width: proposal.width ?? 480, height: proposal.height ?? h)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }
        let trailing = subviews[2].sizeThatFits(.unspecified)
        subviews[2].place(at: CGPoint(x: bounds.maxX, y: bounds.midY), anchor: .trailing, proposal: ProposedViewSize(trailing))
        let ideal = subviews[0].sizeThatFits(.unspecified).width
        let column = max(min(max(150, ideal + 4), bounds.width / 3), 0)
        subviews[0].place(at: CGPoint(x: bounds.minX, y: bounds.midY), anchor: .leading,
                          proposal: ProposedViewSize(width: column, height: bounds.height))
        let messageX = bounds.minX + column + 16, right = bounds.maxX - trailing.width - 16
        subviews[1].place(at: CGPoint(x: messageX, y: bounds.midY), anchor: .leading,
                          proposal: ProposedViewSize(width: max(right - messageX, 0), height: bounds.height))
    }
}
#endif
