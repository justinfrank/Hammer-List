import SwiftUI

final class ThemeManager: ObservableObject {
    enum Override: String, CaseIterable, Identifiable {
        case light
        case dark

        var id: String { rawValue }

        var colorScheme: ColorScheme {
            switch self {
            case .light: return .light
            case .dark: return .dark
            }
        }

        var title: String { rawValue.capitalized }
    }

    @AppStorage("theme.followSystem") var followSystem: Bool = true
    @AppStorage("theme.override") private var overrideRaw: String = Override.dark.rawValue

    var override: Override {
        get { Override(rawValue: overrideRaw) ?? .dark }
        set { overrideRaw = newValue.rawValue }
    }

    /// If `nil`, the app follows the system.
    var preferredColorScheme: ColorScheme? {
        followSystem ? nil : override.colorScheme
    }

    func theme(for effectiveScheme: ColorScheme) -> AppTheme {
        effectiveScheme == .dark ? .dark : .light
    }

    /// Returns the active AppTheme based on the current system color scheme.
    /// Pass `@Environment(\.colorScheme)` from the call site.
    func currentTheme(for systemScheme: ColorScheme) -> AppTheme {
        theme(for: followSystem ? systemScheme : override.colorScheme)
    }
}
