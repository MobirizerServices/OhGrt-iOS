import Foundation

struct AudioRequest: Codable {
    let prompt: String
    let audioVoice: String
    let langCode: String

    enum CodingKeys: String, CodingKey {
        case prompt
        case audioVoice = "audio_voice"
        case langCode = "lang_code"
    }
}

struct AudioResponse: Codable {
    let message: String
    let file: String
}

struct AudioGenerationRequest: Codable {
    let text: String
    let voiceId: String
    let speed: Double?
    let pitch: Double?
    
    enum CodingKeys: String, CodingKey {
        case text
        case voiceId = "voice_id"
        case speed, pitch
    }
}

struct AudioGenerationResponse: Codable {
    let jobId: String
    let status: String
    let estimatedTime: Int? // in seconds
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case estimatedTime = "estimated_time"
    }
}

struct QueuePosition: Codable {
    let position: Int
    let estimatedWaitTime: Int // in seconds
    
    enum CodingKeys: String, CodingKey {
        case position
        case estimatedWaitTime = "estimated_wait_time"
    }
}

struct JobStatus: Codable {
    let status: String // "pending", "processing", "completed", "failed"
    let progress: Double?
    let error: String?
}

struct Voice: Codable {
    let id: String
    let name: String
    let gender: String
    let language: String
    let previewUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, gender, language
        case previewUrl = "preview_url"
    }
}

struct AudioProgress: Codable {
    let jobId: String
    let progressPct: Int
    let audioUrl: String?
    let status: String

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case progressPct = "progress_pct"
        case audioUrl = "audio_url"
        case status
    }
}

struct VoiceCatalogResponse: Codable {
    let languages: [Language]
}

struct Language: Codable {
    let code: String
    let name: String
    let speakers: [Speaker]
}

struct Speaker: Codable {
    let code: String
    let name: String
    let gender: String
    let soundURL: String

    enum CodingKeys: String, CodingKey {
        case code, name, gender
        case soundURL = "sound_url"
    }
}

