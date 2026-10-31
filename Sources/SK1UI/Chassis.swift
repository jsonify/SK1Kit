#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

extension View {
    /// Puts the SK-1 chassis behind the view, filling the safe area: the chassis colour with a soft white glow
    /// across the top, an ellipse 1.6 times the width and min(height, 600) × 0.5 deep (Skreener's `ChassisView`).
    ///
    /// ```swift
    /// ContentView().sk1Chassis()
    /// ```
    public func sk1Chassis() -> some View {
        background(SK1ChassisBackground().ignoresSafeArea())
    }
}

/// The chassis fill and its top glow.
struct SK1ChassisBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = SK1.palette(for: scheme)
        Canvas { ctx, size in
            let rect = CGRect(origin: .zero, size: size)
            ctx.fill(Path(rect), with: .color(Color(sk1Hex: p.chassis)))
            SK1Draw.glow(ctx, center: CGPoint(x: rect.midX, y: rect.minY), rx: rect.width * 0.8,
                         ry: min(rect.height, 600) * 0.5, alpha: p.chassisGlow)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A chassis plate with rounded corners behind `content`: the chassis colour and its top glow with a hairline edge,
/// for a floating bar or a card (Skreener's `Retro.drawPlate` / `ChassisPlate`). It does not pad its content.
///
/// ```swift
/// SKPlate { controls.padding(12) }
/// ```
public struct SKPlate<Content: View>: View {
    private let radius: CGFloat
    private let content: Content

    public init(radius: CGFloat = SK1.Metrics.plateRadius, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.content = content()
    }

    public var body: some View {
        content.background(SK1Canvas { ctx, rect, p in SK1Draw.plate(ctx, rect, radius: radius, palette: p) })
    }
}

/// A sunken tray behind `content`: a floor from the palette's `wellTop` to `wellBottom`, a 2 pt inner shadow under
/// its top edge and a light lip along its bottom (Skreener's `Retro.drawWell` / `RetroWell`). As `RetroWell`, it is
/// drawn 0.5 pt inside the view at the top and bottom, the lip in the bottom point. It does not pad its content.
///
/// ```swift
/// SKWell { rows.padding(14) }
/// ```
public struct SKWell<Content: View>: View {
    private let radius: CGFloat
    private let content: Content

    public init(radius: CGFloat = SK1.Metrics.wellRadius, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.content = content()
    }

    public var body: some View {
        content.background(SK1Canvas { ctx, rect, p in
            SK1Draw.well(ctx, rect.insetBy(dx: 0, dy: 0.5), radius: radius, palette: p)
        })
    }
}

/// A groove in the chassis: a 1 pt rule in the groove colour with a light line beside it, 2 pt in all. Across
/// (between rows) by default, or down (beside a sidebar) (Skreener's `RetroGroove`).
///
/// ```swift
/// SKGroove()            // across
/// SKGroove(.vertical)   // down
/// ```
public struct SKGroove: View {
    private let axis: Axis

    public init(_ axis: Axis = .horizontal) { self.axis = axis }

    public var body: some View {
        let vertical = axis == .vertical
        SK1Canvas { ctx, rect, p in
            let line = vertical ? CGRect(x: rect.minX, y: rect.minY, width: 1, height: rect.height)
                : CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 1)
            let lip = vertical ? line.offsetBy(dx: 1, dy: 0) : line.offsetBy(dx: 0, dy: 1)
            ctx.fill(Path(line), with: .color(Color(sk1Hex: p.groove)))
            ctx.fill(Path(lip), with: .color(.white.opacity(p.grooveLip)))
        }
        .frame(width: vertical ? 2 : nil, height: vertical ? nil : 2)
        .frame(maxWidth: vertical ? nil : .infinity, maxHeight: vertical ? .infinity : nil)
    }
}
#endif
