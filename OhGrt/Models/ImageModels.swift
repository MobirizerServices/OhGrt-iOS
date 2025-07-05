import Foundation

struct ImageSize: Codable {
    var height: Int = 2160
    var width: Int = 3840
}
/*
                    "16:9" -> 1920 to 1080
                     "9:16" -> 1080 to 1920
                     "1:1" -> 1080 to 1080
                     else -> 1080 to 1920
 */

struct ImageGenerationRequest: Codable {
    var prompt: String
    var negativePrompt: String = ""
    var imageSize: ImageSize = ImageSize()
    var numInferenceSteps: Int = 18
    var guidanceScale: Float = 5.0
    var numImages: Int = 1
    var enableSafetyChecker: Bool = true
    var outputFormat: String = "jpeg"
    var styleName: String = "(No style)"

    enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt = "negative_prompt"
        case imageSize = "image_size"
        case numInferenceSteps = "num_inference_steps"
        case guidanceScale = "guidance_scale"
        case numImages = "num_images"
        case enableSafetyChecker = "enable_safety_checker"
        case outputFormat = "output_format"
        case styleName = "style_name"
    }
}

struct ImageData: Codable {
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
    }
}

struct ImageGenerationResponse: Codable {
    var success: Bool
    var message: String
    var data: ImageData?
}
struct GeneratedImage: Codable {
    let url: String
    let width: Int
    let height: Int
    let format: String
}
