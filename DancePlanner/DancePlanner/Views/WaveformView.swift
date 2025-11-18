import SwiftUI

struct WaveformView: View {
    var samples: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2
                let count = samples.count
                let step = width / CGFloat(count)
                
                for (index, sample) in samples.enumerated() {
                    let x = CGFloat(index) * step
                    let amplitude = CGFloat(sample) * (height / 2)
                    
                    path.move(to: CGPoint(x: x, y: midY - amplitude))
                    path.addLine(to: CGPoint(x: x, y: midY + amplitude))
                }
            }
            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
        }
    }
}
