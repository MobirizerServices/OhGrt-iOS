import Foundation
import Combine

class VideoViewModel: ObservableObject {
    @Published var jobId: String?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func startVideoJob(storyId: String, voiceId: String, style: String? = nil, music: String? = nil, resolution: String? = nil) {
        let request = VideoJobRequest(storyId: storyId, voiceId: voiceId, style: style, music: music, resolution: resolution)
        APIService.shared.startVideoJob(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
                self.jobId = response.jobId
            }
            .store(in: &cancellables)
    }
}
