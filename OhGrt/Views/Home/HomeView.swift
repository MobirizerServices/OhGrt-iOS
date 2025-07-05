//
//  OnboardingView.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI
import CoreAudio
import AVFoundation

struct HomeView: View {
    
    @Binding var presentSideMenu: Bool
    @StateObject private var viewModel = HomeViewModel.shared
    @State private var isVoiceCatalogCalled = false
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State var selectedOrientation = "16:9"
    let orientations = ["16:9", "9:16", "1:1", "4:3"]
    
    struct VisualStyleOption: Identifiable {
        let id = UUID()
        let imageName: String
        let title: String
    }
    let styles: [VisualStyleOption] = [
        VisualStyleOption(imageName: "no_style", title: "No Effect"),
        VisualStyleOption(imageName: "cinematic", title: "Cinematic"),
        VisualStyleOption(imageName: "photographic", title: "Photographic"),
        VisualStyleOption(imageName: "anime", title: "Anime"),
        VisualStyleOption(imageName: "digital_art", title: "Digital Art"),
        VisualStyleOption(imageName: "fantasy_art", title: "Fantasy Art")
    ]
    
    @State private var selectedStyle: String = "No Effect"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Header
                Image("HeaderBG")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Button {
                            presentSideMenu.toggle()
                        } label: {
                            Image("menu")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("OhGrt")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                            .frame(width: 32)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    Text("Turn Ideas Into Stories")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.leading, 20)
                    
                    Text("AI-powered story telling for everyone")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.leading, 20)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        Image("logo_transparent")
                            .resizable().scaledToFit()
                            .frame(width: 200, height: 150, alignment: .top)
                        
                        VStack(spacing: 15) {
                            // Prompt Editor
                            ZStack(alignment: .topLeading) {
                                                
                                TextEditor(text: $viewModel.prompt)
                                    .frame(height: 150)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                            )
                                    )
                                    .padding(.horizontal)
                                
                                if viewModel.prompt.isEmpty {
                                    Text("Please describe the video content you want to generate …")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 40)
                                        .padding(.top, 18)
                                }
                            }
                            
                            
                            TextField("Title", text: $viewModel.storyTitle)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width - 40)
                                .frame(height: 40)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.7)))
                            
                            // Video Length
                            VStack(alignment: .leading) {
                                Text("Video Length")
                                    .font(.body)
                                Slider(value: $viewModel.videoLength, in: 5...60, step: 5)
                                HStack {
                                    Text("5s")
                                    Spacer()
                                    Text("\(Int(viewModel.videoLength))s")
                                    Spacer()
                                    Text("60s")
                                }
                                .font(.caption)
                            }
                            .padding(.horizontal)
                            
                            // Language Picker
                            customPicker(label: "Story Language", selection: $viewModel.selectedLanguage, options: viewModel.getLanguageNames(), leftImage: "dropleft")
                                .onChange(of: viewModel.selectedLanguage) { newLanguage in
                                    // Reset voice selection when language changes
                                    if let firstSpeaker = viewModel.getSpeakerNames().first {
                                        viewModel.selectedVoice = firstSpeaker
                                        // Update audio player with new voice
                                        if let soundURL = viewModel.getSelectedVoiceSoundURL() {
                                            audioPlayer.setupPlayer(with: soundURL)
                                        }
                                    }
                                }
                            
                            // Voice Picker
                            customPicker(label: "Voice Selection", selection: $viewModel.selectedVoice, options: viewModel.getSpeakerNames(), leftImage: "audiodropleft")
                                .onChange(of: viewModel.selectedVoice) { newVoice in
                                    // Update audio player when voice changes
                                    if let soundURL = viewModel.getSelectedVoiceSoundURL() {
                                        audioPlayer.setupPlayer(with: soundURL)
                                    }
                                }
                            
                            // Audio Player
                            if let soundURL = viewModel.getSelectedVoiceSoundURL() {
                                AudioPlayerView(audioURL: soundURL)
                                    .padding(.horizontal)
                                    .id("\(viewModel.selectedLanguage)_\(viewModel.selectedVoice)") // Force view to recreate when either language or voice changes
                            }
                            
                            // Video Orientation
                            customPicker(label: "Video Orientation", selection: $selectedOrientation, options: orientations, leftImage: "videodropleft")
                                .onChange(of: selectedOrientation) { videoOri in
                                    //
                                }
                            
                            // Visual Style
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Visual Style")
                                    .font(.body)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(styles) { style in
                                            VStack(spacing: 5) {
                                                Image(style.imageName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(style.title == selectedStyle ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                                    )
                                                Text(style.title)
                                                    .font(.caption)
                                            }
                                            .padding(0)
                                            .onTapGesture {
                                                selectedStyle = style.title
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Create Story Button
                            Button(action: {
                                // Handle create story action
                                viewModel.createStory()
                            }) {
                                HStack {
                                    Image("btnstar")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                    Text("Create Story")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Image("btnBG")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                )
                                .cornerRadius(20)
                            }
                            .padding(.horizontal)
                            
                            // Footer
                            VStack(spacing: 4) {
                                Text("Sponsored & Promote by ")
                                    .font(.caption) +
                                Text("ERAM LABS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.teal)
                                Text("copyright © Mobirizer 2025")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .background(Color.clear)
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToScenes) {
                if let story = viewModel.generatedStory {
                    SceneView(story: story, orientation: selectedOrientation)
                }
            }
            .onAppear {
                // Delay voice catalog API
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if !isVoiceCatalogCalled {
                        viewModel.fetchVoiceCatalog()
                        isVoiceCatalogCalled = true
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Picker View
    func customPicker(label: String, selection: Binding<String>, options: [String], leftImage: String) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.body)
            
            HStack {
                Image(leftImage)
                    .resizable()
                    .frame(width: 15, height: 15)
                
                Picker(label, selection: selection) {
                    ForEach(options, id: \.self) {
                        Text($0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
                
                Image("dropright")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 40)
            .frame(height: 40)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.7)))
        }
        .padding(.horizontal)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(presentSideMenu: .constant(false))
    }
}











struct VisualStyleOption: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
}

struct VisualStyleView: View {
    let styles: [VisualStyleOption] = [
        VisualStyleOption(imageName: "no_style", title: "No Effect"),
        VisualStyleOption(imageName: "cinematic", title: "Cinematic"),
        VisualStyleOption(imageName: "photographic", title: "Photographic"),
        VisualStyleOption(imageName: "anime", title: "Anime"),
        VisualStyleOption(imageName: "digital_art", title: "Digital Art"),
        VisualStyleOption(imageName: "fantasy_art", title: "Fantasy Art")
    ]
    
    @State private var selectedStyle: String = "No Effect"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual Style")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(styles) { style in
                        VStack(spacing: 8) {
                            Image(style.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(style.title == selectedStyle ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                            Text(style.title)
                                .font(.caption)
                        }
                        .padding(8)
                        .onTapGesture {
                            selectedStyle = style.title
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct VisualStyleView_Previews: PreviewProvider {
    static var previews: some View {
        VisualStyleView()
    }
}
