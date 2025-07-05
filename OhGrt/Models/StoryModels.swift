import Foundation

struct Story: Codable {
    let id: String
    let title: String
    let content: String
    let genre: String
    let length: Int // in words
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, genre, length
        case createdAt = "created_at"
    }
}

struct StoryGenerationRequest: Codable {
    let prompt: String
    let genre: String?
    let length: Int? // in words
    let style: String?
    let tone: String?
    
    enum CodingKeys: String, CodingKey {
        case prompt, genre, length, style, tone
    }
}

struct StoryGenerateStoryRequest: Codable {
    let title: String
    let prompt: String
    let language: String
    let sceneTiming: Int
    let characters: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case prompt
        case language
        case sceneTiming = "scene_timing"
        case characters
    }
}

struct SceneModel: Codable {
    let sceneNumber: Int
    let imagePrompt: String
    let textToAudio: String

    enum CodingKeys: String, CodingKey {
        case sceneNumber = "scene_number"
        case imagePrompt = "image_prompt"
        case textToAudio = "text_to_audio"
    }
}

struct StoryGenerateStoryResponse: Codable {
    let title: String
    let scenes: [SceneModel]
}
