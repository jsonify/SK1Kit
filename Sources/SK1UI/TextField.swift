#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// A one-line text field on LCD glass (DESIGN.md's planned "LCD text field", after Skreener's `LCDTextBox`): the
/// text in semibold mono LCD ink with a faint ghost, the caret in the ink, the prompt in the ink at 45%, inside the
/// readout's small bezel (radius 7, the glass 3 pt in). 36 pt tall by default. While it has focus, an orange hairline
/// (SK-1's "on") rings the bezel. Tapping anywhere on the glass focuses it; on iOS it takes taps in at least 44 pt
/// of height. Dimmed when disabled. VoiceOver reads `title` as its name.
///
/// Text-input modifiers on it reach the field inside (`.onSubmit`, `.submitLabel`, `.textInputAutocapitalization`,
/// `.textContentType`, `.autocorrectionDisabled`).
///
/// ```swift
/// SKTextField("Meeting name", text: $title)
/// SKTextField("Role", text: $role, prompt: "Chair, Treasurer, Member…")
/// ```
public struct SKTextField: View {
    private let title: String
    @Binding private var text: String
    private let prompt: String?
    private let height: CGFloat
    @FocusState private var focused: Bool
    @Environment(\.isEnabled) private var isEnabled

    /// `prompt` shows while the field is empty (`title` if not given).
    public init(_ title: String, text: Binding<String>, prompt: String? = nil, height: CGFloat = 36) {
        self.title = title
        _text = text
        self.prompt = prompt
        self.height = height
    }

    public var body: some View {
        let ink = Color(sk1Hex: SK1.lcdInk)
        SKLCD(radius: 7, inset: 3) {
            TextField(title, text: $text, prompt: Text(prompt ?? title).foregroundStyle(ink.opacity(0.45)))
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .sk1LCDInk()
                .tint(ink)
                .lineLimit(1)
                .focused($focused)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(height: height)
        .overlay {
            if focused {
                RoundedRectangle(cornerRadius: 7)
                    .inset(by: -1)
                    .stroke(Color(sk1Hex: SK1.orange), lineWidth: 1.5)
                    .allowsHitTesting(false)
            }
        }
        .opacity(isEnabled ? 1 : 0.4)
        .contentShape(Rectangle())
        .onTapGesture { if isEnabled { focused = true } }
        .sk1MinimumHitArea(width: 44, height: height)
    }
}
#endif
