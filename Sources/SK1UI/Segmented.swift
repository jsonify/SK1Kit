#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// A few choices in a sunken track, the chosen one a charcoal key with light text (Skreener's `RetroSegmented`): the
/// track 24 pt tall with radius 6, the segments 2 pt inside it and 2 pt apart, each as wide as its upper-case title
/// plus 14 pt. An option can carry a badge after its title ("REVIEW · 3"). An optional caption sits to its left.
///
/// ```swift
/// SKSegmented(selection: $tab, options: [
///     .init(.notes, "Notes"),
///     .init(.review, "Review", badge: "3"),
/// ])
/// ```
public struct SKSegmented<Value: Hashable>: View {
    /// One choice: its value, its title, an optional badge after the title and an optional spoken name.
    public struct Option: Identifiable {
        public var value: Value
        public var label: String
        public var badge: String?
        /// What VoiceOver says instead of the title (e.g. "Open Head" for "Open").
        public var help: String?
        public var id: Value { value }

        public init(_ value: Value, _ label: String, badge: String? = nil, help: String? = nil) {
            self.value = value
            self.label = label
            self.badge = badge
            self.help = help
        }

        /// The title as shown, badge included.
        public var title: String { SK1.Format.segmentTitle(label, badge: badge) }
        /// The spoken name, badge included.
        public var accessibilityLabel: String {
            help.map { SK1.Format.segmentAccessibilityLabel($0, badge: badge) }
                ?? SK1.Format.segmentAccessibilityLabel(label, badge: badge)
        }
    }

    @Binding private var selection: Value
    private let options: [Option]
    private let caption: String?
    private let height: CGFloat
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    public init(selection: Binding<Value>, options: [Option], caption: String? = nil, height: CGFloat = 24) {
        _selection = selection
        self.options = options
        self.caption = caption
        self.height = height
    }

    public var body: some View {
        let p = SK1.palette(for: scheme)
        HStack(spacing: 6) {
            if let caption { SKCaption(caption).accessibilityHidden(true) }
            HStack(spacing: 2) {
                ForEach(options) { option in segment(option, palette: p) }
            }
            .padding(2)
            .frame(height: height)
            .background(SK1Canvas { ctx, rect, p in
                let track = Color(sk1Hex: p.track)
                SK1Draw.well(ctx, rect.insetBy(dx: 0, dy: 0.5), radius: 6, top: track, bottom: track, shadow: p.wellShadow,
                             lip: p.dark ? 0.06 : 0.8)
            })
        }
        .opacity(isEnabled ? 1 : 0.4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(caption ?? ""))
    }

    private func segment(_ option: Option, palette p: SK1.Palette) -> some View {
        let selected = option.value == selection
        return Button {
            selection = option.value
        } label: {
            Text(option.title)
                .sk1Text(SK1.TextStyle(size: SK1.TypeScale.caption.size, weight: SK1.TypeScale.caption.weight, kern: 0.6,
                                       uppercase: true))
                .foregroundStyle(Color(sk1Hex: selected ? SK1.charcoalInk : p.trackInk))
                .lineLimit(1)
                .padding(.horizontal, 7)
                .frame(maxHeight: .infinity)
                .background {
                    if selected {
                        SK1Canvas(outset: 2) { ctx, rect, _ in
                            let path = SK1Draw.roundedRect(rect.insetBy(dx: 0.5, dy: 0.5), 4)
                            var c = ctx
                            c.addFilter(.shadow(color: .black.opacity(0.3), radius: SK1Draw.radius(blur: 1.5), x: 0, y: 0.5))
                            c.fill(path, with: .color(Color(sk1Hex: SK1.segmentBottom)))
                            SK1Draw.fill(ctx, path, top: Color(sk1Hex: SK1.segmentTop), bottom: Color(sk1Hex: SK1.segmentBottom))
                        }
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(SK1PlainButtonStyle())
        .sk1MinimumHitArea(width: 44, height: height - 4)
        .accessibilityLabel(Text(option.accessibilityLabel))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
#endif
