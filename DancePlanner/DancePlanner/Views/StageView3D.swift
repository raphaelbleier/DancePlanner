import SwiftUI
import SceneKit

struct StageView3D: UIViewRepresentable {
    var project: Project
    @ObservedObject var playbackManager: PlaybackManager
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = UIColor.black
        
        setupScene(scnView.scene!)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Update dancer positions based on playbackManager
        guard let scene = scnView.scene else { return }
        
        // Check if we need to add/remove nodes (e.g. dancers added)
        // For now, we assume dancers set is stable during playback, but we should be robust
        
        for dancer in project.dancers {
            let nodeName = "dancer_\(dancer.id)"
            var node = scene.rootNode.childNode(withName: nodeName, recursively: false)
            
            if node == nil {
                // Create node if missing
                let geometry = SCNCapsule(capRadius: 0.2, height: 1.7)
                geometry.firstMaterial?.diffuse.contents = UIColor(hex: dancer.colorHex)
                node = SCNNode(geometry: geometry)
                node?.name = nodeName
                scene.rootNode.addChildNode(node!)
            }
            
            if let pos = playbackManager.currentPositions[dancer.id] {
                // Update position
                // 3D World: X is width, Y is height (up), Z is depth
                // Our model: x (width), y (depth)
                // We map model Y to World -Z (standard stage coordinates often have -Z as upstage)
                // But let's stick to simple mapping first: X->X, Y->-Z
                
                // Center the stage. If stage is 10m wide, 0 is center.
                // Our model might be 0-1 normalized or meters. 
                // Let's assume meters from center for now based on previous code.
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.05 // Smooth out slightly
                node?.position = SCNVector3(x: Float(pos.0), y: 0.85, z: Float(-pos.1))
                node?.eulerAngles.y = Float(-pos.2 * .pi / 180.0) // Rotation
                SCNTransaction.commit()
            }
        }
    }
    
    private func setupScene(_ scene: SCNScene) {
        // Floor (Infinite dark background)
        let floor = SCNNode(geometry: SCNFloor())
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        scene.rootNode.addChildNode(floor)
        
        // Stage Bounds
        if let stage = project.stageConfig {
            let stageNode = SCNNode()
            
            let shape: SCNGeometry
            switch stage.shape {
            case .rectangle:
                // Box with very small height
                shape = SCNBox(width: CGFloat(stage.width), height: 0.05, length: CGFloat(stage.depth), chamferRadius: 0)
            case .circle:
                // Cylinder with very small height
                shape = SCNCylinder(radius: CGFloat(stage.width) / 2, height: 0.05)
            case .oval:
                // Cylinder scaled (approximate oval)
                shape = SCNCylinder(radius: CGFloat(stage.width) / 2, height: 0.05)
                // We'll scale the node later if needed, but SCNGeometry is easier to just use cylinder for circle
                // For oval, we might need a custom shape or just scale the node.
            }
            
            shape.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
            stageNode.geometry = shape
            
            // If oval, scale z axis
            if stage.shape == .oval {
                stageNode.scale = SCNVector3(1, 1, Float(stage.depth / stage.width))
            }
            
            stageNode.position = SCNVector3(0, 0.025, 0) // Slightly above floor
            scene.rootNode.addChildNode(stageNode)
            
            // Add a "Front" marker
            let text = SCNText(string: "FRONT", extrusionDepth: 0.1)
            text.font = UIFont.systemFont(ofSize: 0.5)
            text.flatness = 0.01
            let textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(0.5, 0.5, 0.5)
            // Center text
            let (min, max) = textNode.boundingBox
            textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2, 0, 0)
            textNode.position = SCNVector3(0, 0.1, Float(stage.depth / 2) + 0.5)
            textNode.eulerAngles.x = -.pi / 2
            scene.rootNode.addChildNode(textNode)
        }
        
        // Lights
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
    }
}
