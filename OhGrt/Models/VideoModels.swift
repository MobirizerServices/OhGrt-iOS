import Foundation

struct VideoRequest: Codable {
    let title: String
    let scenes: [SceneModelInput]
    let width: Int?
    let height: Int?

    struct SceneModelInput: Codable {
        let sceneNumber: Int
        let imagePrompt: String
        let imageUrl: String
        let audioUrl: String
        let textToDisplay: String
        let animation: AnimationSettings

        enum CodingKeys: String, CodingKey {
            case sceneNumber = "scene_number"
            case imagePrompt = "image_prompt"
            case imageUrl = "image_url"
            case audioUrl = "audio_url"
            case textToDisplay = "text_to_display"
            case animation
        }
    }

    struct AnimationSettings: Codable {
        let type: String
        let startScale: Double?
        let endScale: Double?

        enum CodingKeys: String, CodingKey {
            case type
            case startScale = "start_scale"
            case endScale = "end_scale"
        }
    }
}

struct JobResponse: Codable {
    let jobId: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case message
    }
}

struct VideoRenderRequest: Codable {
    let storyId: String
    let voiceId: String
    let style: String?
    let music: String?
    
    enum CodingKeys: String, CodingKey {
        case storyId = "story_id"
        case voiceId = "voice_id"
        case style, music
    }
}

struct VideoRenderResponse: Codable {
    let jobId: String
    let status: String
    let estimatedTime: Int? // in seconds
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case estimatedTime = "estimated_time"
    }
}

struct VideoJobRequest: Codable {
    let storyId: String
    let voiceId: String
    let style: String?
    let music: String?
    let resolution: String?
    
    enum CodingKeys: String, CodingKey {
        case storyId = "story_id"
        case voiceId = "voice_id"
        case style, music, resolution
    }
}

struct VideoJobResponse: Codable {
    let jobId: String
    let status: String
    let estimatedTime: Int? // in seconds
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case estimatedTime = "estimated_time"
    }
}

struct FullProcessRequest: Codable {
    let storyPrompt: String
    let voiceId: String
    let style: String?
    let music: String?
    let resolution: String?
    
    enum CodingKeys: String, CodingKey {
        case storyPrompt = "story_prompt"
        case voiceId = "voice_id"
        case style, music, resolution
    }
}

struct ProcessingStatus: Codable {
    let status: String
    let stage: String
    let progress: Double
    let error: String?
}

struct VideoProgress: Codable {
    let progress: Double
    let status: String
    let currentStage: String
    let estimatedTimeRemaining: Int? // in seconds
    
    enum CodingKeys: String, CodingKey {
        case progress, status
        case currentStage = "current_stage"
        case estimatedTimeRemaining = "estimated_time_remaining"
    }
}

struct VideoProject: Codable, Identifiable {
    let id: String
    let title: String
    let downloadUrl: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case downloadUrl = "download_url"
        case createdAt = "created_at"
    }
}

struct VideoStatusResponse: Codable {
    let status: String
    let progress: Double
    let message: String?
    let error: String?
    
    enum Status: String, Codable {
        case processing = "processing"
        case generatingAudio = "generating_audio"
        case creatingTransitions = "creating_transitions"
        case finalizing = "finalizing"
        case completed = "completed"
        case failed = "failed"
    }
}
