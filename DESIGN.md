# SK-1 design spec

The SK-1 look, as a short spec for people and agents. The numbers live in `Sources/SK1Tokens` and must match the tables
below; they are copied from Skreener's `Retro.swift` and stay identical to it until Skreener adopts this package.

## Principles

1. One chassis per window: cream #EBE8E1 with a white top glow (charcoal #2B2A27 in Dark Mode), not white cards on grey.
2. Controls sit in sunken trays (wells with an inner shadow and a light lip); a tray's label is a small caption, never a bold heading.
3. Keys are raised and press down: a keycap on a 2 pt skirt; pressed, the face drops onto the skirt; a selected key keeps a glowing orange bar.
4. Orange means "on" or "the main action", and only those: at most one orange key per screen; everything else is cream, plus one charcoal key for an action apart.
5. Live state goes on the LCD: timers, counts, the current mode and short status on olive glass in mono or seven-segment type; never long prose.
6. Lamps signal, text explains: teal for hover or ready, red blinking at 1 s for recording; every lamp's meaning is also in its accessibility label.
7. Quiet type: captions 9 pt semibold, upper case, tracked 0.8; body text is the system font in the palette's ink; decoration (speaker grille) is used sparingly, never on content.

## Colour tokens

Hex values are 0xRRGGBB; alphas (`chassisGlow`, `grooveLip`, `wellShadow`, `wellLip`, `keyHighlight`, `keyShadow`, `canvasDot`) are fractions and `lcdBrightness` scales the LCD glass toward black. In code: `SK1.light`, `SK1.dark`, `SK1.palette(dark:)`.

| Token | Light | Dark |
|---|---|---|
| `chassis` | `#EBE8E1` | `#2B2A27` |
| `chassisGlow` | `0.55` | `0.06` |
| `groove` | `#D3CFC5` | `#1A1917` |
| `grooveLip` | `0.7` | `0.06` |
| `wellTop` | `#E2DED6` | `#1D1C1A` |
| `wellBottom` | `#E9E6DF` | `#242320` |
| `wellShadow` | `0.16` | `0.5` |
| `wellLip` | `0.9` | `0.07` |
| `keyTop` | `#FDFCFA` | `#4A4843` |
| `keyBottom` | `#E8E4DC` | `#36342F` |
| `keyDownTop` | `#ECE9E2` | `#302E2A` |
| `keyDownBottom` | `#F6F4EF` | `#3A3833` |
| `keySkirt` | `#C7C2B7` | `#1A1917` |
| `keyHighlight` | `1` | `0.1` |
| `keyShadow` | `0.14` | `0.45` |
| `keyInk` | `#2B2A27` | `#ECE8DF` |
| `charcoalTop` | `#45433E` | `#2C2A27` |
| `charcoalBottom` | `#252421` | `#181715` |
| `charcoalSkirt` | `#11100F` | `#0A0A09` |
| `ink` | `#2B2A27` | `#ECE8DF` |
| `inkSoft` | `#67635A` | `#A8A397` |
| `track` | `#DCD8CF` | `#1F1E1C` |
| `trackInk` | `#57534B` | `#A8A397` |
| `toggleOff` | `#D3CFC5` | `#4A4843` |
| `bezelTop` | `#D2CEC4` | `#1D1C1A` |
| `bezelBottom` | `#E2DED6` | `#26251F` |
| `lcdBrightness` | `1` | `0.86` |
| `canvas` | `#DCD8CF` | `#1F1E1C` |
| `canvasDot` | `0.09` | `0.07` |
| `grilleLight` | `#8F8A80` | `#1A1917` |
| `grilleDark` | `#3D3B37` | `#0B0B0A` |

### Fixed colours (the same in light and dark)

In code: `SK1.orange` and so on. `SK1.blinkLit(_:)` says whether a blinking lamp is lit (1 s period, lit for the first half).

| Token | Hex |
|---|---|
| `orange` | `#FF5C1C` |
| `orangeTop` | `#FF8045` |
| `orangeBottom` | `#F2520F` |
| `orangeSkirt` | `#B93A07` |
| `charcoalInk` | `#F2EFE9` |
| `segmentTop` | `#45433E` |
| `segmentBottom` | `#2A2926` |
| `glassTop` | `#D3D9BE` |
| `glassMiddle` | `#C3CAAD` |
| `glassBottom` | `#B9C0A2` |
| `lcdInk` | `#1E2318` |
| `chipTop` | `#CFD5BA` |
| `chipMiddle` | `#C7CDB1` |
| `chipBottom` | `#BFC6A9` |
| `teal` | `#1F9E86` |
| `recRed` | `#E0402F` |
| `amber` | `#8A5300` (warning lamp; from Minits, not in Skreener) |
| `lampDimmed` | `0.2` (alpha between blinks) |

Contrast: `SK1.contrast(_:_:)` is the WCAG 2 ratio. Text tokens are tested at 4.5:1 or better on what they sit on, in both palettes.

## Type styles

In code: `SK1.TypeScale`. Sizes and kerning are in points; body text is the system font in the palette's ink.

| Style | Size | Weight | Kern | Upper case | Mono |
|---|---|---|---|---|---|
| `caption` | 9 | semibold | 0.8 | yes | no |
| `indicator` | 9.5 | bold | 0.6 | yes | no |
| `rowTitle` | 12.5 | medium | 0 | no | no |
| `hint` | 11 | regular | 0 | no | no |
| `lcdMono` | 11 | semibold | 0.3 | no | yes |

## Metrics

In code: `SK1.Metrics`, in points.

| Token | Value | Use |
|---|---|---|
| `keyHeight` | 30 | symbol-only key (28 face + 2 skirt) |
| `popUpHeight` | 26 | pop-up key |
| `toggleHeight` | 20 | toggle row |
| `keyRadius` | 6 | key corner |
| `keySkirt` | 2 | skirt under a key |
| `wellRadius` | 10 | tray holding rows |
| `trayRadius` | 9 | tray holding keys (`keyRadius` + 3) |
| `plateRadius` | 14 | floating chassis plate |
| `lcdRadius` | 9 | LCD bezel |
| `lcdInset` | 4 | bezel to glass |
| `chipRadius` | 4 | LCD chip |
| `toggleSquare` | 9 | toggle square |
| `toggleSquareRadius` | 2 | toggle square corner |
| `rowMinHeight` | 40 | settings row |
| `rowInset` | 14 | row content to tray edge |
| `captionToWell` | 8 | caption to a tray of rows |
| `groupSpacing` | 22 | between groups |
| `paneMargin` | 22 | pane margin |
| `sidebarWidth` | 200 | sidebar |
| `iconGap` | 5 | key symbol to title |

Also in `SK1Tokens`: `SK1.SevenSegment` (digit geometry: 20 x 36 box, 3.6 thick, 0.7 gaps, 5 degree lean) and `SK1.KnobScale` (270 degree sweep from 225 degrees; drag arithmetic).

## Components (SK1UI)

`SK1UI` is the SwiftUI form of Skreener's AppKit views (iOS 17+, macOS 14+). Each component ports the drawing maths
of its Skreener source (gradients and their stops, radii, skirts, inner shadows, lips, hairline edges, glows and
alphas) to SwiftUI, takes every colour from `SK1Tokens` and follows `@Environment(\.colorScheme)`. `SK1Gallery` shows
them all. Helpers: `SK1.palette(for: ColorScheme)`, `Color(sk1Hex:)` / `Color(sk1Hex:brightness:)`, `Font.sk1(_:)`.

| Component | Skreener source | SwiftUI API | Example |
|---|---|---|---|
| Chassis | `ChassisView` (`Retro.swift`) | `.sk1Chassis()` | `ContentView().sk1Chassis()` |
| Plate | `Retro.drawPlate`, `ChassisPlate` | `SKPlate(radius:) { }` | `SKPlate { bar.padding(12) }` |
| Well | `Retro.drawWell`, `RetroWell` | `SKWell(radius:) { }` | `SKWell { rows.padding(14) }` |
| Groove | `RetroGroove` | `SKGroove(_ axis:)` | `SKGroove()`, `SKGroove(.vertical)` |
| Caption, hint | `RetroLabel`, `RetroUI.hint` | `SKCaption(_:tone:)`, `.sk1Hint()`, `Font.sk1(_:)` | `SKCaption("Output", tone: .soft)` |
| Keycap | `Retro.drawKey`, `keyColors`, `drawOnBar`; `PillButton` `.keycap` and `.round` | `.buttonStyle(.sk1Key(_:isOn:size:))`; variants `.cream`, `.orange`, `.charcoal`, `.round`; sizes `.regular` (30), `.small` (26), `.large` (56, full width) | `Button("Save") { }.buttonStyle(.sk1Key(.orange))` |
| Keycap tray | `KeycapTray` | `SKKeyTray(caption:) { keys }` | `SKKeyTray(caption: "Tools") { penKey; eraserKey }` |
| Toggle | `Retro.drawToggleSquare`, `PillButton` `.toggle` | `.toggleStyle(.sk1Square)` | `Toggle("Mic", isOn: $mic).toggleStyle(.sk1Square)` |
| Switch | `RetroSwitch` | `.toggleStyle(.sk1Switch)` | `Toggle("Launch", isOn: $on).toggleStyle(.sk1Switch)` |
| Indicator | `RetroIndicator` | `SKIndicator(_:isOn:)` | `SKIndicator("Mic", isOn: true)` |
| Segmented | `RetroSegmented` | `SKSegmented(selection:options:caption:)` | `SKSegmented(selection: $tab, options: [.init(.notes, "Notes"), .init(.review, "Review", badge: "3")])` |
| Glass | `Retro.drawGlass`, `drawChipGlass` | `SKGlass(_ kind:radius:)`, kinds `.display`, `.chip` | `Text("42").padding(6).background(SKGlass(.chip))` |
| LCD | `Retro.drawLCD` | `SKLCD(radius:inset:) { }` | `SKLCD { Text("READY") }.frame(height: 30)` |
| Readout | `LCDReadout` | `SKReadout(_:height:)` | `SKReadout("Scrolling… 4 frames")` |
| Text field | `LCDTextBox` (planned there as "LCD text field") | `SKTextField(_:text:prompt:height:)` | `SKTextField("Role", text: $role, prompt: "Chair, Treasurer…")` |
| Chip | `LCDChip` | `SKChip(_:minWidth:height:)` | `SKChip("100%")` |
| Display | `LCDDisplay` (`LCDDisplay.swift`) | `SKDisplay(title:detail:message:number:digits:unit:live:height:)` | `SKDisplay(title: "Rectangle", message: "Drag to draw", number: 100, unit: "%")` |
| Seven-segment | `SevenSegment.draw`, `SevenSegmentView` | `SevenSegmentShape(_:spacing:segments:)`, `SKSevenSegment(_:digitHeight:spacing:color:)` | `SKSevenSegment("12:05", digitHeight: 26)` |
| Timer | `ElapsedLCD` | `SKElapsed(seconds:recording:paused:detail:size:)` | `SKElapsed(seconds: 72, recording: true, paused: false)` |
| Lamp | `Retro.drawLamp` | `SKLamp(color:lit:glow:size:label:blinking:)`; colours `.teal`, `.red`, `.orange`, `.success`, `.warning`, `.danger` | `SKLamp(color: .danger, lit: true, label: "Recording", blinking: true)` |
| Level meter | new (Minits) | `SKLevelMeter(levels:height:spacing:)` | `SKLevelMeter(levels: recentLevels)` |
| Status strip | `LauncherLCD` (`MenuLauncher.swift`) | `SKStatusStrip(title:detail:lamp:emphasized:height:)` | `SKStatusStrip(title: "Skreener", detail: "v1.18.0 · UP TO DATE")` |
| Tile | `LauncherTile` (`MenuLauncher.swift`) | `SKTile(_:systemImage:legend:variant:isOn:onHover:action:)` | `SKTile("Area", systemImage: "viewfinder", legend: "⇧⌘4") { capture() }` |
| Captioned key | `LauncherKey` (`MenuLauncher.swift`) | `SKCaptionedKey(_:systemImage:variant:lamp:onHover:action:)` | `SKCaptionedKey("Watch", systemImage: "eye", lamp: watching) { toggle() }` |
| Key group | the launcher's trays | `SKKeyGroup(caption:) { keys }` | `SKKeyGroup(caption: "Tools") { drawKey; watchKey }` |
| Picker | `PillPopUp` (`.lcd`, `stepper`) | `SKPicker(selection:options:caption:stepper:)`; arrows are `.sk1Key(.round, size: .mini)` | `SKPicker(selection: $stroke, options: strokes, caption: "Stroke")` |
| Knob | `RetroKnob` | `SKKnob(_:selection:stops:defaultValue:)`, `SKKnob(_:value:in:step:defaultValue:format:)` | `SKKnob("Padding", value: $padding, in: 0...100, defaultValue: 0)` |
| Settings row | `SettingsWindow.row` | `SKRow(title:subtitle:) { control }` | `SKRow(title: "Microphone") { SKChip("Built-in") }` |
| Settings group | `SettingsWindow.group` | `SKGroup(caption:note:) { rows }` | `SKGroup(caption: "Recording") { rowA; rowB }` |

The launcher's pieces (Skreener's menu-bar menu): a tile is a 34 pt key (corner radius 7) with its symbol at 15 pt, a
4 pt lamp 10 pt in from the face's top right corner (teal, white on orange), the title as a caption 4 pt under the key
and an optional legend in 9 pt mono under that; a captioned key is a 26 pt key with its symbol at 12 pt and an 8 pt
semibold caption 2 pt under it, with an optional red lamp for a key that turns something on and off. On the Mac both
sink, and light the tile's lamp, while the pointer is over them, and `onHover` lets a status strip show the key's name
and shortcut. A key group is a well of radius 8 with the keys 4 pt apart and 6 pt in, sharing its width. The status
strip is 24 pt of glass (radius 6) with a 9.5 pt heavy caption at the left and 10 pt mono at the right. A picker's chip
is chip glass 20 pt tall, at least 44 pt wide, in 10 pt bold mono, between 18 pt round arrows 4 pt off; a knob is 52 pt
with ticks lit orange up to the value (11 round a smooth one), its end values in 8 pt mono under it, and its value on a
chip in a bezel 10 pt to its right, at least 64 pt wide.

Behaviour that is the same everywhere: a key presses down at once (no animation) and gives a light haptic on iOS; keys,
toggles and segments take taps in at least 44 x 44 pt on iOS; captions and hints scale with Dynamic Type on iOS
(captions up to `.accessibility1`); blinking lamps blink at 1 s (`SK1.blinkLit`) on a `TimelineView` and stay lit with
Reduce Motion; every lamp, indicator, toggle and timer says its state to VoiceOver ("Recording: on, 1 minute 12
seconds"), and captions are read in normal case. A text field is one line of semibold 14 pt mono LCD ink on glass in the
readout's bezel, 36 pt tall, its prompt in the ink at 45%; while it has focus an orange 1.5 pt hairline rings the bezel
(orange is "on"), and tapping anywhere on the glass focuses it.

### Planned

| Component | Skreener source | Planned SwiftUI form |
|---|---|---|
| Speaker grille | `SpeakerGrille` | `SK1Grille` |
| AppKit views | all of the above | `SK1AppKit`, for apps that are not SwiftUI |

## Adopting SK1Kit in an app

The components alone don't make an app look like Skreener: the screens do. Swapping each native control for its SK-1
twin gives a flat result; laying each screen out as below gives the real thing. Agents: the `adopt-sk1kit` skill
(`.claude/skills/adopt-sk1kit/SKILL.md`; `Scripts/install-adoption-kit.sh` copies it into an app) walks through this.

### Native control → SK-1

| Native | SK-1 | Notes |
|---|---|---|
| window / sheet / popover background | `.sk1Chassis()` | on every root: each window, each `NavigationSplitView` column, each sheet and popover |
| `Form` + `Section` | `SKGroup(caption:note:)` of `SKRow(title:subtitle:)` in a scrolling pane | a `Form` you keep: `.scrollContentBackground(.hidden).sk1Chassis()` |
| `GroupBox`, a card background | `SKWell` (sunken), `SKPlate` (floating) | |
| `Divider()` | `SKGroove()`, `SKGroove(.vertical)` | menus and context menus keep `Divider()` |
| `.borderedProminent` | `.sk1Key(.orange)` | one orange key per screen |
| `.bordered`, `.link`, plain buttons | `.sk1Key()`, `.sk1Key(size: .small)`, `SKCaptionedKey` | `.sk1Key(.charcoal)` for an action apart (Settings, Quit, Delete) |
| a row of related buttons | `SKKeyTray(caption:)` in a toolbar, `SKKeyGroup(caption:)` in a launcher | the caption names the group |
| the main actions of a menu or a home screen | `SKTile` in an `SKWell` grid | legends show shortcuts |
| `Toggle` | `.toggleStyle(.sk1Switch)` in a row, `.sk1Square` in a bar | |
| `Picker` (menu), `Stepper` | `SKPicker` (◀ chip ▶), `SKPicker(stepper: false)` for a pop-up | |
| `Picker(.segmented)` | `SKSegmented` | |
| `Slider`, a number stepper | `SKKnob` (smooth, or click-stop for a few choices) | |
| `TextField` | `SKTextField` | |
| section headers, uppercase labels | `SKCaption(_, tone: .soft)` | |
| secondary text, footnotes | `.sk1Hint()` | |
| countdowns, counts, timers, progress rings | `SKDisplay`, `SKSevenSegment`, `SKElapsed`, `SKChip` | live numbers belong on the LCD |
| status line, "what's under the pointer" | `SKStatusStrip`, `SKReadout` | |
| `Color.accentColor`, a coloured status dot | `SK1.orange` for what is on; `SKLamp` for state | |

`Scripts/sk1-audit.sh <app sources>` lists what is still native, with the SK-1 part to use; a line ending in
`// sk1-audit: ignore` is skipped, for a control that is meant to stay (a system menu, an overlay with its own look).

### Screen recipes

**Menu-bar popover: a launcher** (Skreener's `MenuLauncher`). Top to bottom, 12 pt in, on `.sk1Chassis()`:
`SKStatusStrip` (the app's state at rest; the name and shortcut of the key under the pointer while hovering), the
main actions as `SKTile`s in an `SKWell` (the most important one orange), the app's content (lists in wells, captions
over them), and a last `SKKeyGroup` of `SKCaptionedKey`s ending in charcoal Settings and Quit.

```swift
@State private var hovered: (name: String, detail: String)?

VStack(spacing: 10) {
    SKStatusStrip(title: hovered?.name ?? "MyApp", detail: hovered?.detail ?? status)
    SKWell {
        HStack(spacing: 4) {
            SKTile("Record", systemImage: "record.circle", legend: "⌃⇧7", variant: .orange,
                   onHover: { hovered = $0 ? ("Record", "⌃⇧7") : nil }) { record() }
            SKTile("Open", systemImage: "folder", legend: "⌘O") { open() }
        }
        .padding(6)
    }
    content
    SKKeyGroup {
        SKCaptionedKey("History", systemImage: "clock.arrow.circlepath") { history() }
        SKCaptionedKey("Settings", systemImage: "gearshape", variant: .charcoal) { settings() }
        SKCaptionedKey("Quit", systemImage: "power", variant: .charcoal) { quit() }
    }
}
.padding(12)
.frame(width: 320)
.sk1Chassis()
```

**Main window: captioned trays over an LCD** (Skreener's editor). A toolbar row of `SKKeyTray(caption:)`s, one per
group of commands (View, Go, Tools…; the selected mode `isOn`, the primary command the one orange key), then an
`SKDisplay` the width of the window saying what is going on (the mode, the current item, a live number with its unit,
LIVE while something runs), then `SKGroove()` and the content. Content sits in wells (`SKWell`) or straight on the
chassis; lists of rows go in a well with grooves between them.

**Settings: groups of rows.** A scrolling pane, 22 pt margins and 22 pt between groups, of `SKGroup`s whose rows end
in an SK-1 control: `.sk1Switch` for on/off, `SKKnob` for a number or a few stops, `SKPicker` for a list, `SKChip` for a
read-only value, `.sk1Key()` for an action. The row's subtitle explains it; the group's note explains the group.

**A notice or alert card.** An `SKPlate` with an LCD line on top (lamp, caption, seven-segment countdown), the title
and details, then the keys: the action orange, the rest cream, a round key for close.

**Sheets and popovers.** `.sk1Chassis()` on the root (they are windows of their own), `SKGroove()` over the action
row, Cancel cream and the action orange (charcoal for Delete).

### Rules to check every screen against

1. One chassis per window, and every sheet and popover on it too: nothing white or grey shows.
2. At most one orange key on screen. When two parts of a screen each have a main action, the lesser one goes cream.
3. Live numbers (countdowns, counts, timers) are on LCD glass, in seven-segment digits or mono; prose never is.
4. Groups of controls sit in a tray with a caption; a tray's caption is never a bold heading.
5. State is a lamp (teal ready, red live, amber warning) with its meaning in the accessibility label.
6. Nothing native is left that has an SK-1 part (`Scripts/sk1-audit.sh` passes, or each finding is marked ignore with a
   reason).

### macOS pitfalls

- A `NavigationSplitView` sidebar draws its own material behind the list: put `.scrollContentBackground(.hidden)
  .sk1Chassis()` on the sidebar and on the detail, not on the split view.
- `Form` and `List` paint their own background: `.scrollContentBackground(.hidden)` before `.sk1Chassis()`.
- A `Menu`'s label is drawn by AppKit and loses custom drawing; use `SKPicker` (it lists its choices in a popover).
- A `MenuBarExtra(.window)` popover: `.sk1Chassis()` on its root view, with a fixed width.
- Keys don't animate: don't wrap SK-1 controls in `withAnimation` or `.animation`.
