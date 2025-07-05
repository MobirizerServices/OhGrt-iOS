import Foundation
import Combine

class SubscriptionViewModel: ObservableObject {
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func createSubscription(subscriptionId: String, paymentMethod: String) {
        let request = SubscriptionRequest(subscriptionId: subscriptionId, paymentMethod: paymentMethod)
        APIService.shared.createSubscription(subscription: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
