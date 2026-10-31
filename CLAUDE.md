# SK1Kit

Shared Swift package for the SK-1 look (cream chassis, sunken trays, raised keys, olive LCD, orange for "on"),
extracted from Skreener's `Retro*.swift`. `DESIGN.md` is the spec; `README.md` is the usage guide.

- `SK1Tokens` imports Foundation only (no SwiftUI, AppKit, UIKit or CoreGraphics) so it builds and tests on Linux. Keep it that way.
- `SK1UI` imports SwiftUI: wrap every file that does in `#if canImport(SwiftUI)` (tests too), so the Linux job still builds
  it. Its Foundation-only logic (`SK1.Format`) stays outside the guard and is tested on Linux.
- Tests: `swift test`. CI runs them on Linux and macOS with warnings as errors, then compiles for iOS.
- Builds must be warning-free. Also avoid patterns newer compilers warn about, e.g. a `[weak self]` closure nested
  inside a closure that captures `self` strongly (put `[weak self]` on the outer closure instead).
- Commit subjects use Conventional Commits (`feat(tokens): …`, `fix: …`, `docs: …`, `ci: …`): release-please picks
  the next version from them and CI rejects PRs whose commits don't match.
- Keep `DESIGN.md` and `README.md` current with every change.
- Token values must stay identical to Skreener's (`Retro.swift`) until Skreener adopts the package.
