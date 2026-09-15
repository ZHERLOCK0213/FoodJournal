import SwiftUI

/// All independent artwork shares a registration canvas, so exported SVGs and the app align.
enum AnatomyPart: String, CaseIterable, Identifiable {
    case mouth, esophagus, stomach, duodenum, liver, gallbladder, pancreas, kidneys, smallIntestine, largeIntestine
    var id: String { rawValue }
    var label: String {
        switch self {
        case .mouth: "口腔"
        case .esophagus: "食管"
        case .stomach: "胃"
        case .duodenum: "十二指肠"
        case .liver: "肝脏"
        case .gallbladder: "胆囊"
        case .pancreas: "胰腺"
        case .kidneys: "肾脏"
        case .smallIntestine: "小肠"
        case .largeIntestine: "大肠"
        }
    }
    var explanation: (process: String, result: String) {
        switch self {
        case .mouth: ("咀嚼使食物变小，唾液中的酶开始分解淀粉。", "形成易于吞咽的食团。")
        case .esophagus: ("肌肉有节律地收缩，将吞下的食团推向胃。", "食团进入胃，开始下一阶段。")
        case .stomach: ("胃的收缩混合食物与胃液，胃酸和酶参与蛋白质消化。", "形成食糜，逐步进入小肠。")
        case .duodenum: ("胃排出的食糜与胆汁、胰液混合，继续消化。", "食物成分进一步分解，向后续小肠移动。")
        case .liver: ("制造胆汁，并对肠道吸收后送来的营养物质进行加工、储存和分配。", "胆汁帮助脂肪消化；营养物质供身体使用。")
        case .gallbladder: ("储存肝脏制造的胆汁，进食时将胆汁释放到小肠。", "胆汁帮助脂肪消化。")
        case .pancreas: ("胰液中的酶帮助小肠消化；胰岛素等激素通过血液参与调节。", "帮助分解食物，并参与血糖调节。食团不进入胰腺。")
        case .kidneys: ("过滤血液，回收身体需要的物质，并调节水与电解质的平衡。", "多余水分和代谢废物随尿液排出。")
        case .smallIntestine: ("继续消化食物，并经肠壁吸收大部分营养物质。", "糖、氨基酸等进入血液，部分脂肪经淋巴运输。")
        case .largeIntestine: ("吸收水分，肠道菌群参与剩余部分物质的分解。", "剩余内容物逐渐形成粪便，进入直肠。")
        }
    }
    var source: URL {
        URL(string: self == .kidneys
            ? "https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work"
            : "https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works")!
    }
}

struct AnatomyAsset: Identifiable {
    let part: AnatomyPart
    let data: String
    let colorHex: String
    let strokeWidth: CGFloat
    let anchor: CGPoint
    var id: AnatomyPart { part }
    let path: Path

    init(_ part: AnatomyPart, _ data: String, _ colorHex: String,
         stroke: CGFloat = 0, anchor: CGPoint) {
        self.part = part; self.data = data; self.colorHex = colorHex
        self.strokeWidth = stroke; self.anchor = anchor
        let centerline = AnatomyArtwork.parse(data)
        self.path = stroke == 0 ? centerline : centerline.strokedPath(
            StrokeStyle(lineWidth: stroke, lineCap: .round, lineJoin: .round))
    }
    var color: Color { AnatomyArtwork.color(colorHex) }
}

enum AnatomyArtwork {
    static let size = CGSize(width: 320, height: 440)
    /// Cropped lower-face/neck context only. No scalp, eyes, arms or thighs in the live canvas.
    /// Round the visible back of the head into the nape; keep the mouth registration fixed.
    static let cutawayData = "M 123 48 C 123 64 129 77 139 84 C 147 90 144 101 140 105 C 132 113 114 112 101 116 M 194 56 L 195 61 L 188 64 L 194 68 Q 194 78 184 82 L 177 83 C 177 91 175 100 178 105 C 186 112 208 112 223 116"
    // Rounded adult cranial vault with a horizontal tangent at the crown seam.
    // Soften the occiput-to-neck transition without moving the mouth or organ registration.
    static let bodyData = "M 158 12 C 177 12 190 25 190 40 C 190 45 194 48 199 52 Q 201 55 194 56 L 195 61 L 188 64 L 194 68 Q 194 78 184 82 L 177 83 C 177 91 175 100 178 105 C 190 115 213 113 232 126 C 248 139 251 166 255 190 L 261 228 Q 268 245 271 265 L 280 303 L 289 320 L 301 331 Q 304 336 300 337 L 290 330 L 298 346 Q 299 351 295 351 L 285 337 L 290 355 Q 290 360 286 358 L 278 341 L 281 359 Q 280 364 276 360 L 270 343 L 270 356 Q 268 361 265 356 L 260 335 L 261 314 C 248 292 239 267 237 249 L 230 217 L 227 186 C 223 210 222 228 224 247 L 222 274 C 224 296 235 320 237 341 C 239 370 236 408 231 434 L 175 434 L 166 393 Q 160 383 154 393 L 145 434 L 89 434 C 84 408 81 370 83 341 C 85 320 96 296 98 274 L 96 247 C 98 228 97 210 93 186 L 90 217 L 83 249 C 81 267 72 292 59 314 L 60 335 L 55 356 Q 52 361 50 356 L 50 343 L 44 360 Q 40 364 39 359 L 42 341 L 34 358 Q 30 360 30 355 L 35 337 L 25 351 Q 21 351 22 346 L 30 330 L 20 337 Q 16 336 19 331 L 31 320 L 40 303 L 49 265 Q 52 245 59 228 L 65 190 C 69 166 72 139 88 126 C 107 113 128 116 140 105 C 144 101 147 90 139 84 C 129 77 123 65 123 49 C 123 28 137 12 158 12 Z"
    static let bodyPath = parse(bodyData)
    // SwiftUI Path.contains drops the y=217 scanline on this concave silhouette (iOS 26.5).
    // CoreGraphics uses the rendered path's winding rule correctly, including that scanline.
    static func containsBody(_ point: CGPoint) -> Bool { bodyPath.cgPath.contains(point) }
    static let faceData = "M 181 42 Q 185 40 188 42 M 185 46 L 188 46 M 148 47 C 137 39 134 59 145 63 M 143 48 Q 150 52 142 57 M 172 77 Q 181 80 187 76"
    static let bodyDetailsData = "M 140 105 Q 150 115 155 125 M 178 105 Q 168 115 164 125 M 101 127 Q 126 124 155 131 M 164 131 Q 192 124 218 127 M 92 151 Q 101 165 93 186 M 228 151 Q 219 165 227 186 M 159 137 L 159 157 M 61 229 Q 69 237 80 232 M 259 229 Q 251 237 240 232 M 43 305 L 56 311 M 277 305 L 264 311 M 91 344 Q 117 351 146 381 M 229 344 Q 203 351 174 381"
    static let mouthData = "M 194 61 Q 180 59 174 64 Q 170 67 174 69 Q 183 72 194 68 L 188 64 Z"
    static let esophagusData = "M 174 69 Q 159 71 159 89 L 159 143 Q 159 162 172 176"
    static let duodenumData = "M 156 222 Q 137 222 137 235 Q 137 252 154 252 L 171 252 Q 192 252 192 272"
    // Three horizontal runs, four principal 90° corners. Terminal connector reaches cecum.
    static let smallData = "M 192 272 L 137 272 Q 128 272 128 281 L 128 290 Q 128 299 137 299 L 185 299 Q 194 299 194 308 L 194 316 Q 194 325 185 325 L 110 325"
    static let largeData = "M 110 325 L 110 264 Q 110 247 127 247 L 197 247 Q 214 247 214 264 L 214 326 Q 214 347 192 347 L 177 347 Q 160 347 160 364 L 160 377"
    static let stomachRouteData = "M 172 176 C 189 174 206 186 203 201 C 201 223 176 230 156 222"

    /// Back to front. Each kidney is entirely inside the trunk, behind digestive layers.
    static let assets: [AnatomyAsset] = [
        // Shift both kidneys down 14 registration units; preserve shape, left/right offset and depth.
        AnatomyAsset(.kidneys, "M 126 216 C 112 210 107 225 110 240 C 112 255 128 261 136 250 Q 140 244 132 239 Q 126 235 133 230 Q 139 223 126 216 Z M 200 210 C 214 204 220 220 216 235 C 213 250 199 254 191 244 Q 187 237 195 233 Q 201 229 194 224 Q 187 217 200 210 Z", "759CEB", anchor: CGPoint(x: 208, y: 228)),
        AnatomyAsset(.pancreas, "M 143 231 Q 145 222 156 226 C 170 230 186 225 201 220 Q 209 218 208 224 C 199 237 169 244 151 241 Q 139 241 143 231 Z", "EBC06F", anchor: CGPoint(x: 170, y: 235)),
        AnatomyAsset(.esophagus, esophagusData, "CC8EAA", stroke: 7, anchor: CGPoint(x: 159, y: 130)),
        AnatomyAsset(.duodenum, duodenumData, "EBA781", stroke: 9, anchor: CGPoint(x: 137, y: 236)),
        AnatomyAsset(.stomach, "M 171 170 C 176 162 192 165 201 175 C 217 190 216 211 201 224 C 188 235 166 233 153 226 Q 149 220 157 217 C 172 218 181 209 179 199 Q 168 187 171 170 Z", "EE9F98", anchor: CGPoint(x: 195, y: 195)),
        AnatomyAsset(.liver, "M 98 182 C 111 165 138 162 157 169 Q 168 173 174 182 C 162 198 143 205 123 210 Q 109 217 99 219 C 91 209 90 194 98 182 Z", "CB7D78", anchor: CGPoint(x: 123, y: 188)),
        AnatomyAsset(.gallbladder, "M 133 201 Q 143 199 144 208 C 144 218 137 226 133 221 Q 127 217 130 209 Z", "B8CB70", anchor: CGPoint(x: 137, y: 215)),
        AnatomyAsset(.smallIntestine, smallData, "93D6C5", stroke: 12, anchor: CGPoint(x: 155, y: 299)),
        AnatomyAsset(.largeIntestine, largeData, "56A9B1", stroke: 17, anchor: CGPoint(x: 214, y: 291)),
        AnatomyAsset(.mouth, mouthData, "E5A0B2", anchor: CGPoint(x: 182, y: 66))
    ]

    static func asset(_ part: AnatomyPart) -> AnatomyAsset { assets.first { $0.part == part }! }

    /// Hit the actual silhouette, with a small tolerance for thin tubes. No rectangular colon hit area.
    static func hitTest(_ point: CGPoint) -> AnatomyPart? {
        for asset in assets.reversed() where asset.path.cgPath.contains(point) { return asset.part }
        for asset in assets.reversed() {
            if asset.path.strokedPath(StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)).contains(point) {
                return asset.part
            }
        }
        return nil
    }

    static func color(_ hex: String) -> Color {
        let value = UInt32(hex, radix: 16) ?? 0
        return Color(red: Double(value >> 16 & 255) / 255,
                     green: Double(value >> 8 & 255) / 255, blue: Double(value & 255) / 255)
    }

    /// Our authored SVG command subset. Shared geometry is the source for both rendering and export.
    static func parse(_ data: String) -> Path {
        let tokens = data.split(separator: " ").map(String.init)
        var i = 0
        func point() -> CGPoint {
            let p = CGPoint(x: Double(tokens[i])!, y: Double(tokens[i + 1])!)
            i += 2; return p
        }
        var path = Path()
        while i < tokens.count {
            let op = tokens[i]; i += 1
            switch op {
            case "M": path.move(to: point())
            case "L": path.addLine(to: point())
            case "Q": let c = point(); path.addQuadCurve(to: point(), control: c)
            case "C": let a = point(); let b = point(); path.addCurve(to: point(), control1: a, control2: b)
            case "Z": path.closeSubpath()
            default: preconditionFailure("Unsupported artwork command: \(op)")
            }
        }
        return path
    }

    /// Arc-length sampled once, keeping food particles on the exact rendered centerlines.
    struct Route {
        let points: [CGPoint]
        let lengths: [CGFloat]
        init(_ paths: [String]) {
            var points: [CGPoint] = []
            for data in paths {
                var cursor = CGPoint.zero
                parse(data).cgPath.applyWithBlock { elementPointer in
                    let e = elementPointer.pointee
                    switch e.type {
                    case .moveToPoint: cursor = e.points[0]; points.append(cursor)
                    case .addLineToPoint: cursor = e.points[0]; points.append(cursor)
                    case .addQuadCurveToPoint:
                        let start = cursor, c = e.points[0], end = e.points[1]
                        for j in 1...24 {
                            let t = CGFloat(j) / 24, u = 1 - t
                            points.append(CGPoint(x: u*u*start.x + 2*u*t*c.x + t*t*end.x,
                                                  y: u*u*start.y + 2*u*t*c.y + t*t*end.y))
                        }; cursor = end
                    case .addCurveToPoint:
                        let start = cursor, a = e.points[0], b = e.points[1], end = e.points[2]
                        for j in 1...32 {
                            let t = CGFloat(j) / 32, u = 1 - t
                            points.append(CGPoint(x: u*u*u*start.x + 3*u*u*t*a.x + 3*u*t*t*b.x + t*t*t*end.x,
                                                  y: u*u*u*start.y + 3*u*u*t*a.y + 3*u*t*t*b.y + t*t*t*end.y))
                        }; cursor = end
                    default: break
                    }
                }
            }
            var distances: [CGFloat] = [0]
            for index in 1..<points.count {
                distances.append(distances.last! + hypot(points[index].x - points[index-1].x,
                                                         points[index].y - points[index-1].y))
            }
            self.points = points; self.lengths = distances
        }
        func point(at progress: Double) -> CGPoint {
            let distance = CGFloat(min(1, max(0, progress))) * lengths.last!
            guard let i = lengths.firstIndex(where: { $0 > distance }), i > 0 else { return points.last! }
            let t = (distance - lengths[i-1]) / max(0.001, lengths[i] - lengths[i-1])
            return CGPoint(x: points[i-1].x + (points[i].x - points[i-1].x) * t,
                           y: points[i-1].y + (points[i].y - points[i-1].y) * t)
        }
    }
    static let swallowRoute = Route(["M 208 64 L 190 65 L 174 69", esophagusData])
    static let digestionRoute = Route([stomachRouteData, duodenumData, smallData, largeData])
}
