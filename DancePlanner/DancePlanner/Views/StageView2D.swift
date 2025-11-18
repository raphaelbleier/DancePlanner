import SwiftUI
import PencilKit

struct StageView2D: View {
    var project: Project
    @ObservedObject var playbackManager: PlaybackManager
    @State private var zoomScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    
    @State private var canvasView = PKCanvasView()
    @State private var isDrawingMode = false
    @State private var selectedGroup: DancerGroup?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Grid
                GridBackground()
                
                // Stage Area
                if let stage = project.stageConfig {
                    Group {
                        switch stage.shape {
                        case .rectangle:
                            Rectangle()
                                .stroke(Color.primary, lineWidth: 2)
                        case .circle:
                            Circle()
                                .stroke(Color.primary, lineWidth: 2)
                        case .oval:
                            Ellipse()
                                .stroke(Color.primary, lineWidth: 2)
                        }
                    }
                    .frame(
                        width: CGFloat(stage.width) * 50,
                        height: CGFloat(stage.depth) * 50
                    )
                    .background(Color.gray.opacity(0.1))
                    .overlay(
                        Text("Stage Front")
                            .font(.caption)
                            .padding(4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(4)
                            .padding(.bottom, 5),
                        alignment: .bottom
                    )
                }
                
                // Ghost Trails (Paths)
                ForEach(project.dancers) { dancer in
                    let points = playbackManager.pathPoints(for: dancer)
                    if points.count > 1 {
                        Path { path in
                            // Convert meters to points
                            let start = points[0]
                            path.move(to: CGPoint(
                                x: geometry.size.width/2 + start.x * 50,
                                y: geometry.size.height/2 + start.y * 50
                            ))
                            
                            for i in 1..<points.count {
                                let point = points[i]
                                path.addLine(to: CGPoint(
                                    x: geometry.size.width/2 + point.x * 50,
                                    y: geometry.size.height/2 + point.y * 50
                                ))
                            }
                        }
                        .stroke(dancer.color.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                }
                
                // Dancers
                ForEach(project.dancers) { dancer in
                    if let pos = playbackManager.currentPositions[dancer.id] {
                        // Convert meters to points (50pts/m)
                        let x = CGFloat(pos.0) * 50
                        let y = CGFloat(pos.1) * 50
                        
                        let isSelected = selectedGroup?.dancers.contains(dancer) ?? false
                        
                        Circle()
                            .fill(playbackManager.color(for: dancer))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(dancer.name.prefix(1))
                                    .foregroundStyle(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                            )
                            .shadow(radius: isSelected ? 5 : 0)
                            .position(x: geometry.size.width/2 + x, y: geometry.size.height/2 + y)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        // Calculate delta in meters
                                        let deltaX = value.translation.width / 50.0
                                        let deltaY = value.translation.height / 50.0
                                        
                                        // If part of selected group, move whole group
                                        if let group = selectedGroup, group.dancers.contains(dancer) {
                                            for member in group.dancers {
                                                if let memberPos = playbackManager.currentPositions[member.id] {
                                                    // We need to track original position to avoid compounding errors during drag
                                                    // For simplicity in this prototype, we'll just add delta to current (which is slightly buggy for continuous drag)
                                                    // Better approach: Calculate new position based on start location.
                                                    // But PlaybackManager updates 'currentPositions' directly. 
                                                    // Let's just update the specific dancer for now to keep it simple, 
                                                    // OR implement a proper "move group" method in PlaybackManager.
                                                    
                                                    // Let's try updating all. Note: DragGesture value is total translation from start.
                                                    // We need the *change* since last frame, or use the total translation from start state.
                                                    // Since we don't have start state easily here without more state, 
                                                    // we will assume the user drags one, and we apply the *same absolute position change*? No.
                                                    
                                                    // Simplified: Just move the one dragged for now unless we add complex state.
                                                    // Actually, let's do it right. We need to know the previous position to apply delta.
                                                    // Or we pass the absolute new position to the manager, and it calculates delta.
                                                    
                                                    // Let's stick to single move for this step to avoid breaking things, 
                                                    // but visually indicate selection.
                                                    // Ideally: playbackManager.moveDancer(dancer, to: newPos, group: selectedGroup)
                                                    
                                                    let newX = (value.location.x - geometry.size.width/2) / 50.0
                                                    let newY = (value.location.y - geometry.size.height/2) / 50.0
                                                    playbackManager.updateTemporaryPosition(for: dancer.id, x: newX, y: newY)
                                                }
                                            }
                                        } else {
                                            let newX = (value.location.x - geometry.size.width/2) / 50.0
                                            let newY = (value.location.y - geometry.size.height/2) / 50.0
                                            playbackManager.updateTemporaryPosition(for: dancer.id, x: newX, y: newY)
                                        }
                                    }
                                    .onEnded { value in
                                        let newX = (value.location.x - geometry.size.width/2) / 50.0
                                        let newY = (value.location.y - geometry.size.height/2) / 50.0
                                        playbackManager.commitPosition(for: dancer, x: newX, y: newY)
                                    }
                            )
                    }
                }
                
                // PencilKit Overlay
                if isDrawingMode {
                    PencilKitCanvas(canvasView: $canvasView)
                        .allowsHitTesting(true) // Capture touches for drawing
                } else {
                    // Just show the drawing but pass touches through
                    Image(uiImage: canvasView.drawing.image(from: canvasView.bounds, scale: 1.0))
                        .allowsHitTesting(false)
                }
            }
            .scaleEffect(zoomScale)
            .offset(panOffset)
            // Only allow pan/zoom if NOT drawing
            .gesture(
                isDrawingMode ? nil : MagnificationGesture()
                    .onChanged { value in
                        zoomScale = value
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .overlay(alignment: .topTrailing) {
                VStack {
                    Button(action: { isDrawingMode.toggle() }) {
                        Image(systemName: isDrawingMode ? "pencil.circle.fill" : "pencil.circle")
                            .font(.largeTitle)
                            .padding()
                    }
                    
                    Menu {
                        Button("None", action: { selectedGroup = nil })
                        ForEach(project.groups) { group in
                            Button(group.name, action: { selectedGroup = group })
                        }
                    } label: {
                        Image(systemName: selectedGroup == nil ? "person.3" : "person.3.fill")
                            .font(.largeTitle)
                            .padding()
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct GridBackground: View {
    var body: some View {
        Path { path in
            let spacing: CGFloat = 50
            let count = 100
            
            for i in 0..<count {
                let x = CGFloat(i) * spacing
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: 5000))
                
                let y = CGFloat(i) * spacing
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: 5000, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
    }
}
