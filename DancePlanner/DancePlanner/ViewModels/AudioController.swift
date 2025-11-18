import AVFoundation
import SwiftUI

class AudioController: NSObject, ObservableObject {
    var player: AVAudioPlayer?
    
    @Published var duration: TimeInterval = 0
    @Published var isPlaying = false
    @Published var waveformSamples: [Float] = []
    
    func loadAudio(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            
            // Generate waveform asynchronously
            Task {
                let samples = await generateWaveform(from: url)
                await MainActor.run {
                    self.waveformSamples = samples
                }
            }
        } catch {
            print("Failed to load audio: \(error)")
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
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }
    
    var currentTime: TimeInterval {
        return player?.currentTime ?? 0
    }
    
    private func generateWaveform(from url: URL) async -> [Float] {
        return await Task.detached {
            guard let file = try? AVAudioFile(forReading: url),
                  let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false),
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) else {
                return []
            }
            
            try? file.read(into: buffer)
            
            guard let floatChannelData = buffer.floatChannelData else { return [] }
            
            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))
            
            // Downsample to ~100 samples per second for visualization
            let samplesPerSecond = 50 // Adjust for resolution
            let totalSamples = Int(file.duration) * samplesPerSecond
            let processingStride = max(1, samples.count / totalSamples)
            
            var result: [Float] = []
            for i in stride(from: 0, to: samples.count, by: processingStride) {
                // Calculate RMS or Peak for this chunk
                let chunkEnd = min(i + processingStride, samples.count)
                let chunk = samples[i..<chunkEnd]
                let rms = sqrt(chunk.map { $0 * $0 }.reduce(0, +) / Float(chunk.count))
                result.append(rms)
            }
            
            // Normalize
            if let max = result.max(), max > 0 {
                return result.map { $0 / max }
            }
            
            return result
        }.value
    }
}
