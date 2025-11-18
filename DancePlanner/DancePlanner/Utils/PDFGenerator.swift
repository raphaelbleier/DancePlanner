import SwiftUI
import PDFKit

@MainActor
class PDFGenerator {
    static func generatePDF(for project: Project) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Dance Planner",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: project.name
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            // Title Page
            context.beginPage()
            let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)]
            let titleString = project.name
            titleString.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            // Formations
            let sortedFormations = project.formations.sorted { $0.timestamp < $1.timestamp }
            
            for formation in sortedFormations {
                context.beginPage()
                
                // Header
                let header = "Formation: \(formation.name) (\(String(format: "%.1fs", formation.timestamp)))"
                header.draw(at: CGPoint(x: 50, y: 50), withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                
                // Draw Stage
                let stageRect = CGRect(x: 50, y: 100, width: pageWidth - 100, height: (pageWidth - 100) * 0.8)
                let path = UIBezierPath(rect: stageRect)
                UIColor.lightGray.withAlphaComponent(0.2).setFill()
                path.fill()
                UIColor.black.setStroke()
                path.lineWidth = 2
                path.stroke()
                
                // Draw Front Marker
                "STAGE FRONT".draw(at: CGPoint(x: stageRect.midX - 40, y: stageRect.maxY + 5), withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
                
                // Draw Dancers
                for placement in formation.placements {
                    guard let dancer = placement.dancer else { continue }
                    
                    // Map coordinates (assuming meters, centered at 0,0) to rect
                    // Stage width ~10m -> stageRect.width
                    let scale = stageRect.width / 10.0 // approx scale
                    
                    let x = stageRect.midX + CGFloat(placement.x) * scale
                    let y = stageRect.midY + CGFloat(placement.y) * scale
                    
                    let dancerRect = CGRect(x: x - 10, y: y - 10, width: 20, height: 20)
                    let dancerPath = UIBezierPath(ovalIn: dancerRect)
                    UIColor(hex: dancer.colorHex)?.setFill()
                    dancerPath.fill()
                    
                    // Label
                    let name = dancer.name.prefix(1)
                    let nameAttr = [
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12),
                        NSAttributedString.Key.foregroundColor: UIColor.white
                    ]
                    let textSize = name.size(withAttributes: nameAttr)
                    NSString(string: String(name)).draw(at: CGPoint(x: x - textSize.width/2, y: y - textSize.height/2), withAttributes: nameAttr)
                    
                    // Full Name below
                    let fullName = dancer.name
                    fullName.draw(at: CGPoint(x: x - 10, y: y + 12), withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8)])
                }
            }
        }
        
        let filename = "\(project.name).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Could not create PDF: \(error)")
            return nil
        }
    }
}
