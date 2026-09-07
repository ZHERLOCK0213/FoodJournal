import Foundation
import AppKit
import SwiftUI

/// Compile with AnatomyArtwork.swift. This export uses the same paths as the iOS renderer.
@main
struct ExportAnatomy {
    static func main() throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let cutaway = CommandLine.arguments.contains("--cutaway")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        func save(_ name: String, _ contents: String) throws {
            try contents.write(to: directory.appendingPathComponent(name), atomically: true, encoding: .utf8)
        }
        func document(_ contents: String) -> String {
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"640\" height=\"880\" viewBox=\"0 0 320 440\">\(contents)</svg>"
        }
        let body = cutaway
            ? "<path d=\"\(AnatomyArtwork.cutawayData)\" fill=\"none\" stroke=\"#93A5C6\" stroke-opacity=\"0.4\" stroke-width=\"0.9\"/>"
            : "<path d=\"\(AnatomyArtwork.bodyData)\" fill=\"#293255\" fill-opacity=\"0.45\" stroke=\"#687CA5\" stroke-width=\"1\"/><path d=\"\(AnatomyArtwork.faceData)\" fill=\"none\" stroke=\"#93A5C6\" stroke-width=\"0.9\"/><path d=\"\(AnatomyArtwork.bodyDetailsData)\" fill=\"none\" stroke=\"#93A5C6\" stroke-opacity=\"0.35\" stroke-width=\"0.8\"/>"
        try save("body.svg", document(body))
        var assembled = body
        var cards = "<article><img src='body.svg'><h2>人体底图</h2><a href='body.png'>透明 PNG</a></article>"
        for asset in AnatomyArtwork.assets {
            let paint = asset.strokeWidth > 0
                ? "fill=\"none\" stroke=\"#\(asset.colorHex)\" stroke-width=\"\(asset.strokeWidth)\" stroke-linecap=\"round\" stroke-linejoin=\"round\""
                : "fill=\"#\(asset.colorHex)\""
            let shape = "<path d=\"\(asset.data)\" \(paint)/>"
            try save("\(asset.part.rawValue).svg", document(shape))
            assembled += shape
            cards += "<article><img src='\(asset.part.rawValue).svg'><h2>\(asset.part.label)</h2><a href='\(asset.part.rawValue).png'>透明 PNG</a></article>"
            try png(directory.appendingPathComponent("\(asset.part.rawValue).png"), assets: [asset], body: false)
        }
        try save("assembled.svg", document(assembled))
        try png(directory.appendingPathComponent("body.png"), assets: [], body: true, cutaway: cutaway)
        try png(directory.appendingPathComponent("assembled.png"), assets: AnatomyArtwork.assets, body: true, cutaway: cutaway)
        try save("index.html", """
        <!doctype html><html lang="zh"><meta charset="utf-8"><title>FoodJourney · 独立器官素材</title>
        <style>body{background:#0d1020;color:#e9edf8;font:16px system-ui;margin:40px}h1{font-size:25px}p{color:#a2aec6}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:16px}article{background:#171e31;border:1px solid #303c56;border-radius:16px;padding:16px}img{width:100%;height:280px;object-fit:contain}h2{font-size:16px}a{color:#93d6c5}.hero{width:340px;height:auto;float:right}</style>
        <h1>FoodJourney · 独立器官素材 \(directory.lastPathComponent)</h1><p>\(cutaway ? "口腔至肛门 · 局部剖面" : "成年正面躯干") · 圆润器官 · 透明底</p>
        <p>所有素材使用 320 × 440 注册画布，可原位叠加。SVG 可编辑，PNG 为 2 倍透明导出。双肾作为一个可聚焦器官组。</p>
        <main><article><img src="assembled.svg"><h2>拼接预览</h2><a href="assembled.png">透明 PNG</a></article>\(cards)</main></html>
        """)
        print("Exported body, 10 organ layers, assembled preview and contact sheet to \(directory.path)")
        let kidneyBounds = AnatomyArtwork.asset(.kidneys).path.boundingRect
        for x in stride(from: floor(kidneyBounds.minX), through: ceil(kidneyBounds.maxX), by: 1) {
            for y in stride(from: floor(kidneyBounds.minY), through: ceil(kidneyBounds.maxY), by: 1) {
                let point = CGPoint(x: x, y: y)
                if AnatomyArtwork.asset(.kidneys).path.cgPath.contains(point) && !AnatomyArtwork.containsBody(point) {
                    preconditionFailure("Kidney outside torso at \(point)")
                }
            }
        }
    }

    static func png(_ url: URL, assets: [AnatomyAsset], body: Bool, cutaway: Bool = false) throws {
        let context = CGContext(data: nil, width: 640, height: 880, bitsPerComponent: 8, bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.translateBy(x: 0, y: 880)
        context.scaleBy(x: 2, y: -2)
        func color(_ hex: String, _ alpha: CGFloat = 1) -> CGColor {
            let n = UInt32(hex, radix: 16)!
            return CGColor(red: CGFloat(n >> 16 & 255)/255, green: CGFloat(n >> 8 & 255)/255,
                           blue: CGFloat(n & 255)/255, alpha: alpha)
        }
        if body && cutaway {
            context.addPath(AnatomyArtwork.parse(AnatomyArtwork.cutawayData).cgPath)
            context.setStrokeColor(color("93A5C6", 0.4)); context.setLineWidth(0.9); context.strokePath()
        } else if body {
            context.addPath(AnatomyArtwork.bodyPath.cgPath)
            context.setFillColor(color("293255", 0.45)); context.setStrokeColor(color("687CA5"))
            context.setLineWidth(1); context.drawPath(using: .fillStroke)
            context.addPath(AnatomyArtwork.parse(AnatomyArtwork.faceData).cgPath)
            context.setStrokeColor(color("93A5C6")); context.strokePath()
            context.addPath(AnatomyArtwork.parse(AnatomyArtwork.bodyDetailsData).cgPath)
            context.setStrokeColor(color("93A5C6", 0.35)); context.setLineWidth(0.8); context.strokePath()
        }
        for asset in assets {
            context.saveGState()
            context.addPath(asset.path.cgPath); context.clip()
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: [color(asset.colorHex), color(asset.colorHex, 0.72)] as CFArray,
                                      locations: [0, 1])!
            let b = asset.path.boundingRect
            context.drawLinearGradient(gradient, start: CGPoint(x: b.midX, y: b.minY),
                                       end: CGPoint(x: b.midX, y: b.maxY), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            context.restoreGState()
        }
        let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
        try bitmap.representation(using: .png, properties: [:])!.write(to: url)
    }
}
