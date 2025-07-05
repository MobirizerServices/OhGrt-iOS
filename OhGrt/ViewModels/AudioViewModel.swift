import Foundation
import Combine
import CryptoKit

class AudioViewModel: ObservableObject {
    @Published var audioURL: String?
    @Published var errorMessage: String?
    @Published var jobId: String?
    @Published var status: String?
    @Published var audioProgressStatus: String?

    private var cancellables = Set<AnyCancellable>()
    // Audio cache: key is a unique identifier for the scene (e.g., hash of prompt+voice+lang)
    static let audioCache = NSCache<NSString, NSData>()

    // Helper to generate a cache key
    private func cacheKey(prompt: String, audioVoice: String, langCode: String) -> String {
        return "\(prompt)_\(audioVoice)_\(langCode)".sha256()
    }

    func generateAudio(prompt: String, voice: String, lang: String) {
        let request = AudioGenerationRequest(text: prompt, voiceId: voice, speed: nil, pitch: nil)
        APIService.shared.generateAudio(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
                self.jobId = response.jobId
                self.status = response.status
                // Start polling for job status
                self.pollJobStatus()
            }
            .store(in: &cancellables)
    }
    
    private func pollJobStatus() {
        guard let jobId = jobId else { return }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            APIService.shared.getAudioJobStatus(jobId: jobId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        self.errorMessage = error.localizedDescription
                        timer.invalidate()
                    }
                } receiveValue: { status in
                    if status.status == "completed" {
                        // Get the audio URL from the completed job
                        self.getAudioURL(for: jobId)
                        timer.invalidate()
                    } else if status.status == "failed" {
                        self.errorMessage = status.error ?? "Audio generation failed"
                        timer.invalidate()
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func getAudioURL(for jobId: String) {
        APIService.shared.getAudioProgress(jobId: jobId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { progress in
                // Assuming the audio URL is available in the progress response
                // You may need to adjust this based on your actual API response
                if progress.status == "completed" {
                    let endpoint = APIEndpoint(path: "/audio/download/\(jobId)", method: .GET)
                    self.audioURL = endpoint.url
                }
            }
            .store(in: &cancellables)
    }

    // New: Generate audio using /audio-gen/generate-audio endpoint with job polling and caching
    func generateAudioForScene(prompt: String, audioVoice: String, langCode: String, sceneNumber: Int? = nil) {
        let key = cacheKey(prompt: prompt, audioVoice: audioVoice, langCode: langCode)
        if let cachedData = Self.audioCache.object(forKey: key as NSString) {
            let tempURL = saveDataToTempFile(data: cachedData as Data, key: key)
            self.audioURL = tempURL?.absoluteString
            return
        }
        let request = AudioRequest(prompt: prompt, audioVoice: audioVoice, langCode: langCode)
        APIService.shared.generateAudioGen(request: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("generateAudioForScene: generateAudioGen error: \(error)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
                print("generateAudioForScene: generateAudioGen response: \(response)")
                guard response.success, !response.jobId.isEmpty else {
                    self.errorMessage = response.message
                    return
                }
                self.pollAudioProgressEvery5Sec(jobId: response.jobId, cacheKey: key, sceneNumber: sceneNumber)
            }
            .store(in: &cancellables)
    }

    // Poll getAudioProgress every 5 seconds until status is 'success' and audioUrl is present
    private func pollAudioProgressEvery5Sec(jobId: String, cacheKey: String, sceneNumber: Int? = nil) {
        let pollInterval: TimeInterval = 5.0
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] t in
            guard let self = self else {
                t.invalidate()
                return
            }
            print("pollAudioProgressEvery5Sec: Calling getAudioProgress for jobId: \(jobId)")
            APIService.shared.getAudioProgress(jobId: jobId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        print("pollAudioProgressEvery5Sec: getAudioProgress error: \(error)")
                        self.errorMessage = error.localizedDescription
                        t.invalidate()
                    }
                } receiveValue: { progress in
                    print("pollAudioProgressEvery5Sec: getAudioProgress response: \(progress)")
                    self.audioProgressStatus = progress.status
                    if progress.status == "success", let audioUrl = progress.audioUrl {
                        t.invalidate()
                        // Save audioUrl to LocalSceneData for the correct scene number
                        if let sceneNum = sceneNumber {
                            self.saveAudioUrlToLocalSceneData(audioUrl: audioUrl, sceneNumber: sceneNum)
                        }
                        if let audioURLString = self.audioDownloadURL(for: jobId) {
                            self.downloadAndCacheAudio(from: audioURLString, key: cacheKey)
                        }
                    }
                }
                .store(in: &self.cancellables)
        }
    }

    // Save audioUrl to LocalSceneData for the correct scene number
    private func saveAudioUrlToLocalSceneData(audioUrl: String, sceneNumber: Int) {
        var stories = LocalStoryManager.shared.loadStories()
        guard !stories.isEmpty else { return }
        // Assume last story is the current one being edited
        var story = stories.removeLast()
        if let idx = story.scenes.firstIndex(where: { $0.sceneNumber == sceneNumber }) {
            var scene = story.scenes[idx]
            scene = LocalSceneData(
                sceneNumber: scene.sceneNumber,
                imagePrompt: scene.imagePrompt,
                imageURL: scene.imageURL,
                videoPrompt: scene.videoPrompt,
                audioPrompt: scene.audioPrompt,
                audioJobId: scene.audioJobId,
                audioURL: audioUrl
            )
            story.scenes[idx] = scene
            stories.append(story)
            LocalStoryManager.shared.clearStories()
            for s in stories { LocalStoryManager.shared.saveStory(s) }
        }
    }

    // Download audio file from job and cache it
    private func downloadAndCacheAudioFromJob(jobId: String, key: String) {
        APIService.shared.getAudioProgress(jobId: jobId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { progress in
                if progress.status == "completed", let audioURLString = self.audioDownloadURL(for: jobId) {
                    self.downloadAndCacheAudio(from: audioURLString, key: key)
                } else {
                    self.errorMessage = "Audio not available."
                }
            }
            .store(in: &cancellables)
    }

    // Helper to get the download URL for the audio job
    private func audioDownloadURL(for jobId: String) -> String? {
        let endpoint = APIEndpoint(path: "/audio/download/\(jobId)", method: .GET)
        return endpoint.url
    }

    private func downloadAndCacheAudio(from urlString: String, key: String) {
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid audio URL"
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    Self.audioCache.setObject(data as NSData, forKey: key as NSString)
                    let tempURL = self.saveDataToTempFile(data: data, key: key)
                    self.audioURL = tempURL?.absoluteString
                } else if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = "Failed to download audio."
                }
            }
        }.resume()
    }

    private func saveDataToTempFile(data: Data, key: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("audio_\(key).mp3")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.errorMessage = "Failed to save audio file."
            return nil
        }
    }

    // Optional: Clear cache for a specific scene
    func clearCacheForScene(prompt: String, audioVoice: String, langCode: String) {
        let key = cacheKey(prompt: prompt, audioVoice: audioVoice, langCode: langCode)
        Self.audioCache.removeObject(forKey: key as NSString)
    }
}

// String SHA256 helper
extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
