
import Foundation
import Combine

class PointsViewModel: ObservableObject {
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func getPoints() {
        APIService.shared.getPoints()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
