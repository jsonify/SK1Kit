#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// How big a key is, skirt included.
public enum SK1KeySize: Sendable, Hashable {
    /// The floating bars' key: a 28 pt face on its 2 pt skirt.
    case regular
    /// A pop-up's key, 26 pt.
    case small
    /// The main action on iOS: 56 pt and the full width.
    case large

    public var height: CGFloat {
        switch self {
        case .regular: return SK1.Metrics.keyHeight
        case .small: return SK1.Metrics.popUpHeight
        case .large: return 56
        }
    }
}

/// An SK-1 key (Skreener's `PillButton` `.keycap` and `.round`, drawn by `Retro.drawKey`, `keyColors` and
/// `drawOnBar`): a raised face on a 2 pt skirt, cream, orange or charcoal, casting a shadow. Pressed, the face drops
/// onto the skirt at once (no animation); `isOn` keeps it down, and a cream key then shows the glowing orange bar.
/// Titles are upper case and tracked. A key is at least as wide as it is tall less its skirt (a symbol-only key is
/// square). `.round` is the small round cream key, as wide as it is tall.
///
/// On iOS the key takes taps in at least 44 × 44 pt and gives a light haptic on press.
///
/// ```swift
/// Button("Save") { save() }.buttonStyle(.sk1Key(.orange))
/// Button { pick(.pen) } label: { Image(systemName: "pencil") }.buttonStyle(.sk1Key(isOn: tool == .pen))
/// Button("Record") { start() }.buttonStyle(.sk1Key(.orange, size: .large))
/// ```
public struct SK1KeyStyle: ButtonStyle {
    public var variant: SK1KeyVariant
    public var isOn: Bool
    public var size: SK1KeySize

    public init(_ variant: SK1KeyVariant = .cream, isOn: Bool = false, size: SK1KeySize = .regular) {
        self.variant = variant
        self.isOn = isOn
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        SK1KeyBody(label: configuration.label, pressed: configuration.isPressed, variant: variant, isOn: isOn, size: size)
    }
}

extension ButtonStyle where Self == SK1KeyStyle {
    /// An SK-1 key; see `SK1KeyStyle`.
    public static func sk1Key(_ variant: SK1KeyVariant = .cream, isOn: Bool = false,
                              size: SK1KeySize = .regular) -> SK1KeyStyle {
        SK1KeyStyle(variant, isOn: isOn, size: size)
    }
}

/// A `Label` on a key: the symbol a little larger than the title, `SK1.Metrics.iconGap` apart.
struct SK1KeyLabelStyle: LabelStyle {
    let symbolSize: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: SK1.Metrics.iconGap) {
            configuration.icon.font(.system(size: symbolSize, weight: .semibold))
            configuration.title
        }
    }
}

struct SK1KeyBody<Content: View>: View {
    let label: Content
    let pressed: Bool
    let variant: SK1KeyVariant
    let isOn: Bool
    let size: SK1KeySize
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    /// What a key's title is set in (Skreener: 10 pt bold, tracked 0.6); the large key's is bigger.
    private var titleSize: CGFloat { size == .large ? 15 : 10 }
    /// Skreener: a 13 pt symbol on a key 28 pt or taller, 11 pt on a smaller one; a round key's is 0.38 of it.
    private var symbolSize: CGFloat {
        if variant == .round { return max(7, size.height * 0.38) }
        return size == .large ? 18 : size.height >= 28 ? 13 : 11
    }

    var body: some View {
        let p = SK1.palette(for: scheme)
        let colors = SK1Draw.keyColors(variant, p)
        let round = variant == .round
        let h = size.height
        let down = round ? pressed : (pressed || isOn)
        let skirt: CGFloat = round ? 1 : SK1.Metrics.keySkirt
        let minWidth = round ? h : h - skirt

        label
            .labelStyle(SK1KeyLabelStyle(symbolSize: symbolSize))
            .font(.system(size: round ? symbolSize : titleSize, weight: .bold))
            .tracking(0.6)
            .textCase(.uppercase)
            .lineLimit(1)
            .foregroundStyle(round ? Color(sk1Hex: p.keyInk) : colors.ink)
            // The content sits on the face, above the skirt, and sinks with it when pressed.
            .offset(y: down ? skirt / 2 : -skirt / 2)
            .padding(.horizontal, round ? 0 : 10)
            .frame(minWidth: minWidth, maxWidth: size == .large ? .infinity : nil, minHeight: h, maxHeight: h)
            .frame(width: round ? h : nil)
            .background(SK1Canvas(outset: 8) { ctx, rect, _ in
                Self.draw(ctx, rect, colors: colors, variant: variant, down: down, pressed: pressed, isOn: isOn, dark: p.dark)
            })
            .opacity(isEnabled ? 1 : 0.4)
            .contentShape(Rectangle())
            .sk1MinimumHitArea(width: minWidth, height: h)
            .accessibilityAddTraits(isOn ? .isSelected : [])
            .transaction { $0.animation = nil }
            .sk1PressFeedback(pressed)
    }

    /// The shadow the key casts (its layer shadow in Skreener), then the key and, on a cream key that is on, its bar.
    static func draw(_ ctx: GraphicsContext, _ rect: CGRect, colors c: SK1Draw.KeyColors, variant: SK1KeyVariant, down: Bool,
                     pressed: Bool, isOn: Bool, dark: Bool) {
        if variant == .round {
            let d = min(rect.width, rect.height)
            let body = CGRect(x: rect.midX - d / 2, y: rect.midY - d / 2, width: d, height: d)
            SK1Draw.castShadow(ctx, Path(ellipseIn: body), color: .black, opacity: pressed ? 0 : (dark ? 0.4 : 0.15), radius: 1, y: 1)
            SK1Draw.key(ctx, in: body, radius: (d - 1) / 2, colors: c, down: pressed, skirt: 1)
            return
        }
        let skirt = SK1.Metrics.keySkirt
        // Up, the whole key casts it; pressed, the face alone, half as far down.
        let shadowRect = down ? rect.insetBy(dx: 0, dy: skirt / 2) : rect
        SK1Draw.castShadow(ctx, SK1Draw.roundedRect(shadowRect, SK1.Metrics.keyRadius), color: c.shadow,
                           opacity: down ? c.shadowAlpha * 1.3 : c.shadowAlpha,
                           radius: down ? 1 : (variant == .orange ? 3.5 : 2), y: down ? 1 : 2)
        let face = SK1Draw.key(ctx, in: rect, radius: SK1.Metrics.keyRadius, colors: c, down: down)
        if isOn, variant == .cream { SK1Draw.onBar(ctx, in: face) }
    }
}

extension View {
    /// On iOS, takes taps in at least 44 × 44 pt round a control `width` × `height` big, without changing its layout.
    @ViewBuilder
    func sk1MinimumHitArea(width: CGFloat, height: CGFloat) -> some View {
        #if os(iOS)
        let dx = max(0, (44 - width) / 2), dy = max(0, (44 - height) / 2)
        self.padding(.horizontal, dx).padding(.vertical, dy)
            .contentShape(Rectangle())
            .padding(.horizontal, -dx).padding(.vertical, -dy)
        #else
        self
        #endif
    }

    /// On iOS, a light haptic as a control goes down.
    @ViewBuilder
    func sk1PressFeedback(_ pressed: Bool) -> some View {
        #if os(iOS)
        self.sensoryFeedback(.impact(weight: .light), trigger: pressed) { _, isDown in isDown }
        #else
        self
        #endif
    }
}

/// Keys in a sunken tray (radius 9) with an optional caption under it (Skreener's `KeycapTray`): 5 pt either side of
/// the keys, 4 pt above and below, 3 pt between them, the caption 5 pt under the tray and centred on it. The tray is
/// as wide as its keys. VoiceOver reads the keys as a group named by the caption.
///
/// ```swift
/// SKKeyTray(caption: "Tools") {
///     Button { } label: { Image(systemName: "pencil") }.buttonStyle(.sk1Key(isOn: true))
///     Button { } label: { Image(systemName: "eraser") }.buttonStyle(.sk1Key())
/// }
/// ```
public struct SKKeyTray<Keys: View>: View {
    private let caption: String?
    private let spacing: CGFloat
    private let keys: Keys

    public init(caption: String? = nil, spacing: CGFloat = 3, @ViewBuilder keys: () -> Keys) {
        self.caption = caption
        self.spacing = spacing
        self.keys = keys()
    }

    public var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: spacing) { keys }
                .padding(.horizontal, 5)
                .padding(.vertical, 4)
                // The well's own view: the tray in all but its bottom point, which holds the light lip.
                .background(SK1Canvas { ctx, rect, p in
                    SK1Draw.well(ctx, CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: max(rect.height - 1, 0)),
                                 radius: SK1.Metrics.trayRadius, palette: p)
                })
            if let caption {
                SKCaption(caption).accessibilityHidden(true)
            }
        }
        .padding(.bottom, caption == nil ? 1 : 0)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(caption ?? ""))
    }
}
#endif
