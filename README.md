# SK1Kit

SK1Kit is the SK-1 design system as a Swift package: a cream (charcoal in Dark Mode) chassis with sunken trays of
raised keys, an olive LCD with seven-segment digits, and orange for what is on and for the main action. It started as
the look of the Skreener screenshot app and is shared by the author's other apps. `DESIGN.md` is the short spec of the
principles, tokens and planned components.

## Modules

| Module | State | What it is |
|---|---|---|
| `SK1Tokens` | available | Framework-free tokens: palettes and fixed colours as hex numbers, type styles, metrics, WCAG contrast, seven-segment geometry and knob arithmetic. Foundation only; builds on Linux. |
| `SK1UI` | planned | SwiftUI components (iOS 17+, macOS 14+). |
| `SK1AppKit` | planned | AppKit views for macOS apps that are not SwiftUI. |

## Adding it

Swift Package Manager:

```swift
.package(url: "https://github.com/jsonify/SK1Kit.git", from: "0.1.0")
// target dependency:
.product(name: "SK1Tokens", package: "SK1Kit")
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
```

```swift
import SK1Tokens

let p = SK1.palette(dark: false)   // p.chassis == 0xebe8e1
let ratio = SK1.contrast(SK1.lcdInk, SK1.glassBottom)
```

### Local development

Point an app at a checkout next to it instead of the tag: `.package(path: "../SK1Kit")` (XcodeGen: `path: ../SK1Kit`).

## Tests

```
swift test
```

CI (`.github/workflows/ci.yml`) runs them on Linux (`swift:6.0`) and macOS with warnings as errors, then compiles the
package for iOS.

## Layout

```
Package.swift
Sources/SK1Tokens/   SK1.swift (palettes, fixed colours, blink), RGB.swift (contrast), TypeScale.swift,
                     Metrics.swift, SevenSegment.swift, KnobScale.swift
Tests/SK1TokensTests/
DESIGN.md            principles, token tables, planned components
CLAUDE.md            notes for agents
.github/workflows/   ci.yml, commits.yml, release-please.yml
```

Releases are cut by release-please from Conventional Commit messages.
