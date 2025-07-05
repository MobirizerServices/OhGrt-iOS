import Foundation

extension UserDefaults {
    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let user = "user"
    }
    
    var accessToken: String? {
        get { string(forKey: Keys.accessToken) }
        set { set(newValue, forKey: Keys.accessToken) }
    }
    
    var refreshToken: String? {
        get { string(forKey: Keys.refreshToken) }
        set { set(newValue, forKey: Keys.refreshToken) }
    }
    
    var user: User? {
        get {
            guard let data = data(forKey: Keys.user) else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                set(encoded, forKey: Keys.user)
            }
        }
    }
    
    func clearUserData() {
        removeObject(forKey: Keys.accessToken)
        removeObject(forKey: Keys.refreshToken)
        removeObject(forKey: Keys.user)
    }
} 