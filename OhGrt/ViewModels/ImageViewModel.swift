import Foundation
import Combine
import UIKit

class ImageViewModel: ObservableObject {
    @Published var imageURL: String?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    
    // Simple in-memory image cache
    static let imageCache = NSCache<NSString, UIImage>()
    
    func getCachedImage(for url: String) -> UIImage? {
        Self.imageCache.object(forKey: url as NSString)
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        Self.imageCache.setObject(image, forKey: url as NSString)
    }

    func generateImage(prompt: String, size: ImageSize, negativePrompt: String = "", numInferenceSteps: Int = 28, guidanceScale: Float = 8, numImages: Int = 1, enableSafetyChecker: Bool = true, outputFormat: String = "jpeg", styleName: String = "(No style)", seed: Int = 100, sceneNumber: Int? = nil) {
        let request = ImageGenerationRequest(
            prompt: prompt,
            negativePrompt: negativePrompt,
            imageSize: size,
            numInferenceSteps: numInferenceSteps,
            guidanceScale: guidanceScale,
            numImages: numImages,
            enableSafetyChecker: enableSafetyChecker,
            outputFormat: outputFormat,
            styleName: styleName
        )
        APIService.shared.generateImage(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
                if let urlString = response.data?.imageUrl {
                    self.imageURL = urlString
                    // Download and cache the image
                    self.downloadAndCacheImage(from: urlString)
                    // Save imageURL to LocalStoryData for the correct scene
                    if let sceneNum = sceneNumber {
                        self.saveImageUrlToLocalSceneData(imageUrl: urlString, sceneNumber: sceneNum)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func downloadAndCacheImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        // If already cached, do nothing
        if Self.imageCache.object(forKey: urlString as NSString) != nil {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            Self.imageCache.setObject(image, forKey: urlString as NSString)
        }
        task.resume()
    }

    // Save imageUrl to LocalSceneData for the correct scene number
    private func saveImageUrlToLocalSceneData(imageUrl: String, sceneNumber: Int) {
        var stories = LocalStoryManager.shared.loadStories()
        guard !stories.isEmpty else { return }
        var story = stories.removeLast()
        if let idx = story.scenes.firstIndex(where: { $0.sceneNumber == sceneNumber }) {
            var scene = story.scenes[idx]
            scene = LocalSceneData(
                sceneNumber: scene.sceneNumber,
                imagePrompt: scene.imagePrompt,
                imageURL: imageUrl,
                videoPrompt: scene.videoPrompt,
                audioPrompt: scene.audioPrompt,
                audioJobId: scene.audioJobId,
                audioURL: scene.audioURL
            )
            story.scenes[idx] = scene
            stories.append(story)
            LocalStoryManager.shared.clearStories()
            for s in stories { LocalStoryManager.shared.saveStory(s) }
        }
    }
}
