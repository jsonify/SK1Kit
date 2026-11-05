// sk1-audit fixture: SK-1 throughout, so the audit reports nothing (not compiled; outside every target).
import SwiftUI
import SK1UI

struct AdoptedView: View {
    @State private var on = false
    @State private var n = 1
    @State private var text = ""

    var body: some View {
        VStack {
            SKGroup(caption: "General") {
                SKRow(title: "Launch at login") { Toggle("Launch at login", isOn: $on).toggleStyle(.sk1Switch) }
                SKRow(title: "Count") { SKKnob("Count", value: $n, in: 1...10, defaultValue: 1) }
            }
            Toggle("Mic", isOn: $on)
                .toggleStyle(.sk1Square)
            SKGroove()
            SKTextField("Name", text: $text)
            Button("Save") {}.buttonStyle(.sk1Key(.orange))
            // A Picker( in a comment is not a finding.
            Rectangle().fill(.regularMaterial) // sk1-audit: ignore (a system sheet keeps its material)
        }
        .sk1Chassis()
    }
}
