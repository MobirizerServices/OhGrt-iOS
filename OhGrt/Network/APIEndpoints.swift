//
//  APIEndpoints.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod

    var url: String {
//        return "http://43.248.241.252:8099" + path
        return "https://api.ohgrt.com" + path
    }

    static let firebaseLogin = APIEndpoint(path: "/firebase/firebase-login", method: .POST)
    static let refreshToken = APIEndpoint(path: "/firebase/token/refresh", method: .POST)
    static let sendUserNotification = APIEndpoint(path: "/firebase/send-user-notification/", method: .POST)
    static let updateFCMToken = APIEndpoint(path: "/firebase/update-fcm-token", method: .POST)
    
    // User APIs
    static let getUserProfile = APIEndpoint(path: "/users/profile", method: .GET)
    static let getUsers = APIEndpoint(path: "/users/users", method: .GET)
    static let updateUserProfile = APIEndpoint(path: "/users/profile/update", method: .PUT)
    static let uploadProfileImage = APIEndpoint(path: "/users/profile/upload-image", method: .POST)
    
    // Subscription APIs
    static let getSubscriptions = APIEndpoint(path: "/subscription/subscriptions", method: .GET)
    static let createSubscription = APIEndpoint(path: "/subscription/create-subscription", method: .POST)
    
    // Points APIs
    static let getPoints = APIEndpoint(path: "/points/points", method: .GET)
    static let getPointsSummary = APIEndpoint(path: "/points/points-summary", method: .GET)
    
    // Story APIs
    static let generateStory = APIEndpoint(path: "/story/generate-story", method: .POST)
    
    // Audio APIs
    static let voiceCatalog = APIEndpoint(path: "/audio-gen/voice-catalog", method: .GET)
    
    // Image APIs
    static let generateImage = APIEndpoint(path: "/image/generate-image", method: .POST)
    
    // Audio APIs
    static let generateAudio = APIEndpoint(path: "/audio-gen/generate-audio", method: .POST)
    static let getQueuePosition = APIEndpoint(path: "/audio-gen/queue-position/{job_id}", method: .GET)
    static let getAudioJobStatus = APIEndpoint(path: "/audio/job-status/{job_id}", method: .GET)
    static let getVoiceCatalog = APIEndpoint(path: "/audio/voice-catalog", method: .GET)
    static let getAudioProgress = APIEndpoint(path: "/audio-gen/audio-progress/{job_id}", method: .GET)
    
    // Video APIs
    static let renderFinalVideo = APIEndpoint(path: "/video/render-final-video", method: .POST)
    static let startVideoJob = APIEndpoint(path: "/video/start", method: .POST)
    static let downloadVideo = APIEndpoint(path: "/video/download/{job_id}", method: .GET)
    
    // Video Job APIs
    static let startFullProcess = APIEndpoint(path: "/video-job/full-process", method: .POST)
    static let getVideoJobStatus = APIEndpoint(path: "/video-job/status/{job_id}", method: .GET)
    static let getVideoJobProgress = APIEndpoint(path: "/video-job/progress/{job_id}", method: .GET)
    
    static let getVideoProcessingStatus = APIEndpoint(path: "/video-job/video_processing_status/{job_id}", method: .GET)
    static let getVideoProjects = APIEndpoint(path: "/video-job/video-projects", method: .GET)
}
