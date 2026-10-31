#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// The SK-1 toggle (Skreener's `PillButton` `.toggle`, drawn by `Retro.drawToggleSquare`): a 9 pt square, orange while
/// on, and the label as an upper-case caption, ink while on and soft ink while off, in a row 20 pt tall.
///
/// ```swift
/// Toggle("Mic", isOn: $mic).toggleStyle(.sk1Square)
/// ```
public struct SK1SquareToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View { SK1SquareToggle(configuration: configuration) }
}

extension ToggleStyle where Self == SK1SquareToggleStyle {
    /// The orange-square toggle with a caption; see `SK1SquareToggleStyle`.
    public static var sk1Square: SK1SquareToggleStyle { SK1SquareToggleStyle() }
}

struct SK1SquareToggle: View {
    let configuration: ToggleStyleConfiguration
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let p = SK1.palette(for: scheme)
        let on = configuration.isOn
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 5) {
                SK1SquareIndicator(on: on)
                    .padding(.leading, 1)
                configuration.label
                    .sk1Text(SK1.TypeScale.indicator, scalesWith: .caption2, cap: .accessibility1)
                    .foregroundStyle(Color(sk1Hex: on ? p.ink : p.inkSoft))
                    .lineLimit(1)
            }
            .frame(minHeight: SK1.Metrics.toggleHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(SK1PlainButtonStyle())
        .opacity(isEnabled ? 1 : 0.4)
        .sk1MinimumHitArea(width: 44, height: SK1.Metrics.toggleHeight)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }.toggleStyle(.automatic)
        }
    }
}

/// The toggle's square alone.
struct SK1SquareIndicator: View {
    let on: Bool

    var body: some View {
        Color.clear
            .frame(width: SK1.Metrics.toggleSquare, height: SK1.Metrics.toggleSquare)
            .background(SK1Canvas(outset: 1) { ctx, rect, p in SK1Draw.toggleSquare(ctx, rect, on: on, palette: p) })
    }
}

/// A toggle's look that only shows a state (Skreener's `RetroIndicator`): the square and an upper-case caption.
/// VoiceOver reads "Title: on".
///
/// ```swift
/// SKIndicator("Mic", isOn: recordsMic)
/// ```
public struct SKIndicator: View {
    private let title: String
    private let isOn: Bool
    @Environment(\.colorScheme) private var scheme

    public init(_ title: String, isOn: Bool) {
        self.title = title
        self.isOn = isOn
    }

    public var body: some View {
        let p = SK1.palette(for: scheme)
        HStack(spacing: 5) {
            SK1SquareIndicator(on: isOn)
            Text(title)
                .sk1Text(SK1.TypeScale.indicator, scalesWith: .caption2, cap: .accessibility1)
                .foregroundStyle(Color(sk1Hex: isOn ? p.ink : p.inkSoft))
                .lineLimit(1)
        }
        .frame(minHeight: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(SK1.Format.stateLabel(title, on: isOn)))
    }
}

/// An SK-1 on/off switch for a settings row (Skreener's `RetroSwitch`): a square cream key 34 × 24 pt with a lamp
/// in it, which stays down and glows orange while on. Only the key shows; the label is what VoiceOver reads, so put
/// the title in the row (`SKRow`).
///
/// ```swift
/// SKRow(title: "Launch at login") { Toggle("Launch at login", isOn: $launch).toggleStyle(.sk1Switch) }
/// ```
public struct SK1SwitchToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View { SK1Switch(configuration: configuration) }
}

extension ToggleStyle where Self == SK1SwitchToggleStyle {
    /// A square key with a lamp; see `SK1SwitchToggleStyle`.
    public static var sk1Switch: SK1SwitchToggleStyle { SK1SwitchToggleStyle() }
}

struct SK1Switch: View {
    let configuration: ToggleStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Color.clear.frame(width: 34, height: 24)
        }
        .buttonStyle(SK1SwitchButtonStyle(on: configuration.isOn))
        .opacity(isEnabled ? 1 : 0.4)
        .sk1MinimumHitArea(width: 34, height: 24)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }.toggleStyle(.automatic)
        }
    }
}

/// The switch's key, drawn pressed while on or held.
struct SK1SwitchButtonStyle: ButtonStyle {
    let on: Bool

    func makeBody(configuration: Configuration) -> some View {
        let down = on || configuration.isPressed
        configuration.label
            .background(SK1Canvas(outset: 6) { ctx, rect, p in
                let face = SK1Draw.key(ctx, in: rect.insetBy(dx: 1, dy: 0), radius: 5, colors: SK1Draw.keyColors(.cream, p),
                                       down: down)
                let square = CGRect(x: face.midX - 5, y: face.midY - 5, width: 10, height: 10)
                if on {
                    var c = ctx
                    c.addFilter(.shadow(color: Color(sk1Hex: SK1.orange, opacity: 0.8), radius: SK1Draw.radius(blur: 5)))
                    c.fill(SK1Draw.roundedRect(square, 2), with: .color(Color(sk1Hex: SK1.orange)))
                }
                SK1Draw.toggleSquare(ctx, square, on: on, palette: p)
            })
            .contentShape(Rectangle())
            .transaction { $0.animation = nil }
            .sk1PressFeedback(configuration.isPressed)
    }
}
#endif
