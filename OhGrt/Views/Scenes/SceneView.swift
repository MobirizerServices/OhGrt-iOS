//
//  SceneView.swift
//  OhGrt
//
//  Created by Narendra on 02/05/25.
//

import SwiftUI
import AVFoundation
import Combine
import Foundation

struct SceneView: View {
    let story: StoryGenerateStoryResponse
    let orientation: String
    @State private var currentPage = 0
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var timer: Timer?
    @State private var showEditPopup = false
    @State private var editText = ""
    @State private var editType: EditType = .imagePrompt
    @StateObject private var imageViewModel = ImageViewModel()
    @StateObject private var audioViewModel = AudioViewModel()
    @State private var hasRequestedImage = false
    @State private var isGeneratingAudio = false
    @State private var lastPlayedAudioURL: String? = nil
    @State private var audioJobId: String? = nil
    @State private var audioProgressTimer: Timer? = nil
    @State private var cancellables = Set<AnyCancellable>()
    @State private var navigateToVideoStatus = false
    @State private var showMissingDataAlert = false
    @State private var missingDataMessage = ""
    
    enum EditType {
        case imagePrompt
        case audioText
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header with background image, back button, and title
                    ZStack(alignment: .topLeading) {
                        Image("header")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 130)
                            .clipped()
                        
                        Button(action: {
                            // Back button action (e.g., pop navigation)
                        }) {
                            Image("back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.leading, 100)
                                .padding(.top, 80)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(story.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 70)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.clear)
                    }
                    
                    // Pagination dots with 20px gap from header
                    HStack {
                        ForEach(0..<story.scenes.count, id: \.self) { index in
                            Image(index == currentPage ? "pSelected" : "pUnselected")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 20) // 20px gap from header
                    .padding(.bottom, 10)
                    
                    // Scrollable content with rounded corners
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            // Scene title
                            Text("Scene \(currentPage + 1)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // Image Prompt Text Box
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .center) {
                                    Image("texthead")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 30)
                                        .clipped()
                                        .cornerRadius(8, corners: [.topLeft, .topRight])
                                    Spacer()
                                    Button(action: {
                                        editType = .imagePrompt
                                        editText = story.scenes[currentPage].imagePrompt
                                        showEditPopup = true
                                    }) {
                                        Image("editIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(.trailing, 10)
                                            .padding(.top, 5)
                                    }
                                }
                                .background(Color.blue.opacity(0.8))
                                .frame(height: 30)
                                .overlay(
                                    Text("Image Prompt")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(.leading, 10)
                                        .padding(.top, 5)
                                    , alignment: .leading
                                )
                                VStack(alignment: .leading, spacing: 8) {
                                    if let urlString = imageViewModel.imageURL {
                                        if let cached = imageViewModel.getCachedImage(for: urlString) {
                                            Image(uiImage: cached)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity, maxHeight: 200)
                                                .padding(.vertical, 8)
                                        } else if let url = URL(string: urlString) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView().frame(height: 200)
                                                case .success(let image):
                                                    image.resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 200)
                                                case .failure:
                                                    Image(systemName: "photo").resizable().scaledToFit().frame(height: 200).foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }.padding(.vertical, 8)
                                        }
                                    }
                                    Text(story.scenes[currentPage].imagePrompt)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal)
                            }
                            
                            // Audio Text Box
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading) {
                                    ZStack(alignment: .leading) {
                                        Image("texthead")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 30)
                                            .clipped()
                                        
                                        Text("Audio Text")
                                            .foregroundColor(.white)
                                            .padding(.leading, 10)
                                            .padding(.top, 5)
                                    }
                                    
                                    Text(story.scenes[currentPage].textToAudio)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal)
                                .onTapGesture {
                                    editType = .audioText
                                    editText = story.scenes[currentPage].textToAudio
                                    showEditPopup = true
                                }
                                
                                HStack(spacing: 8) {
                                    if isGeneratingAudio {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .frame(width: 24, height: 24)
                                            .padding(.trailing, 5)
                                    }
                                    Button(action: {
                                        isGeneratingAudio = true
                                        let prompt = story.scenes[currentPage].textToAudio
                                        let audioVoice = HomeViewModel.shared.getSelectedSpeakerCode() ?? "af_sarah"
                                        let langCode = HomeViewModel.shared.voiceCatalog?.languages.first(where: { $0.name == HomeViewModel.shared.selectedLanguage })?.code ?? "en"
                                        let sceneNumber = story.scenes[currentPage].sceneNumber
                                        audioViewModel.generateAudioForScene(prompt: prompt, audioVoice: audioVoice, langCode: langCode, sceneNumber: sceneNumber)
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "waveform")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.white)
                                            Text("Generate Audio")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                    }
                                    .disabled(isGeneratingAudio)
                                    Image("editIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.trailing, 5)
                                        .padding(.top, 5)
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 5)
                            }
                            
                            // Audio Player Bar
                            HStack {
                                Button(action: {
                                    isPlaying.toggle()
                                    if isPlaying {
                                        startTimer()
                                    } else {
                                        stopTimer()
                                    }
                                }) {
                                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                }
                                
                                Slider(value: $currentTime, in: 0...30, step: 0.1) { _ in
                                    stopTimer()
                                    if isPlaying {
                                        startTimer()
                                    }
                                }
                                .accentColor(.blue)
                                
                                Text(String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60))
                                    .font(.caption)
                                
                                if let audioURL = audioViewModel.audioURL, !isGeneratingAudio {
                                    AudioPlayerBar(audioURL: audioURL, isPlaying: $isPlaying)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .onAppear {
                            if !hasRequestedImage {
                                hasRequestedImage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    generateImageForCurrentPage()
                                }
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal, 100)
                    
                    // Previous and Next Buttons
                    HStack(spacing: 16) {
                        if currentPage == story.scenes.count - 1 {
                            // On last scene
                            Button(action: {
                                // "Re-generate" acts as "go to previous scene"
                                if currentPage > 0 {
                                    currentPage -= 1
                                }
                                resetAudioPlayer()
                            }) {
                                Text("Re-generate")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button(action: {
                                // Generate Video action with missing data check
                                let stories = LocalStoryManager.shared.loadStories()
                                guard let localStory = stories.last else {
                                    missingDataMessage = "Local story data not found."
                                    showMissingDataAlert = true
                                    return
                                }
                                // Check all scenes for missing image/audio
                                var incompleteScenes: [Int] = []
                                var missingImageScenes: [Int] = []
                                var missingAudioScenes: [Int] = []
                                for (idx, scene) in localStory.scenes.enumerated() {
                                    if scene.imageURL == nil || scene.imageURL?.isEmpty == true {
                                        missingImageScenes.append(idx + 1)
                                    }
                                    if scene.audioURL == nil || scene.audioURL?.isEmpty == true {
                                        missingAudioScenes.append(idx + 1)
                                    }
                                }
                                if !missingImageScenes.isEmpty || !missingAudioScenes.isEmpty {
                                    var msg = "Please complete all scenes before generating the video.\n"
                                    if !missingImageScenes.isEmpty {
                                        msg += "Missing images for scene(s): \(missingImageScenes.map{String($0)}.joined(separator: ", "))\n"
                                    }
                                    if !missingAudioScenes.isEmpty {
                                        msg += "Missing audio for scene(s): \(missingAudioScenes.map{String($0)}.joined(separator: ", "))\nPress 'Generate Audio' for those scenes."
                                    }
                                    missingDataMessage = msg
                                    showMissingDataAlert = true
                                    return
                                }
                                // All scenes complete, proceed as before
                                resetAudioPlayer()
                                isGeneratingAudio = true // Use as loader for now
                                let animation = Animation(type: "zoom_in", startScale: 1.0, endScale: 1.2)
                                let captionSettings = CaptionSettings(
                                    enabled: true,
                                    position: "bottom",
                                    fontName: "DejaVuSans-Bold",
                                    fontSizeRatio: 0.035,
                                    color: "white",
                                    shadowColor: "black"
                                )
                                let scenesWithAnimation = localStory.scenes.map { scene in
                                    LocalSceneDataWithAnimation(
                                        sceneNumber: scene.sceneNumber,
                                        imagePrompt: scene.imagePrompt,
                                        imageURL: scene.imageURL,
                                        audioURL: scene.audioURL,
                                        audioPrompt: scene.audioPrompt,
                                        animation: animation
                                    )
                                }
                                let request = VideoJobFullProcessRequest(
                                    title: localStory.homeData.title,
                                    scenes: scenesWithAnimation,
                                    width: 1080,
                                    height: 1920,
                                    captionSettings: captionSettings,
                                    language: "en"
                                )
                                APIService.shared.generateFullProcess(request: request)
                                    .receive(on: DispatchQueue.main)
                                    .sink { completion in
                                        isGeneratingAudio = false
                                        if case let .failure(error) = completion {
                                            print("generateFullProcess error: \(error)")
                                        }
                                    } receiveValue: { response in
                                        print("generateFullProcess success: \(response)")
                                        if response.success, let downloadUrl = response.downloadUrl {
                                            var stories = LocalStoryManager.shared.loadStories()
                                            guard !stories.isEmpty else { return }
                                            var story = stories.removeLast()
                                            story.videoData = LocalVideoData(jobId: response.jobId, downloadUrl: downloadUrl)
                                            stories.append(story)
                                            LocalStoryManager.shared.clearStories()
                                            for s in stories { LocalStoryManager.shared.saveStory(s) }
                                            APIService.shared.getVideoJobStatus(jobId: response.jobId)
                                                .receive(on: DispatchQueue.main)
                                                .sink { statusCompletion in
                                                    if case let .failure(error) = statusCompletion {
                                                        print("getVideoJobStatus_new error: \(error)")
                                                    }
                                                } receiveValue: { status in
                                                    print("getVideoJobStatus_new success: \(status)")
                                                    navigateToVideoStatus = true
                                                }
                                                .store(in: &cancellables)
                                        }
                                    }
                                    .store(in: &cancellables)
                            }) {
                                Text("Generate Video")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        Image("btnBG")
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 100)
                            }
                        } else {
                            // Not on last scene
                            Button(action: {
                                if currentPage > 0 {
                                    currentPage -= 1
                                    generateImageForCurrentPage()
                                }
                                resetAudioPlayer()
                            }) {
                                Text("Previous")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.leading, 100)
                            }

                            Button(action: {
                                // Next button logic with missing data check
                                // Load latest LocalStoryData
                                let stories = LocalStoryManager.shared.loadStories()
                                guard let localStory = stories.last else {
                                    missingDataMessage = "Local story data not found."
                                    showMissingDataAlert = true
                                    return
                                }
                                let currentSceneNumber = story.scenes[currentPage].sceneNumber
                                guard let localScene = localStory.scenes.first(where: { $0.sceneNumber == currentSceneNumber }) else {
                                    missingDataMessage = "Current scene data not found."
                                    showMissingDataAlert = true
                                    return
                                }
                                var missing: [String] = []
                                if localScene.imageURL == nil || localScene.imageURL?.isEmpty == true {
                                    missing.append("image")
                                }
                                if localScene.audioURL == nil || localScene.audioURL?.isEmpty == true {
                                    missing.append("audio")
                                }
                                if !missing.isEmpty {
                                    if missing.count == 2 {
                                        missingDataMessage = "Please wait for the image to generate and press 'Generate Audio' to complete this scene."
                                    } else if missing[0] == "image" {
                                        missingDataMessage = "Please wait for the image to generate for this scene."
                                    } else {
                                        missingDataMessage = "Please press 'Generate Audio' to complete this scene."
                                    }
                                    showMissingDataAlert = true
                                    return
                                }
                                // If all data present, move to next scene
                                if currentPage < story.scenes.count - 1 {
                                    currentPage += 1
                                    generateImageForCurrentPage()
                                }
                                resetAudioPlayer()
                            }) {
                                Text("Next")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        Image("btnBG")
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 100)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                NavigationLink(destination: VideoStatus(), isActive: $navigateToVideoStatus) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
            .sheet(isPresented: $showEditPopup) {
                EditPopupView(
                    title: editType == .imagePrompt ? "Image Prompt" : "Audio Text",
                    text: $editText,
                    onSave: {
                        if editType == .imagePrompt {
                            // Update story.scenes[currentPage].imagePrompt
                        } else {
                            // Update story.scenes[currentPage].textToAudio
                        }
                        showEditPopup = false
                    },
                    onCancel: {
                        showEditPopup = false
                    }
                )
            }
            .alert(isPresented: $showMissingDataAlert) {
                Alert(
                    title: Text("Incomplete Scene"),
                    message: Text(missingDataMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onChange(of: audioViewModel.audioURL) { newURL in
            if let url = newURL, url != lastPlayedAudioURL {
                lastPlayedAudioURL = url
                isGeneratingAudio = false
                isPlaying = true
            }
        }
        .onReceive(audioViewModel.$audioProgressStatus) { status in
            if status == "success" {
                isGeneratingAudio = false
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if currentTime < 30 {
                currentTime += 0.1
            } else {
                stopTimer()
                isPlaying = false
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetAudioPlayer() {
        stopTimer()
        isPlaying = false
        currentTime = 0
        audioViewModel.audioURL = nil
    }
    
    // Helper to trigger image generation for current page
    private func generateImageForCurrentPage() {
        let prompt = story.scenes[currentPage].imagePrompt
        let imageSize: ImageSize
        switch orientation {
        case "16:9":
            imageSize = ImageSize(height: 1080, width: 1920)
        case "9:16":
            imageSize = ImageSize(height: 1920, width: 1080)
        case "1:1":
            imageSize = ImageSize(height: 1080, width: 1080)
        default:
            imageSize = ImageSize(height: 1920, width: 1080)
        }
        let sceneNumber = story.scenes[currentPage].sceneNumber
        imageViewModel.generateImage(
            prompt: prompt,
            size: imageSize,
            negativePrompt: "",
            numInferenceSteps: 28,
            guidanceScale: 8,
            numImages: 1,
            enableSafetyChecker: true,
            outputFormat: "jpeg",
            styleName: "(No style)",
            seed: 100,
            sceneNumber: sceneNumber
        )
        // --- New logic: Call getQueuePosition and then poll getAudioProgress ---
        // Assume jobId is available (replace with actual jobId logic as needed)
        let jobId = audioViewModel.jobId
        guard let jobId = jobId else { return }
        APIService.shared.getQueuePosition(jobId: jobId)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { _ in
                startAudioProgressPolling(jobId: jobId)
            }
            .store(in: &cancellables)
    }
    
    // Helper to start polling getAudioProgress every 5 seconds
    private func startAudioProgressPolling(jobId: String) {
        audioProgressTimer?.invalidate()
        audioProgressTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            APIService.shared.getAudioProgress(jobId: jobId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        print("Audio progress error: \(error.localizedDescription)")
                    }
                } receiveValue: { progress in
                    print("Audio progress: \(progress)")
                    // You can update state/UI here if needed
                }
                .store(in: &cancellables)
        }
    }
}

struct EditPopupView: View {
    let title: String
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent black background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .background(.ultraThinMaterial)
            
            // White container with all elements
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .padding(.top)
                
                TextEditor(text: $text)
                    .frame(height: 200)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    Button(action: onSave) {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Image("saveBtn")
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(0.8)
                            )
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.5))
                    .background(.ultraThinMaterial)
            )
            .cornerRadius(10)
            .padding(.horizontal, 40)
        }
    }
}

struct AudioPlayerBar: View {
    let audioURL: String
    @Binding var isPlaying: Bool
    @State private var player: AVPlayer? = nil
    @State private var isLoaded = false
    
    var body: some View {
        HStack {
            if isLoaded {
                Button(action: {
                    if isPlaying {
                        player?.pause()
                    } else {
                        player?.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if let url = URL(string: audioURL) {
                player = AVPlayer(url: url)
                isLoaded = true
                if isPlaying {
                    player?.play()
                }
            }
        }
        .onChange(of: isPlaying) { play in
            if play {
                player?.play()
            } else {
                player?.pause()
            }
        }
        .onChange(of: audioURL) { newURL in
            if let url = URL(string: newURL) {
                player = AVPlayer(url: url)
                if isPlaying {
                    player?.play()
                }
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView(story: StoryGenerateStoryResponse(
            title: "Sample Story",
            scenes: [
                SceneModel(sceneNumber: 0, imagePrompt: "A beautiful sunset", textToAudio: "The sun was setting over the horizon"),
                SceneModel(sceneNumber: 1, imagePrompt: "A mountain landscape", textToAudio: "The mountains stood tall in the distance")
            ]
        ), orientation: "16:9")
    }
}

