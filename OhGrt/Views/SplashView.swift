//
//  SplashView.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Image("Splash")
                .resizable()
                .scaledToFill()
            VStack {
                Image("splash_icon")
                    .resizable()
                    .scaledToFit()
                
                Text("OhGrt")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Let's Create Something Amazing")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                                
                HStack {
                    Text("Sponsored & Promote by")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white)
                    Text("ERAM LABS")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
