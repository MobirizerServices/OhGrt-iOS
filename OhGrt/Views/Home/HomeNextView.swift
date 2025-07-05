//
//  HomeNextView.swift
//  OhGrt
//
//  Created by Narendra on 07/05/25.
//

import SwiftUI

struct HomeNextView: View {
    
    @Binding var presentSideMenu: Bool
//    @StateObject private var viewModel = HomeViewModel()
    
    let languages = ["English", "Japanese", "Hindi", "Spanish", "French"]
    let sceneCounts = (3...10).map { String($0) } // Scene counts from 3 to 10
    let voices = ["female_1", "male_1", "female_2", "male_2"]
    let orientations = ["Landscape", "Portrait", "Square", "4:3"]
    
    var body: some View {
        
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
                    }
                    Spacer()
                    Text("OhGrt")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    // To keep the title centered, add an invisible button of same size
                    Color.clear
                        .frame(width: 32, height: 32)
                }
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
            
            ScrollView {
                
                Image("logo_transparent")
                    .resizable().scaledToFit()
                    .frame(width: 200, height: 150, alignment: .top)
                
                VStack(spacing: 15) {
                    // Prompt Editor
                    ZStack(alignment: .topLeading) {
//                        TextEditor(text: $viewModel.prompt)
//                            .frame(height: 150)
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 15)
//                                    .fill(Color.white)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 15)
//                                            .stroke(Color.blue.opacity(0.8), lineWidth: 1)
//                                    )
//                            )
//                            .padding(.horizontal)
//                        
//                        if viewModel.prompt.isEmpty {
//                            Text("Enter Prompt")
//                                .foregroundColor(.gray)
//                                .padding(.leading, 40)
//                                .padding(.top, 18)
//                        }
                    }
                    
                    // Scene Count Picker
//                    customPicker(label: "Scene Count", selection: $viewModel.selectedSceneCount, options: sceneCounts)
//                    
//                    // Language Picker
//                    customPicker(label: "Story Language", selection: $viewModel.selectedLanguage, options: languages)
//                    
//                    // Orientation Picker
//                    customPicker(label: "Video Mode", selection: $viewModel.selectedOrientation, options: orientations)
                    
                    // Voice Selection Horizontal Scrollable Grid
                    VStack(alignment: .leading) {
                        Text("Select Voice")
                            .font(.body)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(voices, id: \.self) { voice in
                                    Button(action: {
                                        // Toggle selection: if already selected, deselect; otherwise, select
//                                        if viewModel.selectedVoice == voice {
//                                            viewModel.selectedVoice = ""
//                                        } else {
//                                            viewModel.selectedVoice = voice
//                                        }
                                    }) {
                                        ZStack {
                                            Image(voice)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                            
//                                            if viewModel.selectedVoice == voice {
//                                                Image("voice_check")
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width: 24, height: 24)
//                                                    .offset(x: 30, y: -30) // Position checkmark in top-right corner
//                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Create Story Button
                    Button(action: {
//                        let story = viewModel.createStory()
//                        print("Created Story: \(story)")
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
        .background(Color.clear)
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Custom Picker View
    func customPicker(label: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.body)
            
            HStack {
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

struct HomeNextView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNextView(presentSideMenu: .constant(false))
    }
}
