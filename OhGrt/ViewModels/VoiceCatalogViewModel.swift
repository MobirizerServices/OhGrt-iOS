import Foundation
import Combine

class VoiceCatalogViewModel: ObservableObject {
    @Published var voiceCatalog: VoiceCatalogResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchVoiceCatalog() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getVoiceCatalog()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.voiceCatalog = response
            }
            .store(in: &cancellables)
    }
    
    // Helper method to get speakers for a specific language
    func getSpeakers(for languageCode: String) -> [Speaker]? {
        return voiceCatalog?.languages.first { $0.code == languageCode }?.speakers
    }
    
    // Helper method to get all available languages
    func getAvailableLanguages() -> [Language] {
        return voiceCatalog?.languages ?? []
    }
} 