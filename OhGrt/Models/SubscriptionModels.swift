import Foundation

struct Subscription: Codable {
    let id: String
    let name: String
    let subTitle: String
    let price: Double
    let duration: Int // in days
    let features: [String]
    let isActive: Bool
    let startDate: Date
    let endDate: Date
    let isPopular: Bool = false
    let subDescription: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, duration, features, subTitle, subDescription
        case isActive = "is_active"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct SubscriptionRequest: Codable {
    let subscriptionId: String
    let paymentMethod: String
    
    enum CodingKeys: String, CodingKey {
        case subscriptionId = "subscription_id"
        case paymentMethod = "payment_method"
    }
}
