import SwiftUI

struct AddListItemInput: View {
    @Binding var text: String
    var placeholder: String
    var buttonLabel: String
    var onAdd: () -> Void

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .onSubmit(onAdd)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 2)
                )
            Button(action: onAdd) {
                Text(buttonLabel)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }
}

#Preview {
    AddListItemInput(
        text: .constant(""),
        placeholder: "New item",
        buttonLabel: "Add"
    ) {}
} 