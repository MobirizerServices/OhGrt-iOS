//
//  GoogleSignInService.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import Foundation
import Combine
import GoogleSignIn
import UIKit

class GoogleSignInService {
    static let shared = GoogleSignInService()
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func signIn() -> AnyPublisher<(GIDGoogleUser, String), Error> {
        return Future<(GIDGoogleUser, String), Error> { promise in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                promise(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])))
                return
            }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let signInResult = signInResult,
                      let idToken = signInResult.user.idToken?.tokenString else {
                    promise(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                    return
                }
                
                // Call Firebase login API
                self.apiService.firebaseLogin(credentials: idToken)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    } receiveValue: { response in
                        if response.success, let accessToken = response.data?.accessToken {
                            promise(.success((signInResult.user, accessToken)))
                        } else {
                            promise(.failure(NSError(domain: "FirebaseLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message ?? "Login failed"])))
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
}
