#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

extension Font.Weight {
    /// The SwiftUI weight for an SK-1 weight.
    init(sk1 weight: SK1.Weight) {
        switch weight {
        case .regular: self = .regular
        case .medium: self = .medium
        case .semibold: self = .semibold
        case .bold: self = .bold
        }
    }
}

extension Font {
    /// The system font (monospaced for `lcdMono`) at an SK-1 type style's size and weight, e.g.
    /// `.font(.sk1(SK1.TypeScale.rowTitle))`. The style's tracking and case are the view's: see `SKCaption`.
    /// This font does not scale with Dynamic Type; `SKCaption`, `.sk1Hint()` and `SKRow` do.
    public static func sk1(_ style: SK1.TextStyle) -> Font { sk1(style, size: style.size) }

    static func sk1(_ style: SK1.TextStyle, size: CGFloat) -> Font {
        .system(size: size, weight: Font.Weight(sk1: style.weight), design: style.monospaced ? .monospaced : .default)
    }
}

/// An SK-1 type style on text: its font, tracking and case. With `scalesWith`, the size and tracking follow Dynamic
/// Type relative to that text style (on iOS; macOS has no Dynamic Type).
struct SK1TextModifier: ViewModifier {
    let style: SK1.TextStyle
    let scales: Bool
    @ScaledMetric private var scaledSize: CGFloat

    init(style: SK1.TextStyle, scalesWith textStyle: Font.TextStyle?) {
        self.style = style
        scales = textStyle != nil
        _scaledSize = ScaledMetric(wrappedValue: style.size, relativeTo: textStyle ?? .body)
    }

    func body(content: Content) -> some View {
        let size = scales ? scaledSize : style.size
        content
            .font(.sk1(style, size: size))
            .tracking(style.kern * size / style.size)
            .textCase(style.uppercase ? .uppercase : nil)
    }
}

extension View {
    /// An SK-1 type style; with `scalesWith`, it scales with Dynamic Type up to `cap`.
    func sk1Text(_ style: SK1.TextStyle, scalesWith textStyle: Font.TextStyle? = nil,
                 cap: DynamicTypeSize = .accessibility5) -> some View {
        modifier(SK1TextModifier(style: style, scalesWith: textStyle)).dynamicTypeSize(...cap)
    }

    /// The hint style: 11 pt regular in the palette's soft ink, for a note under a row or a tray. It scales with
    /// Dynamic Type on iOS.
    ///
    /// ```swift
    /// Text("Saved to the Desktop.").sk1Hint()
    /// ```
    public func sk1Hint() -> some View { modifier(SK1HintModifier()) }
}

struct SK1HintModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .sk1Text(SK1.TypeScale.hint, scalesWith: .footnote)
            .foregroundStyle(Color(sk1Hex: SK1.palette(for: scheme).inkSoft))
    }
}

/// A caption: small, semibold, upper case and tracked, in the palette's ink (`.ink`) or soft ink (`.soft`), as under
/// a tray or before a control (Skreener's `RetroLabel(caption:)`). VoiceOver reads it in normal case. On iOS it
/// scales with Dynamic Type up to `.accessibility1`.
///
/// ```swift
/// SKCaption("Output", tone: .soft)
/// ```
public struct SKCaption: View {
    public enum Tone: Sendable, Hashable {
        /// The palette's ink.
        case ink
        /// The soft ink, for a group's heading.
        case soft
    }

    private let text: String
    private let tone: Tone
    private let style: SK1.TextStyle
    @Environment(\.colorScheme) private var scheme

    /// `style` is `SK1.TypeScale.caption` unless given (e.g. `indicator`).
    public init(_ text: String, tone: Tone = .ink, style: SK1.TextStyle = SK1.TypeScale.caption) {
        self.text = text
        self.tone = tone
        self.style = style
    }

    public var body: some View {
        let p = SK1.palette(for: scheme)
        Text(text)
            .sk1Text(style, scalesWith: .caption2, cap: .accessibility1)
            .foregroundStyle(Color(sk1Hex: tone == .ink ? p.ink : p.inkSoft))
            .lineLimit(1)
            .accessibilityLabel(Text(text))
    }
}
#endif
