#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// An SK-1 knob (Skreener's `RetroKnob`): a round cream knob seen from above with ticks round it, lit orange up to the
/// value, the first and last values under it, and an LCD chip beside it showing the value. A click-stop knob clicks
/// between a few choices (`init(_:selection:stops:defaultValue:)`, with a charcoal pointer); a smooth one turns through
/// a range in steps (`init(_:value:in:step:defaultValue:format:)`, with an orange pointer). The arithmetic is
/// `SK1.KnobScale`.
///
/// Drag up or down to turn it; with the keyboard focus the arrow keys, Page Up / Down, Home and End turn it; a
/// double-click puts it back to its default. VoiceOver reads it as adjustable, with its name and value.
///
/// ```swift
/// SKKnob("Captures kept", selection: $kept, stops: [("25", 25), ("100", 100), ("All", 0)], defaultValue: 100)
/// SKKnob("Padding", value: $padding, in: 0...100, defaultValue: 0) { "\($0) pt" }
/// ```
public struct SKKnob: View {
    private let name: String
    private let scale: SK1.KnobScale
    private let position: () -> Int
    private let setPosition: (Int) -> Void
    private let defaultPosition: Int
    private let title: (Int) -> String
    /// The values the chip is sized for, so it doesn't change size as the knob turns.
    private let samples: [String]
    @State private var dragging = false
    @State private var lastY: CGFloat = 0
    @State private var carry: CGFloat = 0
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    /// The knob's face, the ring of ticks round its body (Skreener's `knobSize`).
    static let knobSize: CGFloat = 52
    /// From the knob to the chip; the right-hand end value may run into it.
    static let gap: CGFloat = 10
    /// The end values under the knob.
    static let scaleHeight: CGFloat = 11

    /// A click-stop knob for `stops` (what the chip shows, and the value), on `selection`; a double-click picks
    /// `defaultValue`.
    public init<Value: Hashable>(_ name: String, selection: Binding<Value>, stops: [(title: String, value: Value)],
                                 defaultValue: Value) {
        let scale = SK1.KnobScale(kind: .stops(count: stops.count))
        let values = stops.map { $0.value }
        let titles = stops.map { $0.title }
        self.name = name
        self.scale = scale
        position = { scale.clamp(values.firstIndex(of: selection.wrappedValue) ?? 0) }
        setPosition = { p in if values.indices.contains(p) { selection.wrappedValue = values[p] } }
        defaultPosition = scale.clamp(values.firstIndex(of: defaultValue) ?? 0)
        title = { titles.indices.contains($0) ? titles[$0] : "" }
        samples = titles
    }

    /// A smooth knob from the range's start to its end in steps of `step`, on `value`, showing values with `format`; a
    /// double-click goes back to `defaultValue`.
    public init(_ name: String, value: Binding<Int>, in range: ClosedRange<Int>, step: Int = 1, defaultValue: Int,
                format: @escaping (Int) -> String = { "\($0)" }) {
        let scale = SK1.KnobScale(kind: .smooth(min: range.lowerBound, max: range.upperBound, step: step))
        let title: (Int) -> String = { format(scale.value(at: $0)) }
        self.name = name
        self.scale = scale
        position = { scale.position(for: value.wrappedValue) }
        setPosition = { value.wrappedValue = scale.value(at: $0) }
        defaultPosition = scale.position(for: defaultValue)
        self.title = title
        samples = [title(0), title(scale.count - 1), title(scale.count / 2)]
    }

    public var body: some View {
        let at = position()
        HStack(alignment: .top, spacing: 0) {
            Canvas { ctx, _ in
                draw(ctx, palette: SK1.palette(for: scheme), position: at)
            }
            .frame(width: Self.knobSize + Self.gap, height: Self.knobSize + Self.scaleHeight)
            .contentShape(Rectangle())
            .gesture(drag)
            .onTapGesture(count: 2) { turn(to: defaultPosition) }
            chip(at).frame(height: Self.knobSize)
        }
        .opacity(isEnabled ? 1 : 0.4)
        .focusable(isEnabled)
        .onKeyPress(keys: [.upArrow, .rightArrow, .downArrow, .leftArrow, .pageUp, .pageDown, .home, .end]) { press in
            let page = scale.isSmooth ? max(scale.count / 10, 1) : 1
            switch press.key {
            case .upArrow, .rightArrow: turn(to: position() + 1)
            case .downArrow, .leftArrow: turn(to: position() - 1)
            case .pageUp: turn(to: position() + page)
            case .pageDown: turn(to: position() - page)
            case .home: turn(to: 0)
            case .end: turn(to: scale.count - 1)
            default: return .ignored
            }
            return .handled
        }
        .help(name)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(name))
        .accessibilityValue(Text(title(at)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: turn(to: position() + 1)
            case .decrement: turn(to: position() - 1)
            @unknown default: break
            }
        }
    }

    /// Up turns it up: one position per `SK1.KnobScale.dragPerPosition` points, carrying what is left over.
    private var drag: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { v in
                if !dragging {
                    dragging = true
                    lastY = 0
                    carry = 0
                }
                let dy = v.translation.height - lastY
                lastY = v.translation.height
                var left = carry
                let steps = scale.steps(forDrag: -dy, carry: &left)
                carry = left
                if steps != 0 { turn(to: position() + steps) }
            }
            .onEnded { _ in dragging = false }
    }

    private func turn(to p: Int) {
        let p = scale.clamp(p)
        if p != position() { setPosition(p) }
    }

    /// The value on chip glass in a sunken bezel, as wide as the widest sample.
    private func chip(_ at: Int) -> some View {
        ZStack {
            ForEach(Array(samples.enumerated()), id: \.offset) { _, s in Text(s.uppercased()).hidden() }
            Text(title(at).uppercased())
        }
        .font(.system(size: 11, weight: .semibold, design: .monospaced))
        .tracking(0.3)
        .foregroundStyle(Color(sk1Hex: SK1.lcdInk))
        .lineLimit(1)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .frame(minWidth: 64)
        .background(SK1Canvas(outset: 3) { ctx, rect, p in
            SK1Draw.well(ctx, rect.insetBy(dx: -2, dy: -2), radius: 6, top: Color(sk1Hex: p.bezelTop),
                         bottom: Color(sk1Hex: p.bezelBottom), shadow: 0.18, lip: p.wellLip)
            SK1Draw.chipGlass(ctx, rect, radius: 4, brightness: p.lcdBrightness)
        })
        .padding(2)
    }

    /// Skreener's `RetroKnob.draw`, y down.
    private func draw(_ ctx: GraphicsContext, palette p: SK1.Palette, position at: Int) {
        let size = Self.knobSize
        let knob = CGRect(x: 0, y: 0, width: size, height: size)
        let center = CGPoint(x: knob.midX, y: knob.midY)
        // The point `radius` from the centre at `angle` (degrees counter-clockwise from three o'clock).
        func point(_ angle: CGFloat, _ radius: CGFloat) -> CGPoint {
            let a = angle * .pi / 180
            return CGPoint(x: center.x + cos(a) * radius, y: center.y - sin(a) * radius)
        }

        // Ticks: lit orange up to the value.
        let f = scale.fraction(at)
        let tick: CGFloat = scale.isSmooth ? 1.4 : 2
        for t in scale.ticks {
            let c = point(SK1.KnobScale.startAngle - SK1.KnobScale.sweep * t, size / 2 - 2.5)
            let dot = CGRect(x: c.x - tick, y: c.y - tick, width: tick * 2, height: tick * 2)
            if t <= f + 0.0001 {
                SK1Draw.lamp(ctx, in: dot, color: Color(sk1Hex: SK1.orange), lit: true, glow: 3)
            } else {
                ctx.fill(Path(ellipseIn: dot), with: .color(Color(sk1Hex: p.inkSoft, opacity: 0.55)))
            }
        }

        // The knob: the shadow it casts and its skirt, the body, and the lighter top it turns by.
        let body = knob.insetBy(dx: 8, dy: 8)
        var shadowed = ctx
        shadowed.addFilter(.shadow(color: .black.opacity(p.keyShadow * 1.4), radius: SK1Draw.radius(blur: 4), x: 0, y: 3))
        shadowed.fill(Path(ellipseIn: body.offsetBy(dx: 0, dy: 2.5)), with: .color(Color(sk1Hex: p.keySkirt)))
        let bodyPath = Path(ellipseIn: body)
        SK1Draw.fill(ctx, bodyPath, top: Color(sk1Hex: p.keyTop), bottom: Color(sk1Hex: p.keyBottom))
        // The light along its upper rim, from 200° round the top to 340°.
        var rim = Path()
        let rimRadius = body.width / 2 - 0.75
        for (i, degrees) in stride(from: CGFloat(200), through: 340, by: 5).enumerated() {
            let a = degrees * .pi / 180
            let pt = CGPoint(x: center.x + cos(a) * rimRadius, y: center.y + sin(a) * rimRadius)
            if i == 0 { rim.move(to: pt) } else { rim.addLine(to: pt) }
        }
        ctx.stroke(rim, with: .color(.white.opacity(p.keyHighlight * 0.8)), lineWidth: 1)
        ctx.stroke(bodyPath, with: .color(.black.opacity(0.12)), lineWidth: 0.5)
        let top = Path(ellipseIn: body.insetBy(dx: 4, dy: 4))
        SK1Draw.fill(ctx, top, top: Color(sk1Hex: dragging ? p.keyDownBottom : p.keyDownTop),
                     bottom: Color(sk1Hex: dragging ? p.keyDownTop : p.keyTop))
        ctx.stroke(top, with: .color(.black.opacity(0.06)), lineWidth: 1)

        // The pointer: charcoal on a click-stop knob, orange on a smooth one.
        let angle = scale.angle(at)
        var line = Path()
        line.move(to: point(angle, 4))
        line.addLine(to: point(angle, body.width / 2 - 6))
        ctx.stroke(line, with: .color(Color(sk1Hex: scale.isSmooth ? SK1.orange : p.keyInk)),
                   style: StrokeStyle(lineWidth: 3, lineCap: .round))

        // The first and last values under the knob.
        for (end, x) in [(0, center.x - 22), (scale.count - 1, center.x + 22)] {
            let text = ctx.resolve(Text(title(end).uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .tracking(0.2)
                .foregroundStyle(Color(sk1Hex: p.inkSoft)))
            let measured = text.measure(in: CGSize(width: 200, height: 20))
            ctx.draw(text, at: CGPoint(x: max(x - measured.width / 2, 0), y: size - 1), anchor: .topLeading)
        }
    }
}
#endif
