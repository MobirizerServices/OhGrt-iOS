import Foundation

struct FirebaseLoginRequest: Codable {
    let idToken: String
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

//-------------- Login -----------------//
struct FirebaseLoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginUserData?
}

struct LoginUserData: Codable {
    let uid: String
    let email: String
    let name: String
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}
//------------------------------------//

struct TokenRefreshResponse: Codable {
    let token: String
    let refreshToken: String
}

struct UserNotificationRequest: Codable {
    let uid: String?
    let topic: String?
    let title: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case uid, topic, title, body
    }
}

struct EmptyResponse: Codable {}
