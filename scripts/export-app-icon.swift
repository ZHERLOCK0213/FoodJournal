import AppKit
import SwiftUI

/// Authored vector mark: short esophageal inlet, fundus dome, lesser curvature and pyloric outlet.
/// Compile with AnatomyArtwork.swift; writes an opaque 1024px iOS icon and editable SVG source.
@main
struct ExportAppIcon {
    static let shape = "M 430 160 Q 430 148 442 148 L 503 148 Q 515 148 515 160 L 515 298 C 570 218 704 226 757 329 C 844 495 769 689 617 756 C 488 813 368 757 303 655 Q 274 610 235 627 L 202 643 Q 191 648 186 637 L 163 584 Q 158 573 170 568 L 205 552 C 273 521 333 552 370 610 C 408 669 478 686 527 644 C 585 593 556 520 501 471 C 444 421 430 380 430 324 Z"
    static let shine = "M 563 313 C 623 277 694 317 714 383"
    static func main() throws {
        let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let directory = root.appendingPathComponent("Design/AppIcon/v2", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let target = root.appendingPathComponent("FoodJourney/Assets.xcassets/AppIcon.appiconset/icon_1024.png")
        let backup = directory.appendingPathComponent("previous-icon.png")
        if !FileManager.default.fileExists(atPath: backup.path) {
            try FileManager.default.copyItem(at: target, to: backup)
        }
        let svg = """
        <svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
        <defs><linearGradient id="bg" x2="0" y2="1"><stop stop-color="#E5F4FA"/><stop offset="1" stop-color="#BCDDEC"/></linearGradient><linearGradient id="ink" x2="0.6" y2="1"><stop stop-color="#327CAB"/><stop offset="1" stop-color="#20547E"/></linearGradient></defs>
        <path fill="url(#bg)" d="M 0 0 H 1024 V 1024 H 0 Z"/>
        <path d="\(shape)" fill="url(#ink)"/>
        <path d="\(shine)" fill="none" stroke="#B5DFEF" stroke-opacity="0.45" stroke-width="16" stroke-linecap="round"/>
        </svg>
        """
        try svg.write(to: directory.appendingPathComponent("stomach.svg"), atomically: true, encoding: .utf8)
        let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        context.translateBy(x: 0, y: 1024); context.scaleBy(x: 1, y: -1)
        func color(_ hex: String) -> CGColor {
            let n = UInt32(hex, radix: 16)!
            return CGColor(red: CGFloat(n >> 16 & 255) / 255, green: CGFloat(n >> 8 & 255) / 255,
                           blue: CGFloat(n & 255) / 255, alpha: 1)
        }
        func gradient(_ colors: [String], _ start: CGPoint, _ end: CGPoint) {
            let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map(color) as CFArray,
                               locations: [0, 1])!
            context.drawLinearGradient(g, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
        gradient(["E5F4FA", "BCDDEC"], .zero, CGPoint(x: 0, y: 1024))
        context.saveGState()
        context.addPath(AnatomyArtwork.parse(shape).cgPath); context.clip()
        gradient(["327CAB", "20547E"], CGPoint(x: 350, y: 148), CGPoint(x: 700, y: 780))
        context.restoreGState()
        context.addPath(AnatomyArtwork.parse(shine).cgPath)
        context.setStrokeColor(color("B5DFEF")); context.setAlpha(0.45)
        context.setLineWidth(16); context.setLineCap(.round); context.strokePath()
        let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
        let data = bitmap.representation(using: .png, properties: [:])!
        try data.write(to: directory.appendingPathComponent("icon_1024.png"))
        try data.write(to: target)
        print("Exported opaque stomach icon; original preserved at \(backup.path)")
    }
}
