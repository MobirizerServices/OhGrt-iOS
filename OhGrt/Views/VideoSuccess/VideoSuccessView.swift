//
//  VideoSuccessView.swift
//  OhGrt
//
//  Created by Narendra on 07/05/25.
//

import SwiftUI
import AVKit

struct VideoSuccessView: View {
//    @StateObject private var viewModel = VideoViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("successVideoHeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Generation Complete")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding(.top, 10)

                Text("Video Generated Successfully!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Please verify your scenes before proceeding to download")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("All scenes have been processed. Review them below to ensure everything looks perfect.")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                videoSection

                downloadButton

                socialButtons

                Text("Your video will be available for 30 days")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top)

                Text("Sponsored & Promote by ERAM LABS")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }

    private var videoSection: some View {
        ZStack {
//            if let url = viewModel.videoData.videoURL {
//                VideoPlayer(player: AVPlayer(url: url))
//                    .frame(height: 220)
//                    .cornerRadius(16)
//            } else {
//                Image("tempSuccessVideo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 220)
//                    .cornerRadius(16)
//            }

            Image(systemName: "play.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.white)
        }
    }

    private var downloadButton: some View {
        Button(action: {
//            viewModel.downloadVideo()
        }) {
            HStack {
                Image("downloadBtn")
                Text("Download Video")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [Color.purple, Color.green], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(16)
        }
    }

    private var socialButtons: some View {
        HStack(spacing: 24) {
            ForEach(["fb", "gmail", "apple", "whatsapp"], id: \.self) { name in
                Button(action: {
//                    viewModel.shareTo(platform: name)
                }) {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
        }
        .padding(.top, 10)
    }
}


struct VideoSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        VideoSuccessView()
    }
}
