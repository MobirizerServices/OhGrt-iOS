import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Signing in...")
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    GoogleSignInButton(action: viewModel.signInWithGoogle)
                        .frame(width: 280, height: 50)
                        .padding()
                }
            }
            .navigationTitle("Login")
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                DashboardView()
            }
            .onReceive(viewModel.$errorMessage) { error in
                showAlert = error != nil
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Something went wrong"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

