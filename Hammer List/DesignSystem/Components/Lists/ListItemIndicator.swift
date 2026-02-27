import SwiftUI

/// Trailing indicator shown on items that contain nested child lists.
/// Displays a count badge alongside a chevron.
/// To swap the indicator style, modify only this file.
struct ListItemIndicator: View {
    let count: Int

    var body: some View {
        HStack(spacing: AppTokens.Spacing._50) {
            Text("\(count)")
                .font(AppTokens.Typography.caption)
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(alignment: .trailing, spacing: 12) {
        ListItemIndicator(count: 0)
        ListItemIndicator(count: 5)
        ListItemIndicator(count: 12)
    }
    .padding()
}
