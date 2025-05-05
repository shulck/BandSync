import Foundation
import PDFKit
import UIKit

final class SetlistPDFExporter {
    // Main export function
    static func export(setlist: Setlist, showBPM: Bool = true) -> Data? {
        let pdf = PDFDocument()
        
        // Create page with A4 dimensions
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsImageRenderer(bounds: pageBounds)
        
        let image = renderer.image { context in
            // Fill background
            UIColor.white.setFill()
            context.fill(pageBounds)
            
            // Draw content
            drawSetlistContent(setlist: setlist, in: pageBounds, context: context.cgContext, showBPM: showBPM)
        }
        
        if let page = PDFPage(image: image) {
            pdf.insert(page, at: 0)
            return pdf.dataRepresentation()
        }
        
        return nil
    }
    
    // Helper function to draw the content
    private static func drawSetlistContent(setlist: Setlist, in bounds: CGRect, context: CGContext, showBPM: Bool) {
        // Define margins and content area
        let margin: CGFloat = 50
        let contentArea = bounds.insetBy(dx: margin, dy: margin)
        
        // Prepare song attributes - крупный и жирный шрифт для песен
        let songFont = UIFont.boldSystemFont(ofSize: 16)
        let songAttributes: [NSAttributedString.Key: Any] = [
            .font: songFont,
            .foregroundColor: UIColor.black
        ]
        
        // Только красная линия вверху страницы
        let lineY = contentArea.minY + 40
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: contentArea.minX, y: lineY))
        context.addLine(to: CGPoint(x: contentArea.maxX, y: lineY))
        context.strokePath()
        
        // Draw songs
        var currentY = lineY + 30
        let lineHeight: CGFloat = 28  // Увеличенное расстояние между строками для лучшей читаемости
        
        for (index, song) in setlist.songs.enumerated() {
            // Format the song text based on showBPM setting
            let songText: String
            if showBPM {
                songText = "\(index + 1). \(song.title) - \(song.bpm) BPM"
            } else {
                songText = "\(index + 1). \(song.title)"
            }
            
            let songSize = songText.size(withAttributes: songAttributes)
            let songX = bounds.midX - songSize.width / 2
            let songRect = CGRect(x: songX, y: currentY, width: songSize.width, height: songSize.height)
            
            songText.draw(in: songRect, withAttributes: songAttributes)
            currentY += lineHeight
        }
    }
}
