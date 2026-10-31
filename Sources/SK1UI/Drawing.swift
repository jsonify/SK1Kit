#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// The three kinds of key, and the small round one.
public enum SK1KeyVariant: Sendable, Hashable {
    /// The usual key.
    case cream
    /// The main action (at most one per screen).
    case orange
    /// A key apart from the rest (Settings).
    case charcoal
    /// A small round cream key, for a symbol (a stepper's arrows); Skreener's `PillButton` `.round`.
    case round
}

/// Ports of Skreener's `Retro.draw…` functions (`Retro.swift`) from AppKit to a SwiftUI `GraphicsContext`. The maths
/// is the same; SwiftUI's y runs down, so each is the AppKit code's `flipped` branch. An `NSShadow`'s blur becomes
/// a SwiftUI shadow radius of half of it; a layer's `shadowRadius` is used as it is.
enum SK1Draw {
    /// A rounded rectangle with circular corners, the corner no larger than half a side (as `NSBezierPath`'s).
    static func roundedRect(_ r: CGRect, _ radius: CGFloat) -> Path {
        let corner = max(min(radius, r.width / 2, r.height / 2), 0)
        return Path(roundedRect: r, cornerRadius: corner, style: .circular)
    }

    /// The SwiftUI shadow radius for an `NSShadow` blur.
    static func radius(blur: CGFloat) -> CGFloat { blur / 2 }

    /// Fills `path` with a gradient from `top` to `bottom` across its bounds (`Retro.fill`).
    static func fill(_ ctx: GraphicsContext, _ path: Path, top: Color, bottom: Color) {
        let b = path.boundingRect
        ctx.fill(path, with: .linearGradient(Gradient(colors: [top, bottom]), startPoint: CGPoint(x: b.midX, y: b.minY),
                                             endPoint: CGPoint(x: b.midX, y: b.maxY)))
    }

    /// The ends of a linear gradient at `degrees` (0 left to right, 90 top to bottom) that covers `rect`, as
    /// `NSGradient.draw(in:angle:)` places them.
    static func ends(of rect: CGRect, degrees: CGFloat) -> (CGPoint, CGPoint) {
        let a = degrees * .pi / 180, dx = cos(a), dy = sin(a)
        let half = abs(rect.width / 2 * dx) + abs(rect.height / 2 * dy)
        let c = CGPoint(x: rect.midX, y: rect.midY)
        return (CGPoint(x: c.x - dx * half, y: c.y - dy * half), CGPoint(x: c.x + dx * half, y: c.y + dy * half))
    }

    /// A shadow inside `path`, as if its edge stood above what is in it; `offset` is how far down it falls
    /// (`Retro.innerShadow`).
    static func innerShadow(_ ctx: GraphicsContext, _ path: Path, alpha: CGFloat, blur: CGFloat, offset: CGFloat = 1) {
        guard alpha > 0 else { return }
        var c = ctx
        c.clip(to: path)
        c.addFilter(.shadow(color: .black.opacity(alpha), radius: radius(blur: blur), x: 0, y: offset))
        var ring = Path(path.boundingRect.insetBy(dx: -20, dy: -20))
        ring.addPath(path)
        c.fill(ring, with: .color(.black), style: FillStyle(eoFill: true))
    }

    /// Only the shadow `path` casts, as a layer shadow with a `shadowPath` (the keys').
    static func castShadow(_ ctx: GraphicsContext, _ path: Path, color: Color, opacity: Double, radius: CGFloat, y: CGFloat) {
        guard opacity > 0 else { return }
        var c = ctx
        c.addFilter(.shadow(color: color.opacity(opacity), radius: radius, x: 0, y: y, options: .shadowOnly))
        c.fill(path, with: .color(.black))
    }

    /// A sunken tray in `rect`: a floor from `top` to `bottom`, an inner shadow under its top edge, and a light lip
    /// along its bottom, drawn 1 pt below `rect` (`Retro.drawWell`).
    static func well(_ ctx: GraphicsContext, _ rect: CGRect, radius: CGFloat, top: Color, bottom: Color, shadow: CGFloat,
                     lip: CGFloat) {
        if lip > 0 {
            ctx.fill(roundedRect(rect.offsetBy(dx: 0, dy: 1), radius), with: .color(.white.opacity(lip)))
        }
        let path = roundedRect(rect, radius)
        fill(ctx, path, top: top, bottom: bottom)
        innerShadow(ctx, path, alpha: shadow, blur: 2)
    }

    /// `well` in the palette's tray colours.
    static func well(_ ctx: GraphicsContext, _ rect: CGRect, radius: CGFloat, palette p: SK1.Palette) {
        well(ctx, rect, radius: radius, top: Color(sk1Hex: p.wellTop), bottom: Color(sk1Hex: p.wellBottom),
             shadow: p.wellShadow, lip: p.wellLip)
    }

    /// What a key is drawn with (`Retro.KeyColors`).
    struct KeyColors {
        var top: Color, bottom: Color, downTop: Color, downBottom: Color, skirt: Color
        /// The light along the face's top edge.
        var highlight: Color
        /// The symbol and title; the legend.
        var ink: Color, legend: Color
        /// The shadow under the key.
        var shadow: Color, shadowAlpha: Double
    }

    /// `Retro.keyColors`; the round key is cream.
    static func keyColors(_ variant: SK1KeyVariant, _ p: SK1.Palette) -> KeyColors {
        switch variant {
        case .cream, .round:
            return KeyColors(top: Color(sk1Hex: p.keyTop), bottom: Color(sk1Hex: p.keyBottom),
                             downTop: Color(sk1Hex: p.keyDownTop), downBottom: Color(sk1Hex: p.keyDownBottom),
                             skirt: Color(sk1Hex: p.keySkirt), highlight: .white.opacity(p.keyHighlight),
                             ink: Color(sk1Hex: p.keyInk), legend: Color(sk1Hex: p.inkSoft), shadow: .black,
                             shadowAlpha: p.keyShadow)
        case .orange:
            let top = Color(sk1Hex: SK1.orangeTop), bottom = Color(sk1Hex: SK1.orangeBottom)
            return KeyColors(top: top, bottom: bottom, downTop: bottom, downBottom: top, skirt: Color(sk1Hex: SK1.orangeSkirt),
                             highlight: .white.opacity(0.35), ink: .white, legend: .white.opacity(0.8), shadow: bottom,
                             shadowAlpha: p.dark ? 0.5 : 0.35)
        case .charcoal:
            let top = Color(sk1Hex: p.charcoalTop), bottom = Color(sk1Hex: p.charcoalBottom)
            return KeyColors(top: top, bottom: bottom, downTop: bottom, downBottom: top, skirt: Color(sk1Hex: p.charcoalSkirt),
                             highlight: .white.opacity(0.12), ink: Color(sk1Hex: SK1.charcoalInk),
                             legend: Color(sk1Hex: SK1.charcoalInk, opacity: 0.7), shadow: .black,
                             shadowAlpha: p.dark ? 0.6 : 0.3)
        }
    }

    /// Where a key's face is in `bounds`: all but the bottom `skirt`, or (pressed) moved down onto it
    /// (`Retro.keyFace`).
    static func keyFace(in bounds: CGRect, skirt: CGFloat = SK1.Metrics.keySkirt, down: Bool) -> CGRect {
        CGRect(x: bounds.minX, y: down ? bounds.minY + skirt : bounds.minY, width: bounds.width, height: bounds.height - skirt)
    }

    /// A raised key filling `bounds`: a face from top to bottom with a light top edge and a hairline, standing on a
    /// `skirt` of darker colour; pressed (`down`), the face sits on the skirt and is lit from below. Returns the face
    /// (`Retro.drawKey`). The shadow it casts is the caller's.
    @discardableResult
    static func key(_ ctx: GraphicsContext, in bounds: CGRect, radius: CGFloat, colors c: KeyColors, down: Bool,
                    skirt: CGFloat = SK1.Metrics.keySkirt) -> CGRect {
        let face = keyFace(in: bounds, skirt: skirt, down: down)
        if !down {
            ctx.fill(roundedRect(face.offsetBy(dx: 0, dy: skirt), radius), with: .color(c.skirt))
        }
        let facePath = roundedRect(face, radius)
        var inner = ctx
        inner.clip(to: facePath)
        // The light edge: the highlight, with the face drawn over it 1 pt lower.
        inner.fill(facePath, with: .color(c.highlight))
        fill(inner, roundedRect(face.offsetBy(dx: 0, dy: 1), radius), top: down ? c.downTop : c.top,
             bottom: down ? c.downBottom : c.bottom)
        ctx.stroke(roundedRect(face.insetBy(dx: 0.25, dy: 0.25), radius), with: .color(.black.opacity(0.12)), lineWidth: 0.5)
        return face
    }

    /// The short glowing orange bar at the bottom of the selected key's face (`Retro.drawOnBar`).
    static func onBar(_ ctx: GraphicsContext, in face: CGRect) {
        let w = min(10, face.width / 2), h: CGFloat = 2
        let bar = roundedRect(CGRect(x: face.midX - w / 2, y: face.maxY - 3 - h, width: w, height: h), 1)
        let orange = Color(sk1Hex: SK1.orange)
        var c = ctx
        c.addFilter(.shadow(color: orange, radius: radius(blur: 4)))
        c.fill(bar, with: .color(orange))
    }

    /// LCD glass in `rect`: olive, darker toward the bottom (dimmed by `brightness`), an inner shadow and dark edge,
    /// a sheen at the top left and a faint pixel grid (`Retro.drawGlass`).
    static func glass(_ ctx: GraphicsContext, _ rect: CGRect, radius: CGFloat, top: UInt32 = SK1.glassTop,
                      middle: UInt32 = SK1.glassMiddle, bottom: UInt32 = SK1.glassBottom, brightness: CGFloat,
                      grid: Bool = true, shadowBlur: CGFloat = 4, shadowOffset: CGFloat = 2) {
        let glass = roundedRect(rect, radius)
        // Skreener's gradient runs from the bottom up with stops at 0, 0.4 and 1: top down, 0, 0.6 and 1.
        let stops = [Gradient.Stop(color: Color(sk1Hex: top, brightness: brightness), location: 0),
                     Gradient.Stop(color: Color(sk1Hex: middle, brightness: brightness), location: 0.6),
                     Gradient.Stop(color: Color(sk1Hex: bottom, brightness: brightness), location: 1)]
        ctx.fill(glass, with: .linearGradient(Gradient(stops: stops), startPoint: CGPoint(x: rect.midX, y: rect.minY),
                                              endPoint: CGPoint(x: rect.midX, y: rect.maxY)))
        var c = ctx
        c.clip(to: glass)
        // The sheen: white 0.2 to clear over the first 0.4, at 80° (down and a little right) from the top left.
        let (start, end) = ends(of: glass.boundingRect, degrees: 80)
        let sheen = Gradient(stops: [Gradient.Stop(color: .white.opacity(0.2), location: 0),
                                     Gradient.Stop(color: .white.opacity(0), location: 0.4)])
        c.fill(glass, with: .linearGradient(sheen, startPoint: start, endPoint: end))
        if grid {
            var rows = Path()
            var y = rect.minY
            while y < rect.maxY { rows.addRect(CGRect(x: rect.minX, y: y, width: rect.width, height: 1)); y += 2 }
            c.fill(rows, with: .color(.black.opacity(0.025)))
            var columns = Path()
            var x = rect.minX
            while x < rect.maxX { columns.addRect(CGRect(x: x, y: rect.minY, width: 1, height: rect.height)); x += 2 }
            c.fill(columns, with: .color(.black.opacity(0.02)))
        }
        innerShadow(ctx, glass, alpha: 0.28, blur: shadowBlur, offset: shadowOffset)
        ctx.stroke(roundedRect(rect.insetBy(dx: 0.5, dy: 0.5), max(radius - 0.5, 0)), with: .color(.black.opacity(0.25)),
                   lineWidth: 1)
    }

    /// A small LCD chip's glass in `rect`: lighter than the display's, with no pixel grid and a shallower shadow
    /// (`Retro.drawChipGlass`).
    static func chipGlass(_ ctx: GraphicsContext, _ rect: CGRect, radius: CGFloat, brightness: CGFloat) {
        glass(ctx, rect, radius: radius, top: SK1.chipTop, middle: SK1.chipMiddle, bottom: SK1.chipBottom,
              brightness: brightness, grid: false, shadowBlur: 2, shadowOffset: 1)
    }

    /// An LCD in `rect`: the sunken bezel (its light lip drawn 1 pt below `rect`) and the olive glass `inset` inside
    /// it. Returns the glass (`Retro.drawLCD`).
    @discardableResult
    static func lcd(_ ctx: GraphicsContext, in rect: CGRect, radius: CGFloat = SK1.Metrics.lcdRadius,
                    inset: CGFloat = SK1.Metrics.lcdInset, palette p: SK1.Palette) -> CGRect {
        well(ctx, rect, radius: radius, top: Color(sk1Hex: p.bezelTop), bottom: Color(sk1Hex: p.bezelBottom), shadow: 0.18,
             lip: p.wellLip)
        let glassRect = rect.insetBy(dx: inset, dy: inset)
        glass(ctx, glassRect, radius: glassRadius(radius: radius, inset: inset), brightness: p.lcdBrightness)
        return glassRect
    }

    /// The glass's corner in an LCD whose bezel has `radius` and sits `inset` round it.
    static func glassRadius(radius: CGFloat, inset: CGFloat) -> CGFloat { max(radius - inset + 1, 3) }

    /// The white glow across the top of the chassis: an ellipse `rx` by `ry` round `center`, white `alpha` in the
    /// middle fading to clear at its edge.
    static func glow(_ ctx: GraphicsContext, center: CGPoint, rx: CGFloat, ry: CGFloat, alpha: CGFloat) {
        guard rx > 0, ry > 0, alpha > 0 else { return }
        var c = ctx
        c.translateBy(x: center.x, y: center.y)
        c.scaleBy(x: rx, y: ry)
        c.fill(Path(ellipseIn: CGRect(x: -1, y: -1, width: 2, height: 2)),
               with: .radialGradient(Gradient(colors: [.white.opacity(alpha), .white.opacity(0)]), center: .zero,
                                     startRadius: 0, endRadius: 1))
    }

    /// A chassis plate in `rect` with rounded corners: the chassis colour with the white glow across its top (an
    /// ellipse 1.6 times as wide as the plate, 0.8 of its height deep up to 600 pt), and a hairline edge; a square
    /// plate (`radius` 0) gets none (`Retro.drawPlate`).
    static func plate(_ ctx: GraphicsContext, _ rect: CGRect, radius: CGFloat, palette p: SK1.Palette) {
        let shape = roundedRect(rect, radius)
        var c = ctx
        c.clip(to: shape)
        c.fill(Path(rect), with: .color(Color(sk1Hex: p.chassis)))
        glow(c, center: CGPoint(x: rect.midX, y: rect.minY), rx: rect.width * 0.8, ry: max(min(rect.height, 600), 1) * 0.8,
             alpha: p.chassisGlow)
        guard radius > 0 else { return }
        ctx.stroke(roundedRect(rect.insetBy(dx: 0.25, dy: 0.25), radius), with: .color(.black.opacity(p.dark ? 0.55 : 0.25)),
                   lineWidth: 0.5)
    }

    /// A small round lamp in `rect`: lit, `color` with a glow `glow` wide (0 for none, e.g. on the LCD's glass);
    /// unlit, `unlit` (by default a faint dark dot) (`Retro.drawLamp`).
    static func lamp(_ ctx: GraphicsContext, in rect: CGRect, color: Color, lit: Bool, unlit: Color? = nil, glow: CGFloat = 4) {
        let dot = Path(ellipseIn: rect)
        guard lit else {
            ctx.fill(dot, with: .color(unlit ?? .black.opacity(0.14)))
            return
        }
        var c = ctx
        if glow > 0 { c.addFilter(.shadow(color: color, radius: radius(blur: glow))) }
        c.fill(dot, with: .color(color))
    }

    /// A toggle's square (9 pt): orange while `on`, the palette's off colour otherwise, with a light top edge and a
    /// hairline (`Retro.drawToggleSquare`).
    static func toggleSquare(_ ctx: GraphicsContext, _ square: CGRect, on: Bool, palette p: SK1.Palette) {
        let path = roundedRect(square, SK1.Metrics.toggleSquareRadius)
        ctx.fill(path, with: .color(Color(sk1Hex: on ? SK1.orange : p.toggleOff)))
        var c = ctx
        c.clip(to: path)
        c.fill(Path(CGRect(x: square.minX, y: square.minY, width: square.width, height: 1)), with: .color(.white.opacity(0.35)))
        ctx.stroke(path, with: .color(.black.opacity(0.25)), lineWidth: 0.5)
    }
}

/// A `Canvas` in the environment's palette behind a view, `outset` larger all round than the view (for shadows and
/// glows that fall outside it). `draw` gets the view's own rect within the canvas. It takes no clicks and is hidden
/// from accessibility.
struct SK1Canvas: View {
    var outset: CGFloat = 0
    let draw: (GraphicsContext, CGRect, SK1.Palette) -> Void
    @Environment(\.colorScheme) private var scheme

    init(outset: CGFloat = 0, draw: @escaping (GraphicsContext, CGRect, SK1.Palette) -> Void) {
        self.outset = outset
        self.draw = draw
    }

    var body: some View {
        let p = SK1.palette(for: scheme)
        Canvas { ctx, size in
            let rect = CGRect(x: outset, y: outset, width: max(size.width - 2 * outset, 0), height: max(size.height - 2 * outset, 0))
            draw(ctx, rect, p)
        }
        .padding(-outset)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A button style that shows its label as it is, for controls that draw their own pressed state.
struct SK1PlainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label }
}
#endif
