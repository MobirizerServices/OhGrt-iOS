import Foundation
import Combine
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var profileImageURL: URL?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isNotificationsOn = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load saved notification preference
        isNotificationsOn = UserDefaults.standard.bool(forKey: "isNotificationsOn")
    }
    
    func fetchUserProfile() {
        isLoading = true
        error = nil
        
        APIService.shared.getUserProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] profile in
                self?.userProfile = profile
                if let imageUrlString = profile.user.profileImage,
                   let url = URL(string: imageUrlString) {
                    self?.profileImageURL = url
                }
            }
            .store(in: &cancellables)
    }
    
    func updateProfile(name: String?, profileImage: Data?) {
        isLoading = true
        error = nil
        
        // First update profile image if provided
        if let imageData = profileImage {
            APIService.shared.uploadProfileImage(imageData: imageData)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                        self?.isLoading = false
                    }
                } receiveValue: { [weak self] response in
                    // After image upload, update profile with name and new image URL
                    self?.updateProfileDetails(name: name, profileImageUrl: response.url)
                }
                .store(in: &cancellables)
        } else {
            // If no new image, just update profile details
            updateProfileDetails(name: name, profileImageUrl: nil)
        }
    }
    
    private func updateProfileDetails(name: String?, profileImageUrl: String?) {
        let update = UserProfileUpdate(
            name: name,
            profileImage: profileImageUrl
        )
        
        APIService.shared.updateUserProfile(profile: update)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] profile in
                self?.userProfile = profile
                if let imageUrlString = profile.user.profileImage,
                   let url = URL(string: imageUrlString) {
                    self?.profileImageURL = url
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleNotifications() {
        isNotificationsOn.toggle()
        UserDefaults.standard.set(isNotificationsOn, forKey: "isNotificationsOn")
        
        // Here you would typically also update the notification settings on the server
        // and update the FCM token if needed
    }
    
    func logout() {
        // Clear user data
        userProfile = nil
        profileImageURL = nil
        isNotificationsOn = false
        
        // Clear stored tokens
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        
        // Here you would typically also call your logout API endpoint
        // and handle any cleanup needed
    }
    
    func getSavedUserData() {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            // Use the user data
        }
    }
} 