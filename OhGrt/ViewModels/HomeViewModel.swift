import Foundation
import Combine

class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel() // Singleton instance for global access
    
    @Published var voiceCatalog: VoiceCatalogResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedLanguage: String = "English"
    @Published var selectedVoice: String = ""
    @Published var prompt: String = ""
    @Published var videoLength: Double = 15
    @Published var sceneCount: String = "3"
    @Published var generatedStory: StoryGenerateStoryResponse?
    @Published var shouldNavigateToScenes: Bool = false
    @Published var storyTitle: String = ""
    // New properties for orientation and style
    @Published var selectedOrientation: String = "16:9"
    @Published var selectedStyle: String = "No Effect"
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchVoiceCatalog() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getVoiceCatalog()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed: \(error)")
                    self.isLoading = false
                case .finished:
                    break
                }
            }, receiveValue: { response in
                print("Got languages: \(response.languages.count)")
                self.voiceCatalog = response
                // Set default language and voice
                if let firstLanguage = response.languages.first {
                    self.selectedLanguage = firstLanguage.name
                    if let firstSpeaker = firstLanguage.speakers.first {
                        self.selectedVoice = firstSpeaker.name
                    }
                }
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func createStory() {
        isLoading = true
        errorMessage = nil
        
        // Get the language code for the selected language
        let languageCode = voiceCatalog?.languages.first(where: { $0.name == selectedLanguage })?.code ?? "en"
        
        // Create the story generation request
        let request = StoryGenerateStoryRequest(
            title: storyTitle,
            prompt: prompt,
            language: languageCode,
            sceneTiming: Int(videoLength),
            characters: []
        )
        
        APIService.shared.generateStory(request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed: \(error)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                case .finished:
                    break
                }
            }, receiveValue: { response in
                print("Got generate story: \(response.scenes.count)")
                // Save LocalStoryData immediately
                let localScenes = response.scenes.enumerated().map { (idx, scene) in
                    LocalSceneData(
                        sceneNumber: scene.sceneNumber,
                        imagePrompt: scene.imagePrompt,
                        imageURL: nil,
                        videoPrompt: nil,
                        audioPrompt: scene.textToAudio,
                        audioJobId: nil,
                        audioURL: nil
                    )
                }
                let localStory = LocalStoryData(
                    homeData: self.getLocalHomeData(),
                    scenes: localScenes
                )
                LocalStoryManager.shared.saveStory(localStory)
                DispatchQueue.global().async {
                    self.generatedStory = response
                    self.shouldNavigateToScenes = true
                    self.isLoading = false
                }
            })
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
    
    // Helper method to get language names for picker
    func getLanguageNames() -> [String] {
        return voiceCatalog?.languages.map { $0.name } ?? []
    }
    
    // Helper method to get speaker names for the selected language
    func getSpeakerNames() -> [String] {
        guard let language = voiceCatalog?.languages.first(where: { $0.name == selectedLanguage }) else {
            return []
        }
        return language.speakers.map { $0.name }
    }
    
    // Helper method to get speaker code for the selected voice
    func getSelectedSpeakerCode() -> String? {
        guard let language = voiceCatalog?.languages.first(where: { $0.name == selectedLanguage }),
              let speaker = language.speakers.first(where: { $0.name == selectedVoice }) else {
            return nil
        }
        return speaker.code
    }
    
    // Helper method to get sound URL for the selected voice
    func getSelectedVoiceSoundURL() -> URL? {
        guard let language = voiceCatalog?.languages.first(where: { $0.name == selectedLanguage }),
              let speaker = language.speakers.first(where: { $0.name == selectedVoice }) else {
            return nil
        }
        return URL(string: speaker.soundURL)
    }
    
    // Helper method to get scene count options
    func getSceneCountOptions() -> [String] {
        return (2...8).map { String($0) }
    }
    
    // Helper to get LocalHomeData for saving home screen info
    func getLocalHomeData() -> LocalHomeData {
        return LocalHomeData(
            title: storyTitle,
            selectedLanguage: selectedLanguage,
            selectedVoice: selectedVoice,
            selectedOrientation: selectedOrientation,
            selectedStyle: selectedStyle,
            sceneCount: Int(sceneCount) ?? 0
        )
    }
    
    func pollForAudioURL(jobId: String, sceneIndex: Int) {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            APIService.shared.getAudioProgress(jobId: jobId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    // handle error if needed
                } receiveValue: { progress in
//                    if let audioURL = progress.audioURL, !audioURL.isEmpty {
//                        // Update LocalSceneData for this scene
//                        localStoryData.scenes[sceneIndex].audioURL = audioURL
//                        LocalStoryManager.shared.saveStory(localStoryData)
//                        timer.invalidate()
//                    }
                    timer.invalidate()
                }
                .store(in: &self.cancellables)
        }
    }
}

// LocalStoryManager for saving/loading stories
class LocalStoryManager {
    static let shared = LocalStoryManager()
    private let key = "localStories"

    func saveStory(_ story: LocalStoryData) {
        var stories = loadStories()
        stories.append(story)
        if let data = try? JSONEncoder().encode(stories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadStories() -> [LocalStoryData] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let stories = try? JSONDecoder().decode([LocalStoryData].self, from: data) else {
            return []
        }
        return stories
    }

    func clearStories() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

