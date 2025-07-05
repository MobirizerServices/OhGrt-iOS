//
//  StatusView.swift
//  OhGrt
//
//  Created by Narendra on 05/05/25.
//

import SwiftUI

struct StatusView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = StatusViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Image("statusHeader")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                    .clipped()

                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("closeBtn")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 16)
                            .padding(.top, 70)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(spacing: 10) {
                    Text("Generating")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 50)

                    ZStack {
                        Circle()
                            .stroke(lineWidth: 7)
                            .opacity(0.3)
                            .foregroundColor(.white)

                        Circle()
                            .trim(from: 0.0, to: CGFloat(viewModel.percentage / 100))
                            .stroke(Color.white, lineWidth: 10)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: viewModel.percentage)

                        Text("\(Int(viewModel.percentage))%")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 140, height: 140)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    
                    Text("Generating Your Video")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Estimated time: \(viewModel.estimatedTime)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("Your video is in progress, please wait...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }

            VStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.steps) { step in
                    HStack {
                        if step.isCompleted {
                            Image("check")
                                .resizable()
                                .frame(width: 20, height: 20)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 20, height: 20)
                        }

                        Text(step.title)
                            .font(.body)
                    }
                }
            }
            .padding()

            Spacer()

            VStack(spacing: 8) {
                Button(action: {
                    viewModel.cancelGeneration()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel Generation")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.blue, Color.green], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                // Terms & Conditions text with hyperlink
                Text("By accessing or using our app, you agree to be bound by")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                // Hyperlink for Terms & Conditions
                Button(action: {
                    if let url = URL(string: "https://your-terms-url.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("these Terms & Conditions.")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .underline()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .edgesIgnoringSafeArea(.top)
    }
}


struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
            .previewDevice("iPhone 14 Pro")
    }
}
