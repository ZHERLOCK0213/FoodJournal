import SwiftUI

/// Shared registration transform for artwork, hit testing and orthogonal callout leaders.
struct AnatomyCalloutLayout {
    static let crop = CGRect(x: 86, y: 48, width: 146, height: 340)
    static let left: [AnatomyPart] = [.esophagus, .liver, .gallbladder, .pancreas, .kidneys]
    static let right: [AnatomyPart] = [.mouth, .stomach, .duodenum, .smallIntestine, .largeIntestine]
    let size: CGSize
    let cardWidth: CGFloat
    let cardHeight: CGFloat = 76
    let transform: CGAffineTransform

    init(size: CGSize) {
        self.size = size
        cardWidth = min(110, max(86, size.width * 0.24))
        let availableWidth = max(100, size.width - 2 * (cardWidth + 23))
        let scale = min(availableWidth / Self.crop.width, (size.height - 42) / Self.crop.height)
        transform = CGAffineTransform(translationX: size.width / 2 - Self.crop.midX * scale,
                                      y: size.height / 2 - Self.crop.midY * scale)
            .scaledBy(x: scale, y: scale)
    }

    func cardRect(_ part: AnatomyPart) -> CGRect {
        let left = Self.left.contains(part)
        let index = (left ? Self.left : Self.right).firstIndex(of: part)!
        let spacing = (size.height - cardHeight - 16) / 4
        return CGRect(x: left ? 8 : size.width - 8 - cardWidth,
                      y: 8 + CGFloat(index) * spacing, width: cardWidth, height: cardHeight)
    }

    func anchor(_ part: AnatomyPart) -> CGPoint {
        let point: CGPoint
        switch part {
        case .kidneys: point = CGPoint(x: 121, y: 237) // Select the left member of the paired asset.
        case .pancreas: point = CGPoint(x: 151, y: 234)
        case .largeIntestine: point = CGPoint(x: 209, y: 337)
        default: point = AnatomyArtwork.asset(part).anchor
        }
        return point.applying(transform)
    }

    func leaderPoints(_ part: AnatomyPart) -> [CGPoint] {
        let left = Self.left.contains(part)
        let row = (left ? Self.left : Self.right).firstIndex(of: part)!
        let card = cardRect(part)
        let start = CGPoint(x: left ? card.maxX : card.minX, y: card.midY)
        let lane = start.x + (left ? 1 : -1) * CGFloat(7 + row * 2)
        let end = anchor(part)
        return [start, CGPoint(x: lane, y: start.y), CGPoint(x: lane, y: end.y), end]
    }

    func leader(_ part: AnatomyPart) -> Path {
        let points = leaderPoints(part)
        var path = Path()
        path.addLines(points)
        return path
    }
}
