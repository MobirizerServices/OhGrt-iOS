import Foundation
import Combine

struct GenerationStep: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

class StatusViewModel: ObservableObject {
    @Published var percentage: Double = 0
    @Published var estimatedTime: String = "2-3 minutes"
    @Published var steps: [GenerationStep] = [
        GenerationStep(title: "Processing your images", isCompleted: false),
        GenerationStep(title: "Generating audio narration", isCompleted: false),
        GenerationStep(title: "Creating video transitions", isCompleted: false),
        GenerationStep(title: "Finalizing your video", isCompleted: false)
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var jobId: String?
    
    init() {
        setupProgressTracking()
    }
    
    private func setupProgressTracking() {
        // Simulate progress for demo purposes
        // In production, this should be replaced with actual API polling
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.percentage < 100 {
                self.percentage += 1
                
                // Update steps based on progress
                if self.percentage >= 25 {
                    self.steps[0].isCompleted = true
                }
                if self.percentage >= 50 {
                    self.steps[1].isCompleted = true
                }
                if self.percentage >= 75 {
                    self.steps[2].isCompleted = true
                }
                if self.percentage >= 95 {
                    self.steps[3].isCompleted = true
                }
                
                // Update estimated time
                if self.percentage > 50 {
                    self.estimatedTime = "1-2 minutes"
                }
                if self.percentage > 75 {
                    self.estimatedTime = "Less than a minute"
                }
            } else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    func startVideoGeneration(jobId: String) {
        self.jobId = jobId
        self.percentage = 0
        self.steps = self.steps.map { GenerationStep(title: $0.title, isCompleted: false) }
        self.estimatedTime = "2-3 minutes"
        setupProgressTracking()
        
        // Start polling the API for actual status
        pollVideoStatus()
    }
    
    private func pollVideoStatus() {
        guard let jobId = jobId else { return }
        
        // Poll every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            APIService.shared.getVideoStatus(jobId: jobId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure = completion {
                        timer.invalidate()
                    }
                } receiveValue: { [weak self] status in
                    self?.updateStatus(status)
                    if status.status == "completed" || status.status == "failed" {
                        timer.invalidate()
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func updateStatus(_ status: VideoStatusResponse) {
        // Update progress based on actual API response
        switch status.status {
        case "processing":
            percentage = 25
            steps[0].isCompleted = true
        case "generating_audio":
            percentage = 50
            steps[1].isCompleted = true
        case "creating_transitions":
            percentage = 75
            steps[2].isCompleted = true
        case "finalizing":
            percentage = 90
            steps[3].isCompleted = true
        case "completed":
            percentage = 100
            steps = steps.map { GenerationStep(title: $0.title, isCompleted: true) }
        case "failed":
            // Handle failure case
            break
        default:
            break
        }
    }
    
    func cancelGeneration() {
        guard let jobId = jobId else { return }
        
        APIService.shared.cancelVideoJob(jobId: jobId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to cancel video generation: \(error)")
                }
            } receiveValue: { _ in
                print("Video generation cancelled successfully")
            }
            .store(in: &cancellables)
        
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
} 