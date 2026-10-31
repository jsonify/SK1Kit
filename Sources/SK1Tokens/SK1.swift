import Foundation

/// The SK-1 look, after the MT-1 Menu Timer panel: a cream chassis (charcoal in Dark Mode) with sunken trays of
/// raised keys, an olive LCD with seven-segment digits, and orange for what is on and for the main action.
///
/// This is the framework-free part: the tokens (colours as 0xRRGGBB numbers, type styles and metrics as plain
/// numbers), the seven-segment geometry and the knob arithmetic. It imports Foundation only, so it builds and tests
/// on Linux too. The SwiftUI and AppKit layers turn these numbers into colours, fonts and views.
///
/// - `SK1.palette(dark:)` / `SK1.Palette` (`SK1.light`, `SK1.dark`): the colours that change with the appearance.
///   The fixed ones: `SK1.orange` (what is on, the main action), the orange and charcoal keys', the LCD's
///   (`glassTop`…, `chipTop`…, `lcdInk`) and the lamps' (`teal`, `recRed`).
/// - `SK1.TypeScale`: the type styles. `SK1.Metrics`: sizes, radii and spacing.
/// - `SK1.blinkLit(_:)`: whether a blinking lamp is lit (1 s, lit for the first half).
/// - `SK1.RGB` and `SK1.contrast(_:_:)`: WCAG 2 contrast between two colours.
/// - `SK1.SevenSegment`: the digits' geometry. `SK1.KnobScale`: a knob's arithmetic.
public enum SK1 {
    /// The colours that change between light and dark, as 0xRRGGBB (alphas as fractions).
    public struct Palette: Equatable, Sendable {
        public var dark: Bool
        /// The chassis, and the white glow across its top (alpha).
        public var chassis: UInt32, chassisGlow: CGFloat
        /// A groove in the chassis (a rule between groups), and the light line under it (alpha of white).
        public var groove: UInt32, grooveLip: CGFloat
        /// A sunken tray: its floor from top to bottom, its inner shadow (alpha) and the light lip under it (alpha).
        public var wellTop: UInt32, wellBottom: UInt32, wellShadow: CGFloat, wellLip: CGFloat
        /// A cream key: its face from top to bottom, up and pressed, the skirt under it, the light along its top edge
        /// (alpha of white), the shadow it casts (alpha), and its ink.
        public var keyTop: UInt32, keyBottom: UInt32, keyDownTop: UInt32, keyDownBottom: UInt32, keySkirt: UInt32
        public var keyHighlight: CGFloat, keyShadow: CGFloat, keyInk: UInt32
        /// The charcoal key (Settings): face top to bottom, skirt.
        public var charcoalTop: UInt32, charcoalBottom: UInt32, charcoalSkirt: UInt32
        /// Captions and labels; secondary text and a key's legend.
        public var ink: UInt32, inkSoft: UInt32
        /// The segmented control's track and its unselected text; a toggle's square when off.
        public var track: UInt32, trackInk: UInt32, toggleOff: UInt32
        /// The LCD's bezel, top to bottom, and how bright its glass is (1 in light; a touch dimmer in dark).
        public var bezelTop: UInt32, bezelBottom: UInt32, lcdBrightness: CGFloat
        /// The canvas well behind a screenshot, and its dots (alpha).
        public var canvas: UInt32, canvasDot: CGFloat
        /// A speaker grille's holes, lit side and dark side.
        public var grilleLight: UInt32, grilleDark: UInt32

        public init(
            dark: Bool, chassis: UInt32, chassisGlow: CGFloat, groove: UInt32, grooveLip: CGFloat,
            wellTop: UInt32, wellBottom: UInt32, wellShadow: CGFloat, wellLip: CGFloat,
            keyTop: UInt32, keyBottom: UInt32, keyDownTop: UInt32, keyDownBottom: UInt32, keySkirt: UInt32,
            keyHighlight: CGFloat, keyShadow: CGFloat, keyInk: UInt32,
            charcoalTop: UInt32, charcoalBottom: UInt32, charcoalSkirt: UInt32,
            ink: UInt32, inkSoft: UInt32, track: UInt32, trackInk: UInt32, toggleOff: UInt32,
            bezelTop: UInt32, bezelBottom: UInt32, lcdBrightness: CGFloat,
            canvas: UInt32, canvasDot: CGFloat, grilleLight: UInt32, grilleDark: UInt32
        ) {
            self.dark = dark
            self.chassis = chassis; self.chassisGlow = chassisGlow
            self.groove = groove; self.grooveLip = grooveLip
            self.wellTop = wellTop; self.wellBottom = wellBottom; self.wellShadow = wellShadow; self.wellLip = wellLip
            self.keyTop = keyTop; self.keyBottom = keyBottom; self.keyDownTop = keyDownTop
            self.keyDownBottom = keyDownBottom; self.keySkirt = keySkirt
            self.keyHighlight = keyHighlight; self.keyShadow = keyShadow; self.keyInk = keyInk
            self.charcoalTop = charcoalTop; self.charcoalBottom = charcoalBottom; self.charcoalSkirt = charcoalSkirt
            self.ink = ink; self.inkSoft = inkSoft
            self.track = track; self.trackInk = trackInk; self.toggleOff = toggleOff
            self.bezelTop = bezelTop; self.bezelBottom = bezelBottom; self.lcdBrightness = lcdBrightness
            self.canvas = canvas; self.canvasDot = canvasDot
            self.grilleLight = grilleLight; self.grilleDark = grilleDark
        }
    }

    public static let light = Palette(
        dark: false, chassis: 0xebe8e1, chassisGlow: 0.55, groove: 0xd3cfc5, grooveLip: 0.7,
        wellTop: 0xe2ded6, wellBottom: 0xe9e6df, wellShadow: 0.16, wellLip: 0.9,
        keyTop: 0xfdfcfa, keyBottom: 0xe8e4dc, keyDownTop: 0xece9e2, keyDownBottom: 0xf6f4ef, keySkirt: 0xc7c2b7,
        keyHighlight: 1, keyShadow: 0.14, keyInk: 0x2b2a27,
        charcoalTop: 0x45433e, charcoalBottom: 0x252421, charcoalSkirt: 0x11100f,
        ink: 0x2b2a27, inkSoft: 0x67635a, track: 0xdcd8cf, trackInk: 0x57534b, toggleOff: 0xd3cfc5,
        bezelTop: 0xd2cec4, bezelBottom: 0xe2ded6, lcdBrightness: 1,
        canvas: 0xdcd8cf, canvasDot: 0.09, grilleLight: 0x8f8a80, grilleDark: 0x3d3b37)

    public static let dark = Palette(
        dark: true, chassis: 0x2b2a27, chassisGlow: 0.06, groove: 0x1a1917, grooveLip: 0.06,
        wellTop: 0x1d1c1a, wellBottom: 0x242320, wellShadow: 0.5, wellLip: 0.07,
        keyTop: 0x4a4843, keyBottom: 0x36342f, keyDownTop: 0x302e2a, keyDownBottom: 0x3a3833, keySkirt: 0x1a1917,
        keyHighlight: 0.1, keyShadow: 0.45, keyInk: 0xece8df,
        charcoalTop: 0x2c2a27, charcoalBottom: 0x181715, charcoalSkirt: 0x0a0a09,
        ink: 0xece8df, inkSoft: 0xa8a397, track: 0x1f1e1c, trackInk: 0xa8a397, toggleOff: 0x4a4843,
        bezelTop: 0x1d1c1a, bezelBottom: 0x26251f, lcdBrightness: 0.86,
        canvas: 0x1f1e1c, canvasDot: 0.07, grilleLight: 0x1a1917, grilleDark: 0x0b0b0a)

    // The colours that are the same in light and dark.
    /// What is on: a toggle's square, the selected key's bar.
    public static let orange: UInt32 = 0xff5c1c
    /// The orange key (the main action): face top to bottom, skirt.
    public static let orangeTop: UInt32 = 0xff8045, orangeBottom: UInt32 = 0xf2520f, orangeSkirt: UInt32 = 0xb93a07
    /// The charcoal key's ink and the selected segment's.
    public static let charcoalInk: UInt32 = 0xf2efe9
    /// The selected segment, top to bottom.
    public static let segmentTop: UInt32 = 0x45433e, segmentBottom: UInt32 = 0x2a2926
    /// The LCD's glass, top to bottom, and its ink.
    public static let glassTop: UInt32 = 0xd3d9be, glassMiddle: UInt32 = 0xc3caad, glassBottom: UInt32 = 0xb9c0a2
    public static let lcdInk: UInt32 = 0x1e2318
    /// An LCD chip's glass, top to bottom.
    public static let chipTop: UInt32 = 0xcfd5ba, chipMiddle: UInt32 = 0xc7cdb1, chipBottom: UInt32 = 0xbfc6a9
    /// A lamp's teal (a key under the pointer) and the REC lamp's red (the timer's).
    public static let teal: UInt32 = 0x1f9e86, recRed: UInt32 = 0xe0402f
    /// How far a blinking lamp dims between blinks.
    public static let lampDimmed: CGFloat = 0.2

    /// Whether a lamp that has blinked for `elapsed` seconds is lit: once a second, lit for the first half of it.
    public static func blinkLit(_ elapsed: TimeInterval) -> Bool { Int((max(elapsed, 0) * 2).rounded(.down)) % 2 == 0 }

    /// The palette for the appearance: `dark` for Dark Mode.
    public static func palette(dark: Bool) -> Palette { dark ? Self.dark : light }
}
