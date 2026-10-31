# SK1Kit

SK1Kit is the SK-1 design system as a Swift package: a cream (charcoal in Dark Mode) chassis with sunken trays of
raised keys, an olive LCD with seven-segment digits, and orange for what is on and for the main action. It started as
the look of the Skreener screenshot app and is shared by the author's other apps. `DESIGN.md` is the short spec of the
principles, tokens and components.

## Modules

| Module | State | What it is |
|---|---|---|
| `SK1Tokens` | available | Framework-free tokens: palettes and fixed colours as hex numbers, type styles, metrics, WCAG contrast, seven-segment geometry and knob arithmetic. Foundation only; builds on Linux. |
| `SK1UI` | available | SwiftUI components (iOS 17+, macOS 14+): chassis, plates, wells, keys, toggles, segmented control, LCDs, seven-segment digits, timer, lamps, level meter, settings rows. See `DESIGN.md` for the list. |
| `SK1AppKit` | planned | AppKit views for macOS apps that are not SwiftUI. |

## Adding it

Swift Package Manager:

```swift
.package(url: "https://github.com/jsonify/SK1Kit.git", from: "0.1.0")
// target dependencies:
.product(name: "SK1Tokens", package: "SK1Kit"),
.product(name: "SK1UI", package: "SK1Kit"),
```

XcodeGen (`project.yml`):

```yaml
packages:
  SK1Kit:
    url: https://github.com/jsonify/SK1Kit.git
    from: 0.1.0
targets:
  MyApp:
    dependencies:
      - package: SK1Kit
        product: SK1Tokens
      - package: SK1Kit
        product: SK1UI
```

```swift
import SK1Tokens

let p = SK1.palette(dark: false)   // p.chassis == 0xebe8e1
let ratio = SK1.contrast(SK1.lcdInk, SK1.glassBottom)
```

### SK1UI

```swift
import SwiftUI
import SK1UI

struct RecorderView: View {
    @State private var recording = false

    var body: some View {
        VStack(spacing: 22) {
            SKWell {
                SKElapsed(seconds: 72, recording: recording)
                    .padding(14)
            }
            Button(recording ? "Stop" : "Record") { recording.toggle() }
                .buttonStyle(.sk1Key(.orange, size: .large))
        }
        .padding(22)
        .sk1Chassis()   // the chassis fills the screen, safe area included
    }
}
```

Every component reads the colour scheme from the environment, so light and dark need nothing more. `DESIGN.md`
lists them all with their Skreener sources and an example of each.

### The gallery

`SK1Gallery` shows every component in each variant and state, in light and dark. To see it:

- Xcode previews: open `Package.swift` in Xcode, open `Sources/SK1UI/Gallery/SK1Gallery.swift` and show the canvas
  (Editor > Canvas). There are previews for an iPhone-sized and a Mac-sized frame, in light and dark.
- CI: each run of the `apple` job uploads the gallery rendered in light and dark at 390 pt (iPhone) and 720 pt (Mac)
  wide as the `sk1-gallery` artifact (PNGs at 2x). Download it from the run's Summary page.
- Locally on a Mac: `SK1_SNAPSHOT_DIR=/tmp/sk1-gallery swift test --filter GallerySnapshotTests` writes the same PNGs.
- In an app: show `SK1Gallery()` on a debug screen.

### Local development

Point an app at a checkout next to it instead of the tag: `.package(path: "../SK1Kit")` (XcodeGen: `path: ../SK1Kit`).

## Tests

```
swift test
```

CI (`.github/workflows/ci.yml`) runs them on Linux (`swift:6.0`) and macOS with warnings as errors, then compiles the
package for iOS. On Linux, SK1UI builds with only its Foundation text logic (`SK1.Format`): every file that imports
SwiftUI is wrapped in `#if canImport(SwiftUI)`. The macOS run also renders the gallery (see above), and both jobs post
the compiler's warnings and errors in `Sources/` and `Tests/` as annotations on the run, with a count.

## Layout

```
Package.swift
Sources/SK1Tokens/   SK1.swift (palettes, fixed colours, blink), RGB.swift (contrast), TypeScale.swift,
                     Metrics.swift, SevenSegment.swift, KnobScale.swift
Sources/SK1UI/       Format.swift (text shown and spoken; Foundation only), Color+SK1.swift, Drawing.swift (the
                     Retro.draw… ports), Chassis.swift (chassis, plate, well, groove), Type.swift (caption, hint),
                     Keys.swift (key style, tray), Toggles.swift (square, switch, indicator), Segmented.swift,
                     LCD.swift (glass, LCD, readout, chip, display), SevenSegment.swift, Elapsed.swift (timer),
                     Lamp.swift, LevelMeter.swift, Settings.swift (row, group)
Sources/SK1UI/Gallery/ SK1Gallery.swift (every component, with previews)
Tests/SK1TokensTests/
Tests/SK1UITests/    FormatTests.swift (also on Linux), GallerySnapshotTests.swift (macOS: renders the gallery)
DESIGN.md            principles, token tables, components
CLAUDE.md            notes for agents
.github/workflows/   ci.yml, commits.yml, release-please.yml
.github/scripts/     report-diagnostics.sh (compiler diagnostics to annotations)
```

Releases are cut by release-please from Conventional Commit messages.
