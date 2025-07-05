import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let googleSignInService = GoogleSignInService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check if user and accessToken exist
        if let _ = UserDefaults.standard.user, let token = UserDefaults.standard.accessToken, !token.isEmpty {
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func signInWithGoogle() {
        // Prevent multiple API calls if already loading
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        googleSignInService.signIn()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] (user, accessToken) in
                guard let self = self else { return }
                
                // Save tokens and user data
                UserDefaults.standard.accessToken = accessToken
                UserDefaults.standard.user = User(id: user.userID ?? "", 
                                                email: user.profile?.email ?? "", 
                                                name: user.profile?.name ?? "")
                
                // Update authentication state on main thread
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func loginWithFirebase(idToken: String) {
        APIService.shared.firebaseLogin(credentials: idToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // Only proceed if the response is successful
                if response.success {
                    // Save tokens and user data
                    UserDefaults.standard.accessToken = response.data?.accessToken
                    UserDefaults.standard.refreshToken = response.data?.refreshToken
                    UserDefaults.standard.user = User(id: response.data?.uid ?? "", 
                                                    email: response.data?.email ?? "", 
                                                    name: response.data?.name ?? "")
                    
                    // Update authentication state on main thread
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                } else {
                    self.errorMessage = response.message
                }
            }
            .store(in: &cancellables)
    }
} 
