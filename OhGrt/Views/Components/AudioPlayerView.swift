import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioURL: URL
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    var body: some View {
        VStack(spacing: 8) {
            if audioPlayer.isLoading {
                ProgressView("Loading audio...")
                    .padding()
            } else {
                // Seek bar
                Slider(value: $audioPlayer.currentTime, in: 0...audioPlayer.duration) { editing in
                    if !editing {
                        audioPlayer.seek(to: audioPlayer.currentTime)
                    }
                }
                .accentColor(.blue)
                
                HStack {
                    // Play/Pause button
                    Button(action: {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            audioPlayer.play()
                        }
                    }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    
                    // Time labels
                    Text(formatTime(audioPlayer.currentTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(formatTime(audioPlayer.duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onAppear {
            audioPlayer.setupPlayer(with: audioURL)
        }
        .onDisappear {
            audioPlayer.cleanup()
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

class AudioPlayerManager: NSObject, ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var playerItem: AVPlayerItem?
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isLoading = false
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func setupPlayer(with url: URL) {
        isLoading = true
        
        // Get the documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = url.lastPathComponent
        let localURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Check if file already exists
        if FileManager.default.fileExists(atPath: localURL.path) {
            // File exists, play it
            playLocalFile(at: localURL)
        } else {
            // Download the file
            downloadAudio(from: url, to: localURL)
        }
    }
    
    private func downloadAudio(from remoteURL: URL, to localURL: URL) {
        let task = URLSession.shared.downloadTask(with: remoteURL) { [weak self] tempURL, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Download error: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let tempURL = tempURL else {
                print("No temporary URL")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                // Remove existing file if it exists
                if FileManager.default.fileExists(atPath: localURL.path) {
                    try FileManager.default.removeItem(at: localURL)
                }
                
                // Move the downloaded file to the documents directory
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                
                DispatchQueue.main.async {
                    self.playLocalFile(at: localURL)
                }
            } catch {
                print("File operation error: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        task.resume()
    }
    
    private func playLocalFile(at url: URL) {
        let asset = AVURLAsset(url: url)
        
        // Load asset asynchronously
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                var error: NSError?
                let status = asset.statusOfValue(forKey: "duration", error: &error)
                
                if status == .loaded {
                    self.duration = asset.duration.seconds
                    self.playerItem = AVPlayerItem(asset: asset)
                    self.player = AVPlayer(playerItem: self.playerItem)
                    
                    // Observe current time
                    self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
                        self?.currentTime = time.seconds
                    }
                    
                    // Observe playback status
                    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
                    
                    // Observe player item status
                    self.playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
                } else {
                    print("Failed to load asset: \(error?.localizedDescription ?? "Unknown error")")
                }
                self.isLoading = false
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let playerItem = object as? AVPlayerItem {
            switch playerItem.status {
            case .readyToPlay:
                print("Player item is ready to play")
            case .failed:
                print("Player item failed: \(String(describing: playerItem.error))")
                if let error = playerItem.error as NSError? {
                    print("Error domain: \(error.domain)")
                    print("Error code: \(error.code)")
                    print("Error description: \(error.localizedDescription)")
                    print("Error user info: \(error.userInfo)")
                }
            case .unknown:
                print("Player item status unknown")
            @unknown default:
                break
            }
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        currentTime = 0
        player?.seek(to: .zero)
    }
    
    func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        player?.pause()
        player = nil
        playerItem = nil
    }
    
    deinit {
        cleanup()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
} 

