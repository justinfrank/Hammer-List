import SwiftUI

struct SideMenu: View {
    @Binding var isMenuOpen: Bool
    var onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        onClose()
                    }
                }
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Menu")
                        .font(.title.bold())
                        .padding(.top, 40)
                    Divider()
                    Button("List") {}
                    Button("Split view") {}
                    Spacer()
                }
                .frame(width: 250)
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
                Spacer()
            }
            .transition(.move(edge: .leading))
        }
    }
}

#Preview {
    SideMenu(isMenuOpen: .constant(true)) {}
} 