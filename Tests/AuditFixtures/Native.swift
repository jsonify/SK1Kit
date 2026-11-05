// sk1-audit fixture: one of each native pattern the audit reports (not compiled; outside every target).
import SwiftUI

struct NativeView: View {
    @State private var on = false
    @State private var value = 1.0
    @State private var n = 1
    @State private var text = ""
    @State private var choice = 0

    var body: some View {
        Form {
            Picker("Choice", selection: $choice) { Text("A").tag(0) }
            Picker("Mode", selection: $choice) { Text("A").tag(0) }.pickerStyle(.segmented)
            Stepper("Count", value: $n)
            Slider(value: $value)
            Divider()
            Button("Save") {}.buttonStyle(.borderedProminent)
            Button("Cancel") {}.buttonStyle(.bordered)
            Button("More") {}.buttonStyle(.link)
            Circle().fill(Color.accentColor)
            Rectangle().fill(.regularMaterial)
            GroupBox("Box") { Text("Inside") }
            TextField("Name", text: $text)
            Text("Heading").textCase(.uppercase)
            Circle().trim(from: 0, to: 0.5)
            Toggle("Plain", isOn: $on)
        }
    }
}
