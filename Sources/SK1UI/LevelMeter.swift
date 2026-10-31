#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// An input level meter on LCD glass (new for Minits; Skreener has none): one vertical bar per level (0 to 1, oldest
/// first), lit from the bottom in the LCD's ink to its level, the rest of the bar showing faintly as an unlit
/// seven-segment does (`SK1.SevenSegment.unlitOpacity`). Only the levels animate, and not with Reduce Motion.
/// 40 pt tall by default. VoiceOver reads the loudest level as a percentage.
///
/// ```swift
/// SKLevelMeter(levels: recorder.recentLevels)
/// ```
public struct SKLevelMeter: View {
    private let levels: [Float]
    private let height: CGFloat
    private let spacing: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(levels: [Float], height: CGFloat = 40, spacing: CGFloat = 2) {
        self.levels = levels
        self.height = height
        self.spacing = spacing
    }

    public var body: some View {
        let ink = Color(sk1Hex: SK1.lcdInk)
        SKLCD(radius: 7, inset: 3) {
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                    ZStack(alignment: .bottom) {
                        Rectangle().fill(ink.opacity(SK1.SevenSegment.unlitOpacity))
                        Rectangle().fill(ink)
                            .scaleEffect(x: 1, y: CGFloat(SK1.Format.clampedLevel(level)), anchor: .bottom)
                    }
                    .frame(maxWidth: 6)
                }
            }
            .animation(reduceMotion ? nil : .linear(duration: 0.08), value: levels)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Level"))
        .accessibilityValue(Text("\(SK1.Format.levelPercent(levels)) percent"))
    }
}
#endif
