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

## Components (planned, phase 2)

None of these exist in this package yet. Each is a SwiftUI form of a Skreener AppKit view.

| Component | Skreener source | Planned SwiftUI form |
|---|---|---|
| Chassis | `ChassisView`, `ChassisPlate` (`Retro.swift`) | `SK1Chassis` background and `SK1Plate` container |
| Well | `RetroWell`, `Retro.drawWell` | `SK1Well` container |
| Keycap | `PillButton` `.keycap` (`PillButton.swift`) | `SK1KeyStyle` button style with cream, orange and charcoal variants |
| Toggle | `PillButton` `.toggle`, `RetroSwitch` | `SK1ToggleStyle` |
| Round key | `PillButton` `.round` | `SK1RoundKeyStyle` |
| Pop-up | `PillPopUp` | `SK1Picker` with an LCD chip and optional stepper |
| Keycap tray | `KeycapTray` | `SK1KeyTray` with a caption |
| Segmented | `RetroSegmented` | `SK1Segmented` |
| Indicator | `RetroIndicator` | `SK1Indicator` |
| Lamp | `Retro.drawLamp` | `SK1Lamp` with blink and accessibility label |
| LCD glass and readout | `Retro.drawLCD`, `LCDReadout`, `LCDChip`, `LCDTextBox` | `SK1LCD`, `SK1LCDChip` |
| Seven-segment text | `SevenSegmentView` | `SK1SevenSegmentText` (SwiftUI `Canvas`) |
| Knob | `RetroKnob` | `SK1Knob` |
| Groove | `RetroGroove` | `SK1Groove` |
| Caption label | `RetroLabel` | `SK1Caption` and text styles from `TypeScale` |
| Speaker grille | `SpeakerGrille` | `SK1Grille` |
