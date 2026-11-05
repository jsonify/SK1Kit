#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

// Skreener's menu-bar launcher (`MenuLauncher.swift`): a slim LCD strip, big tiles for the main actions in a sunken
// tray, and trays of small captioned keys under captions. On the Mac a tile or key sinks and lights its lamp while the
// pointer is over it, and can tell its owner (`onHover`) so the strip can show its name and shortcut.

/// A big key for a main action (Skreener's `LauncherTile`): its symbol on a 34 pt key, a small lamp in the face's top
/// right corner, and under the key its title as a caption and an optional legend (a shortcut, "⌃⇧4") in small mono.
/// Cream, or orange for the main action; it fills the width it is given. While the pointer is over it the key sinks
/// and the lamp lights (teal, white on orange); `isOn` keeps the lamp lit (something it started is running).
///
/// ```swift
/// SKWell {
///     Grid(horizontalSpacing: 4, verticalSpacing: 4) {
///         GridRow {
///             SKTile("Area", systemImage: "viewfinder", legend: "⇧⌘4") { capture(.area) }
///             SKTile("Record", systemImage: "record.circle", legend: "⌃⇧7", variant: .orange) { record() }
///         }
///     }
///     .padding(6)
/// }
/// ```
public struct SKTile: View {
    private let title: String
    private let systemImage: String
    private let legend: String?
    private let variant: SK1KeyVariant
    private let isOn: Bool
    private let onHover: ((Bool) -> Void)?
    private let action: () -> Void
    @State private var hovering = false

    public init(_ title: String, systemImage: String, legend: String? = nil, variant: SK1KeyVariant = .cream,
                isOn: Bool = false, onHover: ((Bool) -> Void)? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.legend = legend
        self.variant = variant
        self.isOn = isOn
        self.onHover = onHover
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage).font(.system(size: 15, weight: .medium))
        }
        .buttonStyle(SK1TileButtonStyle(title: title, legend: legend, variant: variant, hovering: hovering, lampLit: hovering || isOn))
        .onHover { inside in
            hovering = inside
            onHover?(inside)
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(legend.map { "Shortcut: \($0)" } ?? ""))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// The tile's key, title and legend; pressed or hovered, the key sinks.
struct SK1TileButtonStyle: ButtonStyle {
    let title: String
    let legend: String?
    let variant: SK1KeyVariant
    let hovering: Bool
    let lampLit: Bool

    func makeBody(configuration: Configuration) -> some View {
        SK1TileBody(label: configuration.label, title: title, legend: legend, variant: variant,
                    down: configuration.isPressed || hovering, lampLit: lampLit, pressed: configuration.isPressed)
    }
}

struct SK1TileBody<Content: View>: View {
    let label: Content
    let title: String
    let legend: String?
    let variant: SK1KeyVariant
    let down: Bool
    let lampLit: Bool
    let pressed: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    /// Skreener's `LauncherTile.keyHeight`.
    static var keyHeight: CGFloat { 34 }

    var body: some View {
        let p = SK1.palette(for: scheme)
        let colors = SK1Draw.keyColors(variant, p)
        let skirt = SK1.Metrics.keySkirt
        VStack(spacing: 0) {
            label
                .foregroundStyle(colors.ink)
                .offset(y: down ? skirt / 2 : -skirt / 2)
                .frame(maxWidth: .infinity, minHeight: Self.keyHeight, maxHeight: Self.keyHeight)
                .background(SK1Canvas(outset: 8) { ctx, rect, _ in
                    Self.draw(ctx, rect, colors: colors, variant: variant, down: down, lampLit: lampLit)
                })
                .contentShape(Rectangle())
            Text(title)
                .sk1Text(SK1.TypeScale.caption, scalesWith: .caption2, cap: .accessibility1)
                .foregroundStyle(Color(sk1Hex: p.ink))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 4)
            // A blank legend keeps tiles with and without one the same height.
            Text(legend ?? " ")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(sk1Hex: p.inkSoft))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 1)
        }
        .frame(maxWidth: .infinity)
        .opacity(isEnabled ? 1 : 0.4)
        .transaction { $0.animation = nil }
        .sk1PressFeedback(pressed)
    }

    /// The shadow the key casts, the key (corner radius 7) and its lamp.
    static func draw(_ ctx: GraphicsContext, _ rect: CGRect, colors c: SK1Draw.KeyColors, variant: SK1KeyVariant, down: Bool,
                     lampLit: Bool) {
        let skirt = SK1.Metrics.keySkirt
        let radius = SK1.Metrics.keyRadius + 1
        let shadowRect = down ? rect.insetBy(dx: 0, dy: skirt / 2) : rect
        SK1Draw.castShadow(ctx, SK1Draw.roundedRect(shadowRect, radius), color: c.shadow,
                           opacity: down ? c.shadowAlpha * 1.3 : c.shadowAlpha,
                           radius: down ? 1 : (variant == .orange ? 3.5 : 2), y: down ? 1 : 2)
        let face = SK1Draw.key(ctx, in: rect, radius: radius, colors: c, down: down)
        SK1Draw.lamp(ctx, in: CGRect(x: face.maxX - 10, y: face.minY + 5, width: 4, height: 4),
                     color: variant == .orange ? .white : Color(sk1Hex: SK1.teal), lit: lampLit)
    }
}

/// A small key with its symbol on a 26 pt key and a short caption under it (Skreener's `LauncherKey`), for trays of
/// secondary actions; it fills the width it is given. While the pointer is over it the key sinks. With `lamp`, a key
/// that turns something on and off has a small red lamp in its corner, lit while `lamp` is true.
///
/// ```swift
/// SKKeyGroup(caption: "Tools") {
///     SKCaptionedKey("Draw", systemImage: "scribble.variable") { draw() }
///     SKCaptionedKey("Watch", systemImage: "eye", lamp: watching) { toggleWatch() }
///     SKCaptionedKey("Quit", systemImage: "power", variant: .charcoal) { quit() }
/// }
/// ```
public struct SKCaptionedKey: View {
    private let caption: String
    private let systemImage: String
    private let variant: SK1KeyVariant
    private let lamp: Bool?
    private let onHover: ((Bool) -> Void)?
    private let action: () -> Void
    @State private var hovering = false

    public init(_ caption: String, systemImage: String, variant: SK1KeyVariant = .cream, lamp: Bool? = nil,
                onHover: ((Bool) -> Void)? = nil, action: @escaping () -> Void) {
        self.caption = caption
        self.systemImage = systemImage
        self.variant = variant
        self.lamp = lamp
        self.onHover = onHover
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage).font(.system(size: 12, weight: .medium))
        }
        .buttonStyle(SK1CaptionedKeyButtonStyle(caption: caption, variant: variant, hovering: hovering, lamp: lamp))
        .onHover { inside in
            hovering = inside
            onHover?(inside)
        }
        .accessibilityLabel(Text(caption))
        .accessibilityValue(Text(lamp.map { $0 ? "On" : "Off" } ?? ""))
    }
}

struct SK1CaptionedKeyButtonStyle: ButtonStyle {
    let caption: String
    let variant: SK1KeyVariant
    let hovering: Bool
    let lamp: Bool?

    func makeBody(configuration: Configuration) -> some View {
        SK1CaptionedKeyBody(label: configuration.label, caption: caption, variant: variant,
                            down: configuration.isPressed || hovering, lamp: lamp, pressed: configuration.isPressed)
    }
}

struct SK1CaptionedKeyBody<Content: View>: View {
    let label: Content
    let caption: String
    let variant: SK1KeyVariant
    let down: Bool
    let lamp: Bool?
    let pressed: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    /// Skreener's `LauncherKey.keyHeight`.
    static var keyHeight: CGFloat { SK1.Metrics.popUpHeight }

    var body: some View {
        let p = SK1.palette(for: scheme)
        let colors = SK1Draw.keyColors(variant, p)
        let skirt = SK1.Metrics.keySkirt
        VStack(spacing: 2) {
            label
                .foregroundStyle(colors.ink)
                .offset(y: down ? skirt / 2 : -skirt / 2)
                .frame(maxWidth: .infinity, minHeight: Self.keyHeight, maxHeight: Self.keyHeight)
                .background(SK1Canvas(outset: 8) { ctx, rect, _ in
                    let shadowRect = down ? rect.insetBy(dx: 0, dy: skirt / 2) : rect
                    SK1Draw.castShadow(ctx, SK1Draw.roundedRect(shadowRect, SK1.Metrics.keyRadius), color: colors.shadow,
                                       opacity: down ? colors.shadowAlpha * 1.3 : colors.shadowAlpha,
                                       radius: down ? 1 : 2, y: down ? 1 : 2)
                    let face = SK1Draw.key(ctx, in: rect, radius: SK1.Metrics.keyRadius, colors: colors, down: down)
                    if let lamp {
                        SK1Draw.lamp(ctx, in: CGRect(x: face.maxX - 8, y: face.minY + 4, width: 4, height: 4),
                                     color: Color(sk1Hex: SK1.recRed), lit: lamp)
                    }
                })
                .contentShape(Rectangle())
            // Skreener: 8 pt semibold, tracked 0.4, made smaller until it fits the key.
            Text(caption.uppercased())
                .font(.system(size: 8, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(Color(sk1Hex: p.ink))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .opacity(isEnabled ? 1 : 0.4)
        .transaction { $0.animation = nil }
        .sk1PressFeedback(pressed)
    }
}

/// A full-width tray of keys with an optional caption over it (the launcher's trays): the keys share the width
/// equally, 4 pt apart, 6 pt inside a well of radius 8. Made for `SKCaptionedKey` and `SKTile`, which fill their share.
///
/// ```swift
/// SKKeyGroup(caption: "Help") {
///     SKCaptionedKey("Keys", systemImage: "command") { }
///     SKCaptionedKey("About", systemImage: "info.circle") { }
/// }
/// ```
public struct SKKeyGroup<Keys: View>: View {
    private let caption: String?
    private let keys: Keys

    public init(caption: String? = nil, @ViewBuilder keys: () -> Keys) {
        self.caption = caption
        self.keys = keys()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let caption {
                SKCaption(caption, tone: .soft)
                    .padding(.leading, 2)
                    .accessibilityAddTraits(.isHeader)
            }
            SKWell(radius: 8) {
                HStack(alignment: .top, spacing: 4) { keys }
                    .padding(6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}

/// A slim strip of LCD glass (Skreener's `LauncherLCD`): a title as a heavy caption at the left and a detail in mono at
/// the right, with an optional lamp before the detail (no glow, as on any glass). 24 pt tall by default. Show the
/// resting text ("MEETBALL", "v1.2 · UP TO DATE") and swap in the name and shortcut of the key under the pointer.
///
/// ```swift
/// SKStatusStrip(title: hovered?.name ?? "Skreener", detail: hovered?.shortcut ?? "v1.18.0 · UP TO DATE")
/// ```
public struct SKStatusStrip: View {
    private let title: String
    private let detail: String
    private let lamp: SKLampColor?
    private let emphasized: Bool
    private let height: CGFloat

    /// `emphasized` sets the detail in bold at full strength (news, as Skreener's "UPDATE 1.12.0").
    public init(title: String, detail: String = "", lamp: SKLampColor? = nil, emphasized: Bool = false, height: CGFloat = 24) {
        self.title = title
        self.detail = detail
        self.lamp = lamp
        self.emphasized = emphasized
        self.height = height
    }

    public var body: some View {
        let ink = Color(sk1Hex: SK1.lcdInk)
        HStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9.5, weight: .heavy))
                .tracking(1.1)
                .foregroundStyle(ink)
                .lineLimit(1)
            Spacer(minLength: 8)
            if let lamp {
                SKLampDot(color: lamp.color, lit: true, unlit: nil, glow: 0, size: 6)
            }
            Text(detail)
                .font(.system(size: 10, weight: emphasized ? .bold : .semibold, design: .monospaced))
                .foregroundStyle(ink.opacity(emphasized ? 1 : 0.8))
                .lineLimit(1)
                .truncationMode(.head)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(SK1Canvas { ctx, rect, p in
            SK1Draw.glass(ctx, rect, radius: 6, brightness: p.lcdBrightness, shadowBlur: 3)
        })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(detail.isEmpty ? title : "\(title), \(detail)"))
    }
}
#endif
