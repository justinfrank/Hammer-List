import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Follow System Appearance", isOn: $themeManager.followSystem)

                if !themeManager.followSystem {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.override },
                        set: { themeManager.override = $0 }
                    )) {
                        ForEach(ThemeManager.Override.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
} 