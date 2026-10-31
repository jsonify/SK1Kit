#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// A lamp's colour and the name VoiceOver gives it when the lamp has no label of its own.
public struct SKLampColor: Sendable {
    public var color: Color
    public var name: String

    public init(_ color: Color, name: String) {
        self.color = color
        self.name = name
    }

    /// Teal: a key under the pointer, ready.
    public static let teal = SKLampColor(Color(sk1Hex: SK1.teal), name: "Teal lamp")
    /// The REC lamp's red.
    public static let red = SKLampColor(Color(sk1Hex: SK1.recRed), name: "Red lamp")
    /// What is on.
    public static let orange = SKLampColor(Color(sk1Hex: SK1.orange), name: "Orange lamp")
    /// All is well: teal.
    public static let success = SKLampColor(Color(sk1Hex: SK1.teal), name: "Ready")
    /// Needs a look: amber (`SK1.amber`, from Minits).
    public static let warning = SKLampColor(Color(sk1Hex: SK1.amber), name: "Warning")
    /// Something is wrong: the REC red.
    public static let danger = SKLampColor(Color(sk1Hex: SK1.recRed), name: "Error")
}

/// A small round lamp (Skreener's `Retro.drawLamp`): lit, its colour with a glow `glow` wide (0 for none, as on the
/// LCD's glass); unlit, a faint dark dot. With `blinking`, a lit lamp blinks once a second, lit for the first half
/// (`SK1.blinkLit`); Reduce Motion keeps it lit. VoiceOver reads "Label: on" or "Label: off", the label being the
/// colour's name unless given.
///
/// ```swift
/// SKLamp(color: .danger, lit: isRecording, label: "Recording", blinking: true)
/// ```
public struct SKLamp: View {
    private let color: SKLampColor
    private let lit: Bool
    private let glow: CGFloat
    private let size: CGFloat
    private let label: String?
    private let blinking: Bool

    public init(color: SKLampColor = .teal, lit: Bool, glow: CGFloat = 4, size: CGFloat = 6, label: String? = nil,
                blinking: Bool = false) {
        self.color = color
        self.lit = lit
        self.glow = glow
        self.size = size
        self.label = label
        self.blinking = blinking
    }

    public var body: some View {
        SK1BlinkingLamp(blinking: blinking && lit) { phase in
            SKLampDot(color: color.color, lit: lit && phase, unlit: nil, glow: glow, size: size)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(SK1.Format.stateLabel(label ?? self.color.name, on: lit)))
    }
}

/// The lamp's dot, `size` across, its glow free to fall outside it.
struct SKLampDot: View {
    let color: Color
    let lit: Bool
    let unlit: Color?
    let glow: CGFloat
    let size: CGFloat

    var body: some View {
        Color.clear
            .frame(width: size, height: size)
            .background(SK1Canvas(outset: glow + 2) { ctx, rect, _ in
                SK1Draw.lamp(ctx, in: rect, color: color, lit: lit, unlit: unlit, glow: glow)
            })
            .accessibilityHidden(true)
    }
}

/// Gives `content` whether a blinking lamp is lit now: while `blinking`, on a half-second timeline from when it
/// started (`SK1.blinkLit`); otherwise, or with Reduce Motion, always lit.
struct SK1BlinkingLamp<Content: View>: View {
    let blinking: Bool
    let content: (Bool) -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var since = Date()

    init(blinking: Bool, @ViewBuilder content: @escaping (Bool) -> Content) {
        self.blinking = blinking
        self.content = content
    }

    var body: some View {
        Group {
            if blinking && !reduceMotion {
                TimelineView(.periodic(from: since, by: 0.5)) { timeline in
                    content(SK1.blinkLit(timeline.date.timeIntervalSince(since)))
                }
            } else {
                content(true)
            }
        }
        .onChange(of: blinking) { _, isBlinking in
            if isBlinking { self.since = Date() }
        }
    }
}
#endif
