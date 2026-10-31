#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// A settings row (Skreener's `SettingsWindow.row`): the title (12.5 pt medium, in the palette's ink) with an optional
/// hint under it on the left, `control` on the right, at least 40 pt tall; the text keeps 9 pt from the row's top and
/// bottom, the control 8 pt, and 16 pt between them. The title and hint scale with Dynamic Type on iOS.
///
/// ```swift
/// SKRow(title: "Launch at login", subtitle: "Starts in the menu bar.") {
///     Toggle("Launch at login", isOn: $launch).toggleStyle(.sk1Switch)
/// }
/// ```
public struct SKRow<Control: View>: View {
    private let title: String
    private let subtitle: String?
    private let control: Control
    @Environment(\.colorScheme) private var scheme

    public init(title: String, subtitle: String? = nil, @ViewBuilder control: () -> Control) {
        self.title = title
        self.subtitle = subtitle
        self.control = control()
    }

    public var body: some View {
        let p = SK1.palette(for: scheme)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .sk1Text(SK1.TypeScale.rowTitle, scalesWith: .subheadline)
                    .foregroundStyle(Color(sk1Hex: p.ink))
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .sk1Hint()
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 300, alignment: .leading)
                }
            }
            .padding(.vertical, 9)
            Spacer(minLength: 16)
            control
                .padding(.vertical, 8)
        }
        .frame(minHeight: SK1.Metrics.rowMinHeight)
    }
}

/// A group of settings rows (Skreener's `SettingsWindow.group`): a caption in the soft ink over a sunken tray of
/// rows, 8 pt apart, with grooves between the rows, the rows 14 pt in from the tray's sides (2 pt at the top and
/// bottom), and an optional note under the tray.
///
/// ```swift
/// SKGroup(caption: "Recording", note: "Saved to your Documents folder.") {
///     SKRow(title: "Microphone") { … }
///     SKRow(title: "Quality") { … }
/// }
/// ```
public struct SKGroup<Rows: View>: View {
    private let caption: String
    private let note: String?
    private let rows: Rows

    public init(caption: String, note: String? = nil, @ViewBuilder rows: () -> Rows) {
        self.caption = caption
        self.note = note
        self.rows = rows()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SK1.Metrics.captionToWell) {
            SKCaption(caption, tone: .soft)
                .accessibilityAddTraits(.isHeader)
            SKWell {
                _VariadicView.Tree(SK1GroovedRows()) { rows }
                    .padding(.horizontal, SK1.Metrics.rowInset)
                    .padding(.vertical, 2)
            }
            if let note {
                Text(note)
                    .sk1Hint()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The rows one under another with a groove between each two.
struct SK1GroovedRows: _VariadicView_UnaryViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        return VStack(spacing: 0) {
            ForEach(children) { child in
                if child.id != first { SKGroove() }
                child
            }
        }
    }
}
#endif
