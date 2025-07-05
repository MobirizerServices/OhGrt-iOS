//
//  OhGrtApp.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

@main
struct OhGrtApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Firebase is configured in AppDelegate
        setupGoogleSignIn()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
    
    func setupGoogleSignIn() {
        // Load from GoogleService-Info.plist
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("Error: GoogleService-Info.plist not found in bundle")
            return
        }
        
        guard let dict = NSDictionary(contentsOfFile: path) else {
            print("Error: Could not load GoogleService-Info.plist as dictionary")
            return
        }
        
        guard let clientID = dict["CLIENT_ID"] as? String else {
            print("Error: CLIENT_ID not found in GoogleService-Info.plist")
            return
        }
        
        print("Found Google clientID: \(clientID)")
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        print("Google Sign-In configured successfully")
    }
}
