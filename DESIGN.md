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
| Settings row | `SettingsWindow.row` | `SKRow(title:subtitle:) { control }` | `SKRow(title: "Microphone") { SKChip("Built-in") }` |
| Settings group | `SettingsWindow.group` | `SKGroup(caption:note:) { rows }` | `SKGroup(caption: "Recording") { rowA; rowB }` |

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
| Pop-up | `PillPopUp` | `SK1Picker` with an LCD chip and optional stepper |
| Knob | `RetroKnob` | `SK1Knob` (the arithmetic is `SK1.KnobScale`) |
| Speaker grille | `SpeakerGrille` | `SK1Grille` |
| AppKit views | all of the above | `SK1AppKit`, for apps that are not SwiftUI |
