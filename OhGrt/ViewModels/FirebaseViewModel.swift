
import Foundation
import Combine

class FirebaseViewModel: ObservableObject {
    @Published var loginSuccess = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func login(idToken: String) {
        APIService.shared.firebaseLogin(credentials: idToken)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.loginSuccess = false
                }
            } receiveValue: { _ in
                self.loginSuccess = true
            }
            .store(in: &cancellables)
    }

    func refreshToken(refreshToken: String) {
        APIService.shared.refreshToken(token: refreshToken)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func sendNotification(uid: String?, topic: String?, title: String, body: String) {
        APIService.shared.sendUserNotification(uid: uid ?? "", topic: topic ?? "", title: title, body: body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
