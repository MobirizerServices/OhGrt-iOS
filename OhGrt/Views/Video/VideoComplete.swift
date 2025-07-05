//
//  VideoComplete.swift
//  OhGrt
//
//  Created by Narendra on 01/07/25.
//

import SwiftUI
import AVKit

struct VideoComplete: View {
    let videoURL: URL

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Image
                Image("successVideoHeader")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)

                // Checkmark & Message
                VStack(spacing: 8) {
                    
                    Text("Generation Complete")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.green)

                    Text("Video Generated Successfully!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text("All scenes have been processed. Review them below to ensure everything looks perfect.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Video Player
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 200)
                    .cornerRadius(16)
                    .padding(.horizontal)

                // Download Button
                Button(action: {
                    // Download action
                }) {
                    HStack {
                        Image("downloadBtn")
                        Text("Download Video")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Image("btn").resizable().scaledToFill())
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Social Icons
                HStack(spacing: 30) {
                    Image("fb")
                    Image("whatsapp")
                    Image("apple")
                    Image("gmail")
                }
                .frame(height: 40)

                // Footer Note
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "shield")
                        Text("Your video will be available for 30 days")
                            .font(.footnote)
                    }

                    Text("Sponsored & Promote by ")
                        .font(.caption) +
                    Text("ERAM LABS")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
        }
    }
}


struct VideoComplete_Previews: PreviewProvider {
    static var previews: some View {
        VideoComplete(videoURL: URL(string: "https://example.com/video.wav")!)
            .previewDevice("iPhone 14 Pro")
    }
}
