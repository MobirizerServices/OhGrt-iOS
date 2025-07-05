import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Firebase APIs
    func firebaseLogin(credentials: String) -> AnyPublisher<FirebaseLoginResponse, Error> {
        let body = ["id_token": credentials]
        return networkManager.request(.firebaseLogin, body: body)
    }
    
    func refreshToken(token: String) -> AnyPublisher<TokenRefreshResponse, Error> {
        let body = ["refresh_token": token]
        return networkManager.request(.refreshToken, body: body)
    }
    
    func sendUserNotification(uid: String, topic: String, title: String, body: String) -> AnyPublisher<EmptyResponse, Error> {
        let body = [
            "uid": uid,
            "topic": topic,
            "title": title,
            "body": body
        ]
        return networkManager.request(.sendUserNotification, body: body)
    }
    
    func updateFCMToken(token: String) -> AnyPublisher<EmptyResponse, Error> {
        let body = ["fcm_token": token]
        return networkManager.request(.updateFCMToken, body: body)
    }
    
    // MARK: - User APIs
    func getUserProfile() -> AnyPublisher<UserProfile, Error> {
        return networkManager.request(.getUserProfile)
    }
    
    func getUsers() -> AnyPublisher<[User], Error> {
        return networkManager.request(.getUsers)
    }
    
    func updateUserProfile(profile: UserProfileUpdate) -> AnyPublisher<UserProfile, Error> {
        var body: [String: Any] = [:]
        if let name = profile.name {
            body["name"] = name
        }
        if let profileImage = profile.profileImage {
            body["profile_image"] = profileImage
        }
        return networkManager.request(.updateUserProfile, body: body)
    }
    
    func uploadProfileImage(imageData: Data) -> AnyPublisher<ImageUploadResponse, Error> {
        // For image upload, we still need to use Data
        return networkManager.request(.uploadProfileImage, body: ["file": imageData])
    }
    
    // MARK: - Subscription APIs
    func getSubscriptions() -> AnyPublisher<[Subscription], Error> {
        return networkManager.request(.getSubscriptions)
    }
    
    func createSubscription(subscription: SubscriptionRequest) -> AnyPublisher<Subscription, Error> {
        let body = [
            "subscription_id": subscription.subscriptionId,
            "payment_method": subscription.paymentMethod
        ]
        return networkManager.request(.createSubscription, body: body)
    }
    
    // MARK: - Points APIs
    func getPoints() -> AnyPublisher<Points, Error> {
        return networkManager.request(.getPoints)
    }
    
    func getPointsSummary() -> AnyPublisher<PointsSummary, Error> {
        return networkManager.request(.getPointsSummary)
    }
    
    // MARK: - Story APIs
//    func generateStory(request: StoryGenerateStoryRequest) -> AnyPublisher<StoryGenerateStoryResponse, Error> {
//        let body = [
//            "prompt": request.prompt,
//            "language": request.language,
//            "scene_count": request.sceneCount
//        ] as [String : Any]
//        return networkManager.request(.generateStory, body: body)
//    }
  
    
    func generateStory(request: StoryGenerateStoryRequest) -> AnyPublisher<StoryGenerateStoryResponse, Error> {
        let endpoint = APIEndpoint(path: "/story/generate-story", method: .POST)

        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        // Use new body as requested
        let body: [String: Any] = [
            "title": request.title,
            "prompt": request.prompt,
            "language": request.language,
            "scene_timing": request.sceneTiming,
            "characters": request.characters
        ]

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("generateStory: Bearer token = \(token)")
            }
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("generateStory: Request body = \n\(jsonString)")
            }
        } catch {
            return Fail(error: NetworkError.encodingError(error)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("generateStory response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidResponse
                }

                // Manual parsing
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                print("GenerateStory response data: \(String(describing: json))")
                guard let success = json?["success"] as? Bool, success,
                      let data = json?["data"] as? [String: Any],
                      let story = data["story"] as? [String: Any],
                      let title = story["title"] as? String,
                      let scenesArray = story["scenes"] as? [[String: Any]] else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Missing or invalid fields in response")))
                }

                let scenes: [SceneModel] = scenesArray.compactMap { sceneDict in
                    guard let sceneNumber = sceneDict["scene_number"] as? Int,
                          let imagePrompt = sceneDict["image_prompt"] as? String,
                          let textToAudio = sceneDict["text_to_audio"] as? String else {
                        return nil
                    }

                    return SceneModel(
                        sceneNumber: sceneNumber,
                        imagePrompt: imagePrompt,
                        textToAudio: textToAudio
                    )
                }

                return StoryGenerateStoryResponse(title: title, scenes: scenes)
            }
            .eraseToAnyPublisher()
    }

    
    // MARK: - Image APIs
    func generateImage(request: ImageGenerationRequest) -> AnyPublisher<ImageGenerationResponse, Error> {
        let endpoint = APIEndpoint.generateImage
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        let body: [String: Any] = [
            "prompt": request.prompt,
            "negative_prompt": request.negativePrompt,
            "image_size": [
                "width": request.imageSize.width,
                "height": request.imageSize.height
            ],
            "num_inference_steps": request.numInferenceSteps,
            "guidance_scale": request.guidanceScale,
            "num_images": request.numImages,
            "enable_safety_checker": request.enableSafetyChecker,
            "output_format": request.outputFormat,
            "style_name": request.styleName,
            "seed": 100
        ]
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Fail(error: NetworkError.encodingError(error)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                let success = (json?["success"] as? Bool) ?? (json?["success"] as? Int == 1)
                let message = json?["message"] as? String ?? ""
                var imageUrl: String? = nil
                if let dataDict = json?["data"] as? [String: Any] {
                    imageUrl = dataDict["image_url"] as? String
                }
                let data = ImageData(imageUrl: imageUrl)
                return ImageGenerationResponse(success: success, message: message, data: data)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Audio APIs
    func generateAudio(request: AudioGenerationRequest) -> AnyPublisher<AudioGenerationResponse, Error> {
        var body: [String: Any] = [
            "text": request.text,
            "voice_id": request.voiceId
        ]
        if let speed = request.speed {
            body["speed"] = speed
        }
        if let pitch = request.pitch {
            body["pitch"] = pitch
        }
        return networkManager.request(.generateAudio, body: body)
    }
    
    func getQueuePosition(jobId: String) -> AnyPublisher<QueuePosition, Error> {
        print("Calling getQueuePosition for jobId: \(jobId)")
        let endpoint = APIEndpoint(path: "/audio-gen/queue-position/\(jobId)", method: .GET)
        guard let url = URL(string: endpoint.url) else {
            print("getQueuePosition: Invalid URL")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("getQueuePosition response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("getQueuePosition: Invalid response")
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                guard let success = json?["success"] as? Bool, success,
                      let data = json?["data"] as? [String: Any],
                      let position = data["position"] as? Int,
                      let estimatedWaitTime = data["estimated_wait_time"] as? Int else {
                    print("getQueuePosition: Decoding error")
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Missing or invalid fields in response")))
                }
                print("getQueuePosition: Parsed position=\(position), estimatedWaitTime=\(estimatedWaitTime)")
                return QueuePosition(position: position, estimatedWaitTime: estimatedWaitTime)
            }
            .eraseToAnyPublisher()
    }
    
    func getAudioJobStatus(jobId: String) -> AnyPublisher<JobStatus, Error> {
        let endpoint = APIEndpoint(path: "/audio/job-status/\(jobId)", method: .GET)
        return networkManager.request(endpoint)
    }
    
//    func getVoiceCatalog() -> AnyPublisher<VoiceCatalogResponse, Error> {
//        return networkManager.request(.voiceCatalog)
//            .tryMap { data -> VoiceCatalogResponse in
//                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
//                let decoder = JSONDecoder()
//                do {
//                    return try decoder.decode(VoiceCatalogResponse.self, from: data)
//                } catch {
//                    print("Decoding error: \(error)")
//                    if let decodingError = error as? DecodingError {
//                        switch decodingError {
//                        case .keyNotFound(let key, let context):
//                            print("Key '\(key)' not found: \(context.debugDescription)")
//                        case .typeMismatch(let type, let context):
//                            print("Type '\(type)' mismatch: \(context.debugDescription)")
//                        case .valueNotFound(let type, let context):
//                            print("Value of type '\(type)' not found: \(context.debugDescription)")
//                        case .dataCorrupted(let context):
//                            print("Data corrupted: \(context.debugDescription)")
//                        @unknown default:
//                            print("Unknown decoding error")
//                        }
//                    }
//                    throw error
//                }
//            }
//            .eraseToAnyPublisher()
//    }
    
//    func getVoiceCatalog() -> AnyPublisher<VoiceCatalogResponse, Error> {
//        let endpoint = APIEndpoint(path: "/audio-gen/voice-catalog", method: .GET)
//        return networkManager.request(endpoint)
//    }
    
    func getVoiceCatalog() -> AnyPublisher<VoiceCatalogResponse, Error> {
        let endpoint = APIEndpoint(path: "/audio-gen/voice-catalog", method: .GET)
        
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                switch response.statusCode {
                case 200...299:
                    return result.data
                default:
                    throw NetworkError.unexpectedStatusCode(response.statusCode)
                }
            }
            .tryMap { data in
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let languageArray = json["languages"] as? [[String: Any]] else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid structure")))
                }

                let languages: [Language] = languageArray.compactMap { langDict in
                    guard let code = langDict["code"] as? String,
                          let name = langDict["name"] as? String,
                          let speakersArray = langDict["speakers"] as? [[String: Any]] else {
                        return nil
                    }

                    let speakers: [Speaker] = speakersArray.compactMap { speakerDict in
                        guard let code = speakerDict["code"] as? String,
                              let name = speakerDict["name"] as? String,
                              let gender = speakerDict["gender"] as? String,
                              let soundURL = speakerDict["sound_url"] as? String else {
                            return nil
                        }
                        return Speaker(code: code, name: name, gender: gender, soundURL: soundURL)
                    }

                    return Language(code: code, name: name, speakers: speakers)
                }

                return VoiceCatalogResponse(languages: languages)
            }
            .eraseToAnyPublisher()
    }


    
    func getAudioProgress(jobId: String) -> AnyPublisher<AudioProgress, Error> {
        print("Calling getAudioProgress for jobId: \(jobId)")
        let endpoint = APIEndpoint(path: "/audio-gen/audio-progress/\(jobId)", method: .GET)
        guard let url = URL(string: endpoint.url) else {
            print("getAudioProgress: Invalid URL")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("getAudioProgress response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("getAudioProgress: Invalid response")
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                guard let success = json?["success"] as? Bool, success,
                      let data = json?["data"] as? [String: Any] else {
                    print("getAudioProgress: Decoding error")
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Missing or invalid fields in response")))
                }
                let jobId = data["job_id"] as? String ?? ""
                let progressPct = data["progress_pct"] as? Int ?? 0
                let audioUrl = data["audio_url"] as? String
                let status = data["status"] as? String ?? ""
                print("getAudioProgress: Parsed jobId=\(jobId), progressPct=\(progressPct), audioUrl=\(String(describing: audioUrl)), status=\(status)")
                return AudioProgress(jobId: jobId, progressPct: progressPct, audioUrl: audioUrl, status: status)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Video APIs
    func renderFinalVideo(request: VideoRenderRequest) -> AnyPublisher<VideoRenderResponse, Error> {
        var body: [String: Any] = [
            "story_id": request.storyId,
            "voice_id": request.voiceId
        ]
        if let style = request.style {
            body["style"] = style
        }
        if let music = request.music {
            body["music"] = music
        }
        return networkManager.request(.renderFinalVideo, body: body)
    }
    
    func startVideoJob(request: VideoJobRequest) -> AnyPublisher<VideoJobResponse, Error> {
        var body: [String: Any] = [
            "story_id": request.storyId,
            "voice_id": request.voiceId
        ]
        if let style = request.style {
            body["style"] = style
        }
        if let music = request.music {
            body["music"] = music
        }
        if let resolution = request.resolution {
            body["resolution"] = resolution
        }
        return networkManager.request(.startVideoJob, body: body)
    }
    
    func downloadVideo(jobId: String) -> AnyPublisher<Data, Error> {
        let endpoint = APIEndpoint(path: "/video/download/\(jobId)", method: .GET)
        return networkManager.request(endpoint)
    }
    
    func getVideoStatus(jobId: String) -> AnyPublisher<VideoStatusResponse, Error> {
        let endpoint = APIEndpoint(path: "/video/status/\(jobId)", method: .GET)
        return networkManager.request(endpoint)
    }
    
    func cancelVideoJob(jobId: String) -> AnyPublisher<EmptyResponse, Error> {
        let endpoint = APIEndpoint(path: "/video/cancel/\(jobId)", method: .POST)
        return networkManager.request(endpoint)
    }
    
    func getVideoProcessingStatus(jobId: String) -> AnyPublisher<ProcessingStatus, Error> {
        let endpoint = APIEndpoint(path: "/video-job/video_processing_status/\(jobId)", method: .GET)
        return networkManager.request(endpoint)
    }
    
    func getVideoJobProgress(jobId: String) -> AnyPublisher<VideoProgress, Error> {
        let endpoint = APIEndpoint(path: "/video-job/progress/\(jobId)", method: .GET)
        print("[getVideoJobProgress] Requesting progress for jobId: \(jobId)")
        print("[getVideoJobProgress] URL: \(endpoint.url)")
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("[getVideoJobProgress] Raw response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                let success = (json?["success"] as? Int == 1) || (json?["success"] as? Bool == true)
                guard success, let data = json?["data"] as? [String: Any] else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Missing or invalid fields in response")))
                }
                let progress = data["progress"] as? Double ?? 0.0
                let status = data["status"] as? String ?? ""
                let currentStage = data["current_stage"] as? String ?? ""
                let estimatedTimeRemaining = data["estimated_time_remaining"] as? Int
                print("[getVideoJobProgress] Parsed progress: \(progress), status: \(status), currentStage: \(currentStage), estimatedTimeRemaining: \(String(describing: estimatedTimeRemaining))")
                return VideoProgress(progress: progress, status: status, currentStage: currentStage, estimatedTimeRemaining: estimatedTimeRemaining)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - AudioGen APIs
    func generateAudioGen(request: AudioRequest) -> AnyPublisher<AudioGenJobResponse, Error> {
        print("Calling generateAudioGen with request: \(request)")
        let endpoint = APIEndpoint.generateAudio
        guard let url = URL(string: endpoint.url) else {
            print("generateAudioGen: Invalid URL")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var body: [String: Any] = [
            "prompt": request.prompt,
            "audio_voice": request.audioVoice,
            "lang_code": request.langCode,
            "speed": 1
        ]
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("generateAudioGen: Encoding error \(error)")
            return Fail(error: NetworkError.encodingError(error)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("generateAudioGen response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("generateAudioGen: Invalid response")
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                let message = json?["message"] as? String ?? ""
                let success = (json?["success"] as? Int == 1)
                var jobId = ""
                if let dataDict = json?["data"] as? [String: Any] {
                    jobId = dataDict["job_id"] as? String ?? ""
                }
                print("generateAudioGen: Parsed jobId=\(jobId), message=\(message), success=\(success)")
                return AudioGenJobResponse(jobId: jobId, message: message, success: success)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Video Job Full Process API
    func generateFullProcess(request: VideoJobFullProcessRequest) -> AnyPublisher<FullProcessResponse, Error> {
        let endpoint = APIEndpoint.startFullProcess
        guard let url = URL(string: endpoint.url) else {
            print("generateFullProcess: Invalid URL")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var body: [String: Any] = [
            "title": request.title,
            "scenes": request.scenes.map { scene in
                [
                    "scene_number": scene.sceneNumber,
                    "image_prompt": scene.imagePrompt,
                    "image_url": scene.imageURL ?? "",
                    "audio_url": scene.audioURL ?? "",
                    "text_to_display": scene.audioPrompt,
                    "animation": [
                        "type": scene.animation.type,
                        "start_scale": scene.animation.startScale,
                        "end_scale": scene.animation.endScale
                    ]
                ]
            },
            "width": request.width,
            "height": request.height,
            "caption_settings": [
                "enabled": request.captionSettings.enabled,
                "position": request.captionSettings.position,
                "font_name": request.captionSettings.fontName,
                "font_size_ratio": request.captionSettings.fontSizeRatio,
                "color": request.captionSettings.color,
                "shadow_color": request.captionSettings.shadowColor
            ],
            "language": request.language
        ]
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("generateFullProcess: Request body = \n\(jsonString)")
            }
        } catch {
            print("generateFullProcess: Encoding error \(error)")
            return Fail(error: NetworkError.encodingError(error)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("generateFullProcess response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("generateFullProcess: Invalid response")
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                let message = json?["message"] as? String ?? ""
                let success = (json?["success"] as? Int == 1) || (json?["success"] as? Bool == true)
                let data = json?["data"] as? [String: Any]
                let jobId = data?["job_id"] as? String ?? ""
                let downloadUrl = data?["download_url"] as? String
                return FullProcessResponse(jobId: jobId, message: message, success: success, downloadUrl: downloadUrl)
            }
            .eraseToAnyPublisher()
    }
    
    func getVideoJobStatus(jobId: String) -> AnyPublisher<JobStatus, Error> {
        let endpoint = APIEndpoint(path: "/video-job/status/\(jobId)", method: .GET)
        print("[getVideoJobStatus] Requesting status for jobId: \(jobId)")
        print("[getVideoJobStatus] URL: \(endpoint.url)")
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("[getVideoJobStatus] Raw response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                let success = (json?["success"] as? Int == 1) || (json?["success"] as? Bool == true)
                guard success else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "API did not return success")))
                }
                guard let data = json?["data"] as? [String: Any] else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Missing or invalid fields in response")))
                }
                // Save download_url if present
                if let downloadUrl = data["download_url"] as? String {
                    var stories = LocalStoryManager.shared.loadStories()
                    guard !stories.isEmpty else { return JobStatus(status: data["status"] as? String ?? "", progress: nil, error: nil) }
                    var story = stories.removeLast()
                    if var videoData = story.videoData {
                        videoData = LocalVideoData(jobId: videoData.jobId, downloadUrl: downloadUrl)
                        story.videoData = videoData
                    } else if let jobId = data["job_id"] as? String {
                        story.videoData = LocalVideoData(jobId: jobId, downloadUrl: downloadUrl)
                    }
                    stories.append(story)
                    LocalStoryManager.shared.clearStories()
                    for s in stories { LocalStoryManager.shared.saveStory(s) }
                }
                let status = data["status"] as? String ?? ""
                let progress = data["progress"] as? Double
                let error = data["error"] as? String
                print("[getVideoJobStatus] Parsed status: \(status), progress: \(String(describing: progress)), error: \(String(describing: error))")
                return JobStatus(status: status, progress: progress, error: error)
            }
            .eraseToAnyPublisher()
    }

    func getVideoProjects() -> AnyPublisher<[VideoProject], Error> {
        let endpoint = APIEndpoint.getVideoProjects
        print("[getVideoProjects] Requesting video projects at URL: \(endpoint.url)")
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                print("[getVideoProjects] Raw response: \(String(data: result.data, encoding: .utf8) ?? "<no data>")")
                guard let response = result.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                let json = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any]
                let message = json?["message"] as? String ?? ""
                let success = (json?["success"] as? Int == 1) || (json?["success"] as? Bool == true)
                guard success else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "API did not return success: \(message)")))
                }
                guard let dataArray = json?["data"] as? [[String: Any]] else {
                    throw NetworkError.decodingError(.dataCorrupted(.init(codingPath: [], debugDescription: "Missing or invalid 'data' array in response")))
                }
                let isoFormatter = ISO8601DateFormatter()
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
                // Custom formatter for fractional seconds
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                customFormatter.locale = Locale(identifier: "en_US_POSIX")
                customFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                let projects: [VideoProject] = dataArray.compactMap { dict in
                    let id = dict["id"] as? String ?? ""
                    let title = dict["title"] as? String ?? ""
                    let downloadUrl = dict["download_url"] as? String ?? ""
                    let createdAtRaw = dict["created_at"] as? String ?? ""
                    var createdAt = createdAtRaw
                    if let date = customFormatter.date(from: createdAtRaw) {
                        createdAt = displayFormatter.string(from: date)
                    }
                    return VideoProject(id: id, title: title, downloadUrl: downloadUrl, createdAt: createdAt)
                }
                print("[getVideoProjects] Parsed projects: \(projects)")
                return projects
            }
            .eraseToAnyPublisher()
    }
}

// Add this struct for the new response
struct AudioGenJobResponse: Codable {
    let jobId: String
    let message: String
    let success: Bool
}

struct FullProcessResponse: Codable {
    let jobId: String
    let message: String
    let success: Bool
    let downloadUrl: String?
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case message
        case success
        case downloadUrl = "download_url"
    }
}

