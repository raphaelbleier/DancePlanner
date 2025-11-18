import SwiftUI

struct TimelineView: View {
    var project: Project
    @ObservedObject var playbackManager: PlaybackManager
    @State private var showFileImporter = false
    @State private var showFormationSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Controls
            HStack {
                Button(action: { playbackManager.togglePlayPause() }) {
                    Image(systemName: playbackManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                
                Text(timeString(from: playbackManager.currentTime))
                    .monospacedDigit()
                
                Spacer()
                
                Button(action: {
                    playbackManager.addKeyframeAtCurrentTime()
                }) {
                    Image(systemName: "plus.diamond")
                }
                
                if let activeFormation = playbackManager.activeFormation {
                    Button(action: {
                        showFormationSettings = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .sheet(isPresented: $showFormationSettings) {
                        if let project = playbackManager.project {
                            NavigationStack {
                                FormationSettingsView(formation: activeFormation, project: project)
                            }
                            .presentationDetents([.medium])
                        }
                    }
                }
                
                Button(action: {
                    showFileImporter = true
                }) {
                    Image(systemName: "music.note.list")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.thinMaterial)
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        importAudio(from: url)
                    }
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
            
            // Timeline Track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background Tracks
                    Rectangle()
                        .fill(Color(uiColor: .secondarySystemBackground))
                    
                    // Waveform
                    if !playbackManager.audioController.waveformSamples.isEmpty {
                        WaveformView(samples: playbackManager.audioController.waveformSamples)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                    
                    // Beat Markers (Visual only for now)
                    ForEach(0..<Int(playbackManager.duration), id: \.self) { second in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: geometry.size.height)
                            .offset(x: CGFloat(second) * (geometry.size.width / CGFloat(playbackManager.duration)))
                    }
                    
                    // Playhead
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2, height: geometry.size.height)
                        .offset(x: CGFloat(playbackManager.currentTime / playbackManager.duration) * geometry.size.width)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let location = value.location.x
                                    let progress = location / geometry.size.width
                                    playbackManager.seek(to: TimeInterval(progress) * playbackManager.duration)
                                }
                        )
                }
            }
        }
        .frame(height: 120)
        .background(Color(uiColor: .systemBackground))
        .border(Color(uiColor: .separator), width: 1)
    }
    
    private func importAudio(from url: URL) {
        // 1. Secure access to the file
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // 2. Copy to Documents Directory
        do {
            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destination = docs.appendingPathComponent(url.lastPathComponent)
            
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            
            try fileManager.copyItem(at: url, to: destination)
            
            // 3. Update Project
            project.audioFilename = url.lastPathComponent
            
            // 4. Load into PlaybackManager
            playbackManager.loadAudio(url: destination)
            
        } catch {
            print("Error importing audio: \(error)")
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
