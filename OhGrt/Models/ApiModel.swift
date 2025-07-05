//
//  ApiModel.swift
//  OhGrt
//
//  Created by Narendra on 14/05/25.
//

//
//// /api/firebase/firebase-login
//struct FirebaseLoginRequest: Codable {
//    var idToken: String = ""
//    enum CodingKeys: String, CodingKey {
//        case idToken = "id_token"
//    }
//}
//
//// /api/firebase/token/refresh
//struct FirebaseTokenRefreshRequest: Codable {
//    var refreshToken: String = ""
//    enum CodingKeys: String, CodingKey {
//        case refreshToken = "refresh_token"
//    }
//}
//
//// /api/firebase/send-user-notification/
//struct FirebaseSendUserNotificationRequest: Codable {
//    var uid: String = ""
//    var topic: String = ""
//    var title: String = ""
//    var body: String = ""
//}
//
//// /api/users/profile/update
//struct UsersProfileUpdateRequest: Codable {
//    var name: String = ""
//    var email: String = ""
//    var dateOfBirth: String = ""
//    var occupation: String = ""
//    var language: String = ""
//    var profileImage: String = ""
//    enum CodingKeys: String, CodingKey {
//        case dateOfBirth = "date_of_birth"
//        case profileImage = "profile_image"
//    }
//}
//
//// /api/users/profile/upload-image
//struct UsersProfileUploadImageRequest: Codable {
//    var file: String = ""
//}
//
//// /api/subscription/create-subscription
//struct SubscriptionCreateSubscriptionRequest: Codable {
//    var planName: String = ""
//    var points: Int = 0
//    var price: Int = 0
//    var isActive: Bool = false
//    enum CodingKeys: String, CodingKey {
//        case planName = "plan_name"
//        case isActive = "is_active"
//    }
//}
//
//// /api/story/generate-story
//struct StoryGenerateStoryRequest: Codable {
//    var prompt: String = ""
//    var language: String = ""
//    var sceneCount: Int = 0
//    enum CodingKeys: String, CodingKey {
//        case sceneCount = "scene_count"
//    }
//}
//
//struct StoryGenerateStoryResponse: Codable {
//    var title: String = ""
//    var scenes: [Scene] = []
//    struct Scene: Codable {
//        var sceneNumber: Int = 0
//        var imagePrompt: String = ""
//        var textToAudio: String = ""
//        enum CodingKeys: String, CodingKey {
//            case sceneNumber = "scene_number"
//            case imagePrompt = "image_prompt"
//            case textToAudio = "text_to_audio"
//        }
//    }
//}
//
//// /api/image/generate-image
//struct ImageGenerateImageRequest: Codable {
//    var prompt: String = ""
//    var negativePrompt: String = ""
//    var imageSize: ImageSize = ImageSize()
//    var numInferenceSteps: Int = 0
//    var guidanceScale: Int = 0
//    var numImages: Int = 0
//    var enableSafetyChecker: Bool = false
//    var outputFormat: String = ""
//    var styleName: String = ""
//    enum CodingKeys: String, CodingKey {
//        case negativePrompt = "negative_prompt"
//        case imageSize = "image_size"
//        case numInferenceSteps = "num_inference_steps"
//        case guidanceScale = "guidance_scale"
//        case numImages = "num_images"
//        case enableSafetyChecker = "enable_safety_checker"
//        case outputFormat = "output_format"
//        case styleName = "style_name"
//    }
//    struct ImageSize: Codable {
//        var height: Int = 0
//        var width: Int = 0
//    }
//}
//
//struct ImageGenerateImageResponse: Codable {
//    var message: String = ""
//    var imageUrl: String = ""
//    enum CodingKeys: String, CodingKey {
//        case imageUrl = "image_url"
//    }
//}
//
//// /api/audio/generate-audio
//struct AudioGenerateAudioRequest: Codable {
//    var prompt: String = ""
//    var audioVoice: String = ""
//    var langCode: String = ""
//    enum CodingKeys: String, CodingKey {
//        case audioVoice = "audio_voice"
//        case langCode = "lang_code"
//    }
//}
//
//struct AudioGenerateAudioResponse: Codable {
//    var message: String = ""
//    var file: String = ""
//}
//
//// /api/video/render-final-video
//struct VideoRenderFinalVideoRequest: Codable {
//    var jobId: String = ""
//    enum CodingKeys: String, CodingKey {
//        case jobId = "job_id"
//    }
//}
//
//// /api/video/start-video-job
//struct VideoStartVideoJobRequest: Codable {
//    var title: String = ""
//    var scenes: [Scene] = []
//    var width: Int = 0
//    var height: Int = 0
//    struct Scene: Codable {
//        var sceneNumber: Int = 0
//        var imagePrompt: String = ""
//        var imageUrl: String = ""
//        var audioUrl: String = ""
//        var textToDisplay: String = ""
//        var animation: Animation = Animation()
//        enum CodingKeys: String, CodingKey {
//            case sceneNumber = "scene_number"
//            case imagePrompt = "image_prompt"
//            case imageUrl = "image_url"
//            case audioUrl = "audio_url"
//            case textToDisplay = "text_to_display"
//        }
//        struct Animation: Codable {
//            var type: String = ""
//            var startScale: Int = 0
//            var endScale: Double = 0
//            enum CodingKeys: String, CodingKey {
//                case startScale = "start_scale"
//                case endScale = "end_scale"
//            }
//        }
//    }
//}
//
//struct VideoStartVideoJobResponse: Codable {
//    var jobId: String = ""
//    var message: String = ""
//    enum CodingKeys: String, CodingKey {
//        case jobId = "job_id"
//    }
//}
//
//// /api/video-job/full-process
//struct VideoJobFullProcessRequest: Codable {
//    var title: String = ""
//    var scenes: [Scene] = []
//    var width: Int = 0
//    var height: Int = 0
//    struct Scene: Codable {
//        var sceneNumber: Int = 0
//        var imagePrompt: String = ""
//        var imageUrl: String = ""
//        var audioUrl: String = ""
//        var textToDisplay: String = ""
//        var animation: Animation = Animation()
//        enum CodingKeys: String, CodingKey {
//            case sceneNumber = "scene_number"
//            case imagePrompt = "image_prompt"
//            case imageUrl = "image_url"
//            case audioUrl = "audio_url"
//            case textToDisplay = "text_to_display"
//        }
//        struct Animation: Codable {
//            var type: String = ""
//            var startScale: Int = 0
//            var endScale: Double = 0
//            enum CodingKeys: String, CodingKey {
//                case startScale = "start_scale"
//                case endScale = "end_scale"
//            }
//        }
//    }
//}
//
//struct VideoJobFullProcessResponse: Codable {
//    var jobId: String = ""
//    var message: String = ""
//    enum CodingKeys: String, CodingKey {
//        case jobId = "job_id"
//    }
//}

// Local data models for saving home and scene information
struct LocalHomeData: Codable {
    let title: String
    let selectedLanguage: String
    let selectedVoice: String
    let selectedOrientation: String
    let selectedStyle: String
    let sceneCount: Int
}

struct LocalSceneData: Codable {
    let sceneNumber: Int
    let imagePrompt: String
    let imageURL: String?
    let videoPrompt: String?
    let audioPrompt: String
    let audioJobId: String?
    let audioURL: String?
}

struct LocalVideoData: Codable {
    let jobId: String
    let downloadUrl: String
}

struct LocalStoryData: Codable {
    let homeData: LocalHomeData
    var scenes: [LocalSceneData]
    var videoData: LocalVideoData?
}

// MARK: - Video Job Full Process API Models
struct VideoJobFullProcessRequest: Codable {
    let title: String
    let scenes: [LocalSceneDataWithAnimation]
    let width: Int
    let height: Int
    let captionSettings: CaptionSettings
    let language: String
}

struct LocalSceneDataWithAnimation: Codable {
    let sceneNumber: Int
    let imagePrompt: String
    let imageURL: String?
    let audioURL: String?
    let audioPrompt: String
    let animation: Animation
}

struct Animation: Codable {
    let type: String
    let startScale: Double
    let endScale: Double
}

struct CaptionSettings: Codable {
    let enabled: Bool
    let position: String
    let fontName: String
    let fontSizeRatio: Double
    let color: String
    let shadowColor: String
}

struct VideoStatusModel: Codable {
    let jobId: String
    let taskId: String
    let status: String
    let queuePosition: Int
    let downloadUrl: String?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case taskId = "task_id"
        case status
        case queuePosition = "queue_position"
        case downloadUrl = "download_url"
    }
}
