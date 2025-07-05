import Foundation
import Combine

class StoryViewModel: ObservableObject {
    @Published var story: StoryGenerateStoryResponse?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func generateStory(prompt: String, language: String = "English", sceneCount: Int = 1) {
//        let request = StoryGenerateStoryRequest(prompt: prompt, language: language, sceneCount: sceneCount)
//        APIService.shared.generateStory(request: request)
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                if case .failure(let error) = completion {
//                    self.errorMessage = error.localizedDescription
//                }
//            } receiveValue: { response in
//                self.story = response
//            }
//            .store(in: &cancellables)
    }
}
