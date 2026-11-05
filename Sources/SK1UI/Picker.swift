#if canImport(SwiftUI)
import SwiftUI
import SK1Tokens

/// A choice shown on a small LCD chip, with round arrows either side that step to the choice before or after (Skreener's
/// `PillPopUp` in its `.lcd` style with `stepper`: ◀ 3 PT ▶). A click on the chip lists every choice in a popover on
/// the chassis, the chosen one with its orange square. The chip is as wide as the widest choice, so it doesn't change
/// size as the choice does; an arrow at the end of the list is dimmed. An optional caption sits to the left. VoiceOver
/// reads it as a picker.
///
/// ```swift
/// SKPicker(selection: $stroke, options: [.init(1, "1 pt"), .init(3, "3 pt"), .init(6, "6 pt")], caption: "Stroke")
/// SKPicker(selection: $format, options: formats, stepper: false)   // the chip alone, a pop-up
/// ```
public struct SKPicker<Value: Hashable>: View {
    /// One choice: its value and what the chip shows for it.
    public struct Option: Identifiable {
        public var value: Value
        public var label: String
        public var id: Value { value }

        public init(_ value: Value, _ label: String) {
            self.value = value
            self.label = label
        }
    }

    @Binding private var selection: Value
    private let options: [Option]
    private let caption: String?
    private let stepper: Bool
    @State private var choosing = false
    @Environment(\.isEnabled) private var isEnabled

    public init(selection: Binding<Value>, options: [Option], caption: String? = nil, stepper: Bool = true) {
        _selection = selection
        self.options = options
        self.caption = caption
        self.stepper = stepper
    }

    private var index: Int? { options.firstIndex { $0.value == selection } }

    public var body: some View {
        HStack(spacing: 4) {
            if let caption {
                SKCaption(caption).padding(.trailing, 3).accessibilityHidden(true)
            }
            if stepper { arrow(-1, symbol: "arrowtriangle.left.fill", name: "Previous").disabled(index == 0) }
            Button { choosing = true } label: { chip }
                .buttonStyle(SK1PlainButtonStyle())
                .popover(isPresented: $choosing, arrowEdge: .bottom) {
                    SK1PickerList(options: options.map { (label: $0.label, chosen: $0.value == selection) }) { i in
                        selection = options[i].value
                        choosing = false
                    }
                }
            if stepper {
                arrow(1, symbol: "arrowtriangle.right.fill", name: "Next").disabled(index == options.count - 1)
            }
        }
        .fixedSize()
        .accessibilityRepresentation {
            Picker(caption ?? "", selection: $selection) {
                ForEach(options) { Text($0.label).tag($0.value) }
            }
        }
    }

    /// The chosen choice on chip glass, as wide as the widest.
    private var chip: some View {
        ZStack {
            ForEach(options) { Text($0.label).hidden() }
            Text(options.first { $0.value == selection }?.label ?? "–")
        }
        .font(.system(size: 10, weight: .bold, design: .monospaced))
        .tracking(0.5)
        .foregroundStyle(Color(sk1Hex: SK1.lcdInk))
        .lineLimit(1)
        .padding(.horizontal, 7)
        .frame(minWidth: 44, minHeight: 20, maxHeight: 20)
        .background(SKGlass(.chip, radius: 3))
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : 0.4)
    }

    private func arrow(_ by: Int, symbol: String, name: String) -> some View {
        Button { step(by) } label: { Image(systemName: symbol) }
            .buttonStyle(.sk1Key(.round, size: .mini))
            .accessibilityLabel(Text(caption.map { "\($0): \(name.lowercased())" } ?? name))
    }

    /// The choice `by` places on from the chosen one (from the first or last when none is chosen); nothing past the ends.
    private func step(_ by: Int) {
        guard !options.isEmpty else { return }
        let i = (index ?? (by > 0 ? -1 : options.count)) + by
        guard options.indices.contains(i) else { return }
        selection = options[i].value
    }
}

/// The popover's list: each choice in mono after a toggle square, orange for the chosen one, on the chassis.
struct SK1PickerList: View {
    let options: [(label: String, chosen: Bool)]
    let pick: (Int) -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = SK1.palette(for: scheme)
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { i, option in
                Button { pick(i) } label: {
                    HStack(spacing: 7) {
                        SK1SquareIndicator(on: option.chosen)
                        Text(option.label)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color(sk1Hex: option.chosen ? p.ink : p.inkSoft))
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 10)
                    .frame(minHeight: 26)
                    .contentShape(Rectangle())
                }
                .buttonStyle(SK1PlainButtonStyle())
                .accessibilityAddTraits(option.chosen ? .isSelected : [])
            }
        }
        .padding(.vertical, 6)
        .frame(minWidth: 140, alignment: .leading)
        .sk1Chassis()
        .presentationCompactAdaptation(.popover)
    }
}
#endif
