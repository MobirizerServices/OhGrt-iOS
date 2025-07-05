import Foundation

// Placeholder: Define actual properties when schema is known

struct PointsResponse: Codable {}
struct PointsSummaryResponse: Codable {}

struct Points: Codable {
    let total: Int
    let history: [PointsTransaction]
}

struct PointsTransaction: Codable {
    let id: String
    let amount: Int
    let type: String // "credit" or "debit"
    let description: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, amount, type, description
        case createdAt = "created_at"
    }
}

struct PointsSummary: Codable {
    let total: Int
    let available: Int
    let used: Int
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case total, available, used
        case lastUpdated = "last_updated"
    }
}
