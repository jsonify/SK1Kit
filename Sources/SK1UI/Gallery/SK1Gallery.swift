#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// Every SK1UI component in each of its variants and states, on the chassis, in the environment's colour scheme:
/// for Xcode's previews, a debug screen in an app, and the snapshot test (`SK1_SNAPSHOT_DIR`). The interactive ones
/// work; the others show fixed states.
public struct SK1Gallery: View {
    private let scrolls: Bool
    @State private var tab = 1
    @State private var mic = true
    @State private var launch = false
    @State private var tool = 0

    /// `scrolls` false lays it out at full height (for rendering it to an image).
    public init(scrolls: Bool = true) { self.scrolls = scrolls }

    public var body: some View {
        if scrolls {
            ScrollView { content }.sk1Chassis()
        } else {
            content.sk1Chassis()
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: SK1.Metrics.groupSpacing) {
            section("Chassis, plate, well, groove") {
                SKPlate {
                    VStack(alignment: .leading, spacing: 10) {
                        SKCaption("Plate")
                        SKWell {
                            Text("A sunken well").sk1Hint().padding(14).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        SKGroove()
                        HStack(spacing: 10) {
                            Text("Left").sk1Hint()
                            SKGroove(.vertical).frame(height: 24)
                            Text("Right").sk1Hint()
                        }
                    }
                    .padding(14)
                }
            }

            section("Type") {
                HStack(spacing: 16) {
                    SKCaption("Caption ink")
                    SKCaption("Caption soft", tone: .soft)
                }
                Text("A hint under a row or a tray.").sk1Hint()
                Text("Row title, Font.sk1").font(.sk1(SK1.TypeScale.rowTitle))
            }

            section("Keys") {
                keyRow(.regular)
                keyRow(.small)
                HStack(spacing: 8) {
                    Button("On") {}.buttonStyle(.sk1Key(isOn: true))
                    Button("Off") {}.buttonStyle(.sk1Key())
                    Button { } label: { Image(systemName: "pencil") }.buttonStyle(.sk1Key(isOn: true))
                    Button { } label: { Image(systemName: "eraser") }.buttonStyle(.sk1Key())
                    Button { } label: { Image(systemName: "chevron.left") }.buttonStyle(.sk1Key(.round, size: .small))
                    Button { } label: { Image(systemName: "chevron.right") }.buttonStyle(.sk1Key(.round, size: .small))
                }
                HStack(spacing: 8) {
                    Button("Disabled") {}.buttonStyle(.sk1Key()).disabled(true)
                    Button("Disabled") {}.buttonStyle(.sk1Key(.orange)).disabled(true)
                    Button { } label: { Label("Share", systemImage: "square.and.arrow.up") }.buttonStyle(.sk1Key())
                }
                Button("Record") {}.buttonStyle(.sk1Key(.orange, size: .large))
                Button("Large cream") {}.buttonStyle(.sk1Key(size: .large))
            }

            section("Key tray") {
                HStack(alignment: .top, spacing: 12) {
                    SKKeyTray(caption: "Tools") {
                        ForEach(0..<3) { i in
                            Button { tool = i } label: { Image(systemName: ["pencil", "highlighter", "eraser"][i]) }
                                .buttonStyle(.sk1Key(isOn: tool == i))
                        }
                    }
                    SKKeyTray {
                        Button("Undo") {}.buttonStyle(.sk1Key())
                        Button("Save") {}.buttonStyle(.sk1Key(.orange))
                    }
                }
            }

            section("Toggles and indicators") {
                HStack(spacing: 16) {
                    Toggle("Mic", isOn: $mic).toggleStyle(.sk1Square)
                    Toggle("On", isOn: .constant(true)).toggleStyle(.sk1Square)
                    Toggle("Off", isOn: .constant(false)).toggleStyle(.sk1Square)
                }
                HStack(spacing: 16) {
                    SKIndicator("Indicator on", isOn: true)
                    SKIndicator("Off", isOn: false)
                }
                HStack(spacing: 16) {
                    Toggle("Switch on", isOn: .constant(true)).toggleStyle(.sk1Switch)
                    Toggle("Switch off", isOn: .constant(false)).toggleStyle(.sk1Switch)
                    Toggle("Disabled", isOn: .constant(true)).toggleStyle(.sk1Switch).disabled(true)
                }
            }

            section("Segmented") {
                SKSegmented(selection: $tab, options: [
                    .init(0, "Notes"), .init(1, "Review", badge: "3"), .init(2, "People"),
                ])
                SKSegmented(selection: .constant(0), options: [.init(0, "Head"), .init(1, "Open", help: "Open head")],
                            caption: "Arrow")
            }

            section("LCD") {
                HStack(spacing: 10) {
                    SKGlass().frame(width: 80, height: 34)
                    SKGlass(.chip).frame(width: 60, height: 20)
                    SKChip("100%")
                    SKChip("4")
                }
                SKLCD { Text("SKLCD").font(.sk1(SK1.TypeScale.lcdMono)).foregroundStyle(Color(sk1Hex: SK1.lcdInk)) }
                    .frame(height: 34)
                SKReadout("Scrolling… 4 frames captured, keep going to add more")
                SKDisplay(title: "Filled rectangle", detail: "Key R", message: "Drag to draw", number: 100, unit: "%")
                SKDisplay(title: "Select", message: "Moving 2 annotations", number: 1200, unit: "%", live: true)
                SKDisplay(title: "Transcribing", message: "Whisper small · 42%", live: false)
            }

            section("Seven-segment") {
                HStack(alignment: .bottom, spacing: 12) {
                    SKSevenSegment("0123456789", digitHeight: 22)
                    SKSevenSegment("-  :", digitHeight: 22)
                }
                .padding(8)
                .background(SKGlass())
            }

            section("Timer") {
                HStack(spacing: 10) {
                    SKElapsed(seconds: 72, recording: true, detail: "M4A")
                    SKElapsed(seconds: 72, recording: true, paused: true, detail: "M4A")
                }
                HStack(spacing: 10) {
                    SKElapsed(seconds: 0, recording: false)
                    SKElapsed(seconds: 3_725, recording: true, detail: "MP4 60")
                }
            }

            section("Lamps") {
                HStack(spacing: 14) {
                    ForEach(Self.lamps, id: \.name) { lamp in
                        VStack(spacing: 6) {
                            SKLamp(color: lamp.color, lit: true)
                            SKLamp(color: lamp.color, lit: false)
                        }
                    }
                    SKLamp(color: .danger, lit: true, size: 8, label: "Recording", blinking: true)
                }
                .padding(.vertical, 4)
            }

            section("Level meter") {
                SKLevelMeter(levels: Self.levels)
                SKLevelMeter(levels: Array(repeating: 0, count: 24), height: 24)
            }

            section("Settings group") {
                SKGroup(caption: "Recording", note: "Recordings are saved to your Documents folder.") {
                    SKRow(title: "Launch at login", subtitle: "Starts in the menu bar.") {
                        Toggle("Launch at login", isOn: $launch).toggleStyle(.sk1Switch)
                    }
                    SKRow(title: "Microphone") { SKChip("Built-in") }
                    SKRow(title: "Mode") {
                        SKSegmented(selection: .constant(0), options: [.init(0, "Auto"), .init(1, "Manual")])
                    }
                }
            }
        }
        .padding(SK1.Metrics.paneMargin)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static let lamps: [(color: SKLampColor, name: String)] = [
        (.teal, "teal"), (.red, "red"), (.orange, "orange"), (.success, "success"), (.warning, "warning"), (.danger, "danger"),
    ]

    private static let levels: [Float] = (0..<24).map { i in
        let x = Float(i)
        return 0.5 + 0.4 * sin(x * 0.7) * cos(x * 0.23)
    }

    private func keyRow(_ size: SK1KeySize) -> some View {
        HStack(spacing: 8) {
            Button("Cream") {}.buttonStyle(.sk1Key(size: size))
            Button("Orange") {}.buttonStyle(.sk1Key(.orange, size: size))
            Button("Charcoal") {}.buttonStyle(.sk1Key(.charcoal, size: size))
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SKCaption(title, tone: .soft)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("iPhone, light", traits: .fixedLayout(width: 390, height: 2200)) {
    SK1Gallery().preferredColorScheme(.light)
}

#Preview("iPhone, dark", traits: .fixedLayout(width: 390, height: 2200)) {
    SK1Gallery().preferredColorScheme(.dark)
}

#Preview("Mac, light", traits: .fixedLayout(width: 720, height: 2000)) {
    SK1Gallery().preferredColorScheme(.light)
}

#Preview("Mac, dark", traits: .fixedLayout(width: 720, height: 2000)) {
    SK1Gallery().preferredColorScheme(.dark)
}
#endif
