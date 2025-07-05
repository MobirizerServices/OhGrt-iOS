//
//  ContentView.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
} 
