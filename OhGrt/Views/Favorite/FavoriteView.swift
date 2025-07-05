import SwiftUI

struct FavoriteView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Favorite Screen")
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