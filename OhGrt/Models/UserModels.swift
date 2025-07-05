import Foundation

struct User: Codable {
    let id: String
    let email: String
    let name: String?
    let profileImage: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(id: String, email: String, name: String? = nil, profileImage: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImage = profileImage
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case profileImage = "profile_image"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserProfile: Codable {
    let user: User
    let points: Int
    let subscription: Subscription?
}

struct UserProfileUpdate: Codable {
    let name: String?
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case profileImage = "profile_image"
    }
}

struct ImageUploadResponse: Codable {
    let url: String
    let message: String
}
