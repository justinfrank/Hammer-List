import SwiftUI

struct ListHeader<Trailing: View>: View {
    @Binding var listName: String
    var trailing: (() -> Trailing)? = nil
    
    var body: some View {
        HStack {
            Text(listName)
                .font(.largeTitle.bold())
                .padding(.vertical, 8)
                .padding(.horizontal)
            Spacer()
            if let trailing = trailing {
                trailing()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
    }
}

#Preview {
    VStack(spacing: 16) {
        ListHeader<EmptyView>(listName: .constant("My Tasks"))
        ListHeader<Button<Text>>(listName: .constant("My Tasks"), trailing: { Button("Edit") {} })
    }
} 