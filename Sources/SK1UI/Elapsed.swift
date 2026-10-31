#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// The recording timer's LCD (Skreener's `ElapsedLCD`): along the top a REC lamp that blinks while recording (steady
/// and "PAUSED" while paused, dimmed while stopped) and what is recorded (`detail`, e.g. "MP4 60"), and under them the
/// elapsed time in seven-segment digits, "mm:ss" or "h:mm:ss" from an hour. 142 × 62 pt by default. Reduce Motion keeps
/// the lamp lit. VoiceOver reads e.g. "Recording: on, 1 minute 12 seconds".
///
/// ```swift
/// SKElapsed(seconds: elapsed, recording: true, paused: false, detail: "M4A")
/// ```
public struct SKElapsed: View {
    private let seconds: TimeInterval
    private let recording: Bool
    private let paused: Bool
    private let detail: String
    private let size: CGSize

    public init(seconds: TimeInterval, recording: Bool, paused: Bool = false, detail: String = "",
                size: CGSize = CGSize(width: 142, height: 62)) {
        self.seconds = seconds
        self.recording = recording
        self.paused = paused
        self.detail = detail
        self.size = size
    }

    public var body: some View {
        let ink = Color(sk1Hex: SK1.lcdInk)
        let red = Color(sk1Hex: SK1.recRed)
        SKLCD {
            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    if paused {
                        SKLampDot(color: ink, lit: false, unlit: ink.opacity(0.4), glow: 4, size: 6)
                    } else {
                        SK1BlinkingLamp(blinking: recording) { lit in
                            SKLampDot(color: red, lit: recording && lit, unlit: red.opacity(SK1.lampDimmed), glow: 4, size: 6)
                        }
                    }
                    Text(SK1.Format.elapsedStatus(paused: paused))
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(ink)
                    Spacer(minLength: 4)
                    Text(detail.uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(ink.opacity(0.75))
                        .lineLimit(1)
                }
                .frame(height: 10)
                // The digits fill what is left under the top row, at most 26 pt tall.
                GeometryReader { geo in
                    SKSevenSegment(SK1.Format.elapsed(seconds), digitHeight: max(min(26, geo.size.height), 8), spacing: 3)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
        }
        .frame(width: size.width, height: size.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(SK1.Format.elapsedAccessibilityLabel(seconds: seconds, recording: recording, paused: paused)))
    }
}
#endif
