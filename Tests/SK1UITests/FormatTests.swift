import XCTest
import SK1Tokens
@testable import SK1UI

/// The text SK1UI's components show and speak. Foundation only, so these run on Linux too.
final class FormatTests: XCTestCase {
    func testElapsedIsMinutesAndSecondsUnderAnHour() {
        XCTAssertEqual(SK1.Format.elapsed(0), "00:00")
        XCTAssertEqual(SK1.Format.elapsed(9.99), "00:09", "part seconds round down")
        XCTAssertEqual(SK1.Format.elapsed(72), "01:12")
        XCTAssertEqual(SK1.Format.elapsed(3_599), "59:59")
    }

    func testElapsedShowsHoursFromAnHour() {
        XCTAssertEqual(SK1.Format.elapsed(3_600), "1:00:00")
        XCTAssertEqual(SK1.Format.elapsed(3_725), "1:02:05")
        XCTAssertEqual(SK1.Format.elapsed(36_000 + 61), "10:01:01")
    }

    func testElapsedOfNonsenseIsZero() {
        XCTAssertEqual(SK1.Format.elapsed(-5), "00:00")
        XCTAssertEqual(SK1.Format.elapsed(.nan), "00:00")
        XCTAssertEqual(SK1.Format.elapsed(.infinity), "00:00")
        XCTAssertEqual(SK1.Format.wholeSeconds(1e300), Int.max)
    }

    func testSpokenDuration() {
        XCTAssertEqual(SK1.Format.spokenDuration(0), "0 seconds")
        XCTAssertEqual(SK1.Format.spokenDuration(1), "1 second")
        XCTAssertEqual(SK1.Format.spokenDuration(72), "1 minute 12 seconds")
        XCTAssertEqual(SK1.Format.spokenDuration(120), "2 minutes")
        XCTAssertEqual(SK1.Format.spokenDuration(3_601), "1 hour 1 second")
        XCTAssertEqual(SK1.Format.spokenDuration(7_384), "2 hours 3 minutes 4 seconds")
    }

    func testTimerAccessibilityLabelSaysItsState() {
        XCTAssertEqual(SK1.Format.elapsedAccessibilityLabel(seconds: 72, recording: true, paused: false),
                       "Recording: on, 1 minute 12 seconds")
        XCTAssertEqual(SK1.Format.elapsedAccessibilityLabel(seconds: 72, recording: true, paused: true),
                       "Recording: paused, 1 minute 12 seconds")
        XCTAssertEqual(SK1.Format.elapsedAccessibilityLabel(seconds: 0, recording: false, paused: false),
                       "Recording: off, 0 seconds")
        XCTAssertEqual(SK1.Format.elapsedStatus(paused: false), "REC")
        XCTAssertEqual(SK1.Format.elapsedStatus(paused: true), "PAUSED")
    }

    func testStateLabels() {
        XCTAssertEqual(SK1.Format.state(true), "on")
        XCTAssertEqual(SK1.Format.state(false), "off")
        XCTAssertEqual(SK1.Format.stateLabel("Microphone", on: true), "Microphone: on")
        XCTAssertEqual(SK1.Format.stateLabel("Warning", on: false), "Warning: off")
    }

    func testSegmentBadge() {
        XCTAssertEqual(SK1.Format.segmentTitle("Review", badge: "3"), "Review · 3")
        XCTAssertEqual(SK1.Format.segmentTitle("Review", badge: nil), "Review")
        XCTAssertEqual(SK1.Format.segmentTitle("Review", badge: ""), "Review")
        XCTAssertEqual(SK1.Format.segmentAccessibilityLabel("Review", badge: "3"), "Review, 3")
        XCTAssertEqual(SK1.Format.segmentAccessibilityLabel("Review", badge: nil), "Review")
    }

    func testLevels() {
        XCTAssertEqual(SK1.Format.levelPercent([]), 0)
        XCTAssertEqual(SK1.Format.levelPercent([0.1, 0.42, 0.3]), 42)
        XCTAssertEqual(SK1.Format.levelPercent([2, -1]), 100)
        XCTAssertEqual(SK1.Format.levelPercent([.nan, 0.5]), 50)
        XCTAssertEqual(SK1.Format.clampedLevel(-0.2), 0)
        XCTAssertEqual(SK1.Format.clampedLevel(1.5), 1)
        XCTAssertEqual(SK1.Format.clampedLevel(.nan), 0)
        XCTAssertEqual(SK1.Format.clampedLevel(0.25), 0.25)
    }

    func testDisplayAccessibilityValue() {
        XCTAssertEqual(SK1.Format.displayAccessibilityValue(title: "Rectangle", message: "Drag to draw", live: false),
                       "Rectangle: Drag to draw, idle")
        XCTAssertEqual(SK1.Format.displayAccessibilityValue(title: "", message: "Moving", live: true), "Moving, live")
        XCTAssertEqual(SK1.Format.displayAccessibilityValue(title: "", message: "", live: false), "idle")
    }
}
