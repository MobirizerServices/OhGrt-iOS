//
//  VideoStatus.swift
//  OhGrt
//
//  Created by Narendra on 01/07/25.
//

import SwiftUI
import Combine

struct VideoStatus: View {
    @State private var progress: CGFloat = 0.0
    private let steps = ["Processing video idea", "Applying template", "Adding voiceover", "Final rendering"]
    @State private var timer: Timer? = nil
    @State private var cancellable: AnyCancellable? = nil
    @State private var navigateToComplete = false
    @State private var videoURL: URL? = nil

    private func getJobId() -> String? {
        let stories = LocalStoryManager.shared.loadStories()
        return stories.last?.videoData?.jobId
    }
    
    private func getDownloadUrl() -> String? {
        let stories = LocalStoryManager.shared.loadStories()
        return stories.last?.videoData?.downloadUrl
    }
    
    private func pollVideoProgress() {
        guard let jobId = getJobId() else { return }
        cancellable = APIService.shared.getVideoJobProgress(jobId: jobId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Video progress error: \(error)")
                }
            }, receiveValue: { videoProgress in
                print("Polled progress: \(videoProgress.progress)")
                self.progress = CGFloat(videoProgress.progress)
                if videoProgress.progress >= 100 {
                    stopPolling()
                    // Wait 3 seconds, then navigate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        if let urlString = getDownloadUrl(), let url = URL(string: urlString) {
                            self.videoURL = url
                            self.navigateToComplete = true
                        }
                    }
                }
            })
    }
    
    private func startPolling() {
        stopPolling()
        pollVideoProgress() // Immediate first call
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if self.progress < 100 {
                pollVideoProgress()
            } else {
                stopPolling()
            }
        }
    }
    
    private func stopPolling() {
        timer?.invalidate()
        timer = nil
        cancellable?.cancel()
        cancellable = nil
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with gradient background
                ZStack(alignment: .topLeading) {
                    Image("statusHeader")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()

                    VStack {
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding()
                            }

                            Spacer()

                            Text("Generating")
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                            Image(systemName: "clock")
                                .foregroundColor(.white)
                                .padding()
                        }

                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 10)
                                    .frame(width: 120, height: 120)

                                Circle()
                                    .trim(from: 0, to: progress / 100)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 120, height: 120)
                                    .animation(.easeInOut(duration: 1.0), value: progress)

                                Text("\(Int(progress))%")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                            }

                            
                            Text("Generating Your Video")
                                .foregroundColor(.white)
                                .font(.headline)

                            Text("Estimated time: \(max(0, Int((100 - progress) * 0.4))) seconds remaining")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)

                            Text("Your video is in progress, please wait…")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.footnote)
                        }
                        .padding(.bottom, 30)
                    }
                }

                // Steps Section
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        HStack {
                            Image(progress >= CGFloat((index + 1) * 25) ? "sCheck" : "pUnselected")
                            Text(steps[index])
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 30)

                Spacer()

                // Cancel Button
                Button(action: {
                    progress = 0
                }) {
                    HStack {
                        Image("btnstar")
                        Text("Cancel Generation")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Image("btnBG").resizable().scaledToFill())
                    .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                Text("By accessing or using our app, you agree to be bound by these Terms & Conditions.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 8)

                Text("Sponsored & Promote by ERAM LABS\ncopyright © Mobirizer 2025")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            NavigationLink(
                destination: {
                    if let url = videoURL {
                        AnyView(VideoComplete(videoURL: url))
                    } else {
                        AnyView(EmptyView())
                    }
                }(),
                isActive: $navigateToComplete
            ) {
                EmptyView()
            }
        }
        .onAppear {
            if progress < 100 {
                startPolling()
            }
        }
        .onDisappear {
            stopPolling()
        }
    }
}

struct VideoStatus_Previews: PreviewProvider {
    static var previews: some View {
        VideoStatus()
            .previewDevice("iPhone 14 Pro")
    }
}
