import Foundation

extension SK1 {
    /// The arithmetic of a knob, apart from drawing (unit-tested): where each of its positions points and how far a
    /// drag or a scroll turns it. A knob has `count` positions from 0; a click-stop knob has one per choice, a smooth one
    /// one per step of its range.
    public struct KnobScale: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            /// Clicks between `count` choices.
            case stops(count: Int)
            /// Turns smoothly from `min` to `max` in steps of `step`.
            case smooth(min: Int, max: Int, step: Int)
        }

        public let kind: Kind

        public init(kind: Kind) { self.kind = kind }

        /// How far the pointer turns from the first position to the last, in degrees: from seven o'clock round to five.
        public static let sweep: CGFloat = 270
        /// The pointer's angle at the first position, in degrees counter-clockwise from three o'clock.
        public static let startAngle: CGFloat = 225
        /// How far a drag goes for one click of a click-stop knob, and for the whole sweep of a smooth one, in points.
        public static let dragPerStop: CGFloat = 22
        public static let dragForSweep: CGFloat = 160
        /// The ticks round a smooth knob.
        public static let smoothTicks = 11

        public var count: Int {
            switch kind {
            case .stops(let n): return max(n, 1)
            case .smooth(let lo, let hi, let step): return max((hi - lo) / max(step, 1), 0) + 1
            }
        }

        public var isSmooth: Bool { if case .smooth = kind { return true } else { return false } }

        public func clamp(_ position: Int) -> Int { min(max(position, 0), count - 1) }

        /// How far round `position` is, from 0 (the first) to 1 (the last).
        public func fraction(_ position: Int) -> CGFloat {
            count > 1 ? CGFloat(clamp(position)) / CGFloat(count - 1) : 0
        }

        /// The pointer's angle at `position`, in degrees counter-clockwise from three o'clock.
        public func angle(_ position: Int) -> CGFloat { Self.startAngle - Self.sweep * fraction(position) }

        /// The ticks round the knob, each as a fraction of the sweep.
        public var ticks: [CGFloat] {
            let n = isSmooth ? Self.smoothTicks : count
            return n > 1 ? (0..<n).map { CGFloat($0) / CGFloat(n - 1) } : [0]
        }

        /// How far a drag goes for one position.
        public var dragPerPosition: CGFloat {
            isSmooth ? Self.dragForSweep / CGFloat(max(count - 1, 1)) : Self.dragPerStop
        }

        /// The positions a drag of `distance` points (up is positive) turns the knob, carrying what is left over in
        /// `carry` for the next move of the same drag.
        public func steps(forDrag distance: CGFloat, carry: inout CGFloat) -> Int {
            carry += distance
            let steps = Int((carry / dragPerPosition).rounded(.towardZero))
            carry -= CGFloat(steps) * dragPerPosition
            return steps
        }

        /// The value at `position` of a smooth knob (a click-stop knob's position is its choice's index).
        public func value(at position: Int) -> Int {
            guard case .smooth(let lo, _, let step) = kind else { return clamp(position) }
            return lo + clamp(position) * step
        }

        /// The position nearest `value` on a smooth knob.
        public func position(for value: Int) -> Int {
            guard case .smooth(let lo, _, let step) = kind else { return clamp(value) }
            return clamp(Int((Double(value - lo) / Double(max(step, 1))).rounded()))
        }
    }
}
