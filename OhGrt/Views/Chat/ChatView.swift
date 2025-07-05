import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Chat Screen")
                    .font(.title)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.purple)
                Text("Back")
                    .foregroundColor(.purple)
            })
        }
    }
} 