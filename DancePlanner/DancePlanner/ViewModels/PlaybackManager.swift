import SwiftUI
import Combine

class PlaybackManager: ObservableObject {
    @Published var currentTime: TimeInterval = 0
    @Published var isPlaying = false
    @Published var duration: TimeInterval = 60.0
    
    private var timer: AnyCancellable?
    private var lastUpdateTime: Date?
    
    let audioController = AudioController()
    
    // Cache for calculated positions: [DancerID: (x, y, rotation)]
    @Published var currentPositions: [UUID: (Double, Double, Double)] = [:]
    
    // Active Formation (if we are exactly on a keyframe)
    @Published var activeFormation: Formation?
    
    var project: Project?
    
    func setProject(_ project: Project) {
        self.project = project
        // Initial calculation
        updatePositions()
        
        // Load Audio if exists
        if let filename = project.audioFilename {
            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = docs.appendingPathComponent(filename)
            if fileManager.fileExists(atPath: url.path) {
                loadAudio(url: url)
            }
        }
    }
    
    func loadAudio(url: URL) {
        audioController.loadAudio(url: url)
        // Update duration from audio
        if audioController.duration > 0 {
            self.duration = audioController.duration
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        isPlaying = true
        if audioController.player != nil {
            audioController.play()
        }
        lastUpdateTime = Date()
        timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        isPlaying = false
        if audioController.player != nil {
            audioController.pause()
        }
        timer?.cancel()
        timer = nil
    }
    
    func seek(to time: TimeInterval) {
        currentTime = max(0, min(duration, time))
        if audioController.player != nil {
            audioController.seek(to: currentTime)
        }
        updatePositions()
    }
    
    private func tick() {
        if let player = audioController.player, player.isPlaying {
            // Sync with audio player
            currentTime = player.currentTime
            if currentTime >= duration {
                pause()
            }
        } else {
            // Fallback to manual timer logic
            guard let lastUpdate = lastUpdateTime else { return }
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdateTime = now
            
            currentTime += delta
            if currentTime >= duration {
                currentTime = duration
                pause()
            }
        }
        
        updatePositions()
    }
    
    private func updatePositions() {
        guard let project = project else { return }
        
        // 1. Find active formations (before and after current time)
        let sortedFormations = project.formations.sorted { $0.timestamp < $1.timestamp }
        
        guard !sortedFormations.isEmpty else { return }
        
        // Find the formation immediately before or at current time
        let previousIndex = sortedFormations.lastIndex { $0.timestamp <= currentTime }
        
        var newPositions: [UUID: (Double, Double, Double)] = [:]
        
        if let prevIndex = previousIndex {
            let prevFormation = sortedFormations[prevIndex]
            
            // Check if there is a next formation to interpolate to
            if prevIndex + 1 < sortedFormations.count {
                let nextFormation = sortedFormations[prevIndex + 1]
                
                // Calculate progress (0.0 to 1.0)
                let timeDiff = nextFormation.timestamp - prevFormation.timestamp
                let progress = (currentTime - prevFormation.timestamp) / timeDiff
                
                // Interpolate for each dancer
                for dancer in project.dancers {
                    let startPlacement = prevFormation.placements.first { $0.dancer?.id == dancer.id }
                    let endPlacement = nextFormation.placements.first { $0.dancer?.id == dancer.id }
                    
                    if let start = startPlacement, let end = endPlacement {
                        // Linear interpolation
                        let x = start.x + (end.x - start.x) * progress
                        let y = start.y + (end.y - start.y) * progress
                        let rot = start.rotation + (end.rotation - start.rotation) * progress
                        newPositions[dancer.id] = (x, y, rot)
                    } else if let start = startPlacement {
                        // Only start position exists (stay there)
                        newPositions[dancer.id] = (start.x, start.y, start.rotation)
                    } else if let end = endPlacement {
                        // Only end position exists (jump there? or stay hidden? Let's snap to end)
                        newPositions[dancer.id] = (end.x, end.y, end.rotation)
                    }
                }
            } else {
                // Last formation, just hold positions
                for placement in prevFormation.placements {
                    if let dancerId = placement.dancer?.id {
                        newPositions[dancerId] = (placement.x, placement.y, placement.rotation)
                    }
                }
            }
        } else {
            // Before first formation
            if let firstFormation = sortedFormations.first {
                for placement in firstFormation.placements {
                    if let dancerId = placement.dancer?.id {
                        newPositions[dancerId] = (placement.x, placement.y, placement.rotation)
                    }
                }
            }
        }
        
        currentPositions = newPositions
        
        // Check if we are close to a formation to mark it as active
        if let prevIndex = previousIndex {
            let prevFormation = sortedFormations[prevIndex]
            if abs(prevFormation.timestamp - currentTime) < 0.1 {
                activeFormation = prevFormation
            } else {
                activeFormation = nil
            }
        } else {
            activeFormation = nil
        }
    }
    
    func updateTemporaryPosition(for dancerID: UUID, x: Double, y: Double) {
        if var pos = currentPositions[dancerID] {
            pos.0 = x
            pos.1 = y
            currentPositions[dancerID] = pos
        }
    }
    
    func commitPosition(for dancer: Dancer, x: Double, y: Double) {
        guard let project = project else { return }
        
        // 1. Find or create formation at current time
        let formation: Formation
        if let active = activeFormation {
            formation = active
        } else {
            // Create new formation
            formation = Formation(name: "Keyframe \(Int(currentTime))", timestamp: currentTime)
            project.formations.append(formation)
            activeFormation = formation
        }
        
        // 2. Update or create placement
        if let existingPlacement = formation.placements.first(where: { $0.dancer?.id == dancer.id }) {
            existingPlacement.x = x
            existingPlacement.y = y
        } else {
            let placement = Placement(x: x, y: y, dancer: dancer)
            formation.placements.append(placement)
        }
        
        // 3. Trigger update
        updatePositions()
    }
    
    func addKeyframeAtCurrentTime() {
        guard let project = project else { return }
        // Check if one exists very close
        if activeFormation == nil {
            let formation = Formation(name: "Keyframe \(Int(currentTime))", timestamp: currentTime)
            
            // Copy positions from current interpolation
            for dancer in project.dancers {
                if let pos = currentPositions[dancer.id] {
                    let placement = Placement(x: pos.0, y: pos.1, rotation: pos.2, dancer: dancer)
                    formation.placements.append(placement)
                }
            }
            
            project.formations.append(formation)
            updatePositions()
        }
    }
    
    func pathPoints(for dancer: Dancer) -> [CGPoint] {
        guard let project = project else { return [] }
        let sortedFormations = project.formations.sorted { $0.timestamp < $1.timestamp }
        var points: [CGPoint] = []
        
        for formation in sortedFormations {
            if let placement = formation.placements.first(where: { $0.dancer?.id == dancer.id }) {
                points.append(CGPoint(x: placement.x, y: placement.y))
            }
        }
        return points
    }
    
    func color(for dancer: Dancer) -> Color {
        // Check active formation or previous formation for costume assignment
        // For simplicity, we look at the formation immediately preceding current time
        guard let project = project else { return dancer.color }
        
        let sortedFormations = project.formations.sorted { $0.timestamp < $1.timestamp }
        let prevIndex = sortedFormations.lastIndex { $0.timestamp <= currentTime }
        
        if let index = prevIndex {
            let formation = sortedFormations[index]
            if let costumeID = formation.costumeAssignments[dancer.id],
               let costume = project.costumes.first(where: { $0.id == costumeID }) {
                return costume.color
            }
        }
        
        return dancer.color
    }
}
