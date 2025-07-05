//
//  VideoView.swift
//  OhGrt
//
//  Created by Narendra on 30/04/25.
//

import SwiftUI
import Combine
import AVKit

struct VideoView: View  {
    @Binding var presentSideMenu: Bool
    @StateObject private var viewModel = VideoViewModel()
    @State private var cancellable: AnyCancellable? = nil
    @State private var projects: [VideoProject] = []
    
    var body: some View {
        VStack {
            // Header
            ZStack {
                Image("videoHeaderBG")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 120)
                    .clipped()
                    .ignoresSafeArea()
                
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
                    
                    Text("My Videos")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                        .frame(width: 12)
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, -50)
            }
            .frame(width: UIScreen.main.bounds.width)
            
            // Video List
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(projects) { project in
                        VideoProjectCard(project: project)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 1)
            }
            .padding(.top, -60) // Push ScrollView up
            .refreshable {
                fetchProjects()
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            fetchProjects()
        }
    }
    
    private func fetchProjects() {
        cancellable = APIService.shared.getVideoProjects()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("getVideoProjects error: \(error)")
                }
            }, receiveValue: { projects in
                print("getVideoProjects success: \(projects)")
                self.projects = projects
            })
    }
}

struct VideoProjectCard: View {
    let project: VideoProject
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = URL(string: project.downloadUrl ?? "") {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .cornerRadius(10)
            } else {
                Color.gray.frame(height: 200).cornerRadius(10)
            }
            Text(project.title)
                .font(.headline)
                .bold()
                .padding(.top, 4)
            HStack(alignment: .center) {
                Text(formatDateTime(project.createdAt))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    // Download action
                    if let url = URL(string: project.downloadUrl ?? "") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image("downloadBtn")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Download")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.bottom, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    // Helper to format date/time
    func formatDateTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}

// Video Row
struct VideoRow: View {
//    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}


struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(presentSideMenu: .constant(false))
    }
}
