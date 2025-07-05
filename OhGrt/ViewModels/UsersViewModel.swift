import Foundation
import Combine

class UsersViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchUserProfile() {
        APIService.shared.getUserProfile()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { profile in
                self.userProfile = profile
            }
            .store(in: &cancellables)
    }
}
