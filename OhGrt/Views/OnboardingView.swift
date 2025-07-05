//
//  OnboardingView.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("bg")
                    .resizable()
                    .scaledToFill()
                VStack {
                    Image("splash_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Text("Welcome to OhGrt")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TabView(selection: $currentPage) {
                        Image("OnboardingImage1").tag(0)
                        Image("OnboardingImage2").tag(1)
                        Image("OnboardingImage3").tag(2)
                        Image("OnboardingImage4").tag(3)
                    }
                    .tabViewStyle(.page)
                    .frame(height: 400)
                    
                    Button(action: {
                        viewModel.signInWithGoogle()
                    }) {
                        Text("Login with Google")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Image("btn")
                                    .resizable()
                                    .scaledToFill()
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
                DashboardView()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
