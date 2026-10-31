import Foundation
import SK1Tokens

// Foundation only, and not wrapped in `#if canImport(SwiftUI)`: this is the part of SK1UI that builds and is tested on
// Linux too.

extension SK1 {
    /// What SK1UI's components show and speak, apart from SwiftUI (unit-tested).
    public enum Format {
        /// Whole seconds in `seconds`, 0 for a negative, infinite or NaN value.
        public static func wholeSeconds(_ seconds: TimeInterval) -> Int {
            guard seconds.isFinite, seconds > 0 else { return 0 }
            return seconds >= Double(Int.max) ? Int.max : Int(seconds.rounded(.down))
        }

        /// The elapsed time as `SKElapsed` shows it: "mm:ss", or "h:mm:ss" from an hour.
        public static func elapsed(_ seconds: TimeInterval) -> String {
            let s = wholeSeconds(seconds)
            let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
            func two(_ n: Int) -> String { n < 10 ? "0\(n)" : "\(n)" }
            return h > 0 ? "\(h):\(two(m)):\(two(sec))" : "\(two(m)):\(two(sec))"
        }

        /// The elapsed time in words: "1 hour 2 minutes 3 seconds", leaving out what is zero ("0 seconds" for none).
        public static func spokenDuration(_ seconds: TimeInterval) -> String {
            let s = wholeSeconds(seconds)
            let parts: [(Int, String)] = [(s / 3600, "hour"), ((s % 3600) / 60, "minute"), (s % 60, "second")]
            let words = parts.filter { $0.0 > 0 }.map { "\($0.0) \($0.1)\($0.0 == 1 ? "" : "s")" }
            return words.isEmpty ? "0 seconds" : words.joined(separator: " ")
        }

        /// "on" or "off".
        public static func state(_ on: Bool) -> String { on ? "on" : "off" }

        /// What the timer says to VoiceOver: "Recording: on, 1 minute 12 seconds" (paused: "Recording: paused, …").
        public static func elapsedAccessibilityLabel(seconds: TimeInterval, recording: Bool, paused: Bool) -> String {
            let state = paused ? "paused" : Self.state(recording)
            return "Recording: \(state), \(spokenDuration(seconds))"
        }

        /// What the timer's lamp says beside the digits: "PAUSED" while paused, "REC" otherwise.
        public static func elapsedStatus(paused: Bool) -> String { paused ? "PAUSED" : "REC" }

        /// A lamp's or an indicator's label: "Microphone: on".
        public static func stateLabel(_ name: String, on: Bool) -> String { "\(name): \(state(on))" }

        /// A segment's title with its badge: "Review · 3" (just "Review" with no badge or an empty one).
        public static func segmentTitle(_ label: String, badge: String?) -> String {
            guard let badge, !badge.isEmpty else { return label }
            return "\(label) · \(badge)"
        }

        /// A segment's spoken name with its badge: "Review, 3".
        public static func segmentAccessibilityLabel(_ label: String, badge: String?) -> String {
            guard let badge, !badge.isEmpty else { return label }
            return "\(label), \(badge)"
        }

        /// A level meter's reading, 0 to 100: the loudest of `levels` (each 0 to 1), rounded.
        public static func levelPercent(_ levels: [Float]) -> Int {
            let peak = levels.filter(\.isFinite).max() ?? 0
            return Int((min(max(peak, 0), 1) * 100).rounded())
        }

        /// A level clamped to 0...1 (0 for NaN).
        public static func clampedLevel(_ level: Float) -> Float {
            level.isFinite ? min(max(level, 0), 1) : 0
        }

        /// What the editor-style display says to VoiceOver: its title and message, then whether it is live.
        public static func displayAccessibilityValue(title: String, message: String, live: Bool) -> String {
            let text = [title, message].filter { !$0.isEmpty }.joined(separator: ": ")
            let state = live ? "live" : "idle"
            return text.isEmpty ? state : "\(text), \(state)"
        }
    }
}
