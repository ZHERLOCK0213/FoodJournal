import XCTest
@testable import FoodJourney

@MainActor
final class AnatomyArtworkTests: XCTestCase {
    func testPosteriorKidneysStayWithinAdultBody() {
        let kidneys = AnatomyArtwork.asset(.kidneys).path
        let bounds = kidneys.boundingRect
        for x in stride(from: floor(bounds.minX), through: ceil(bounds.maxX), by: 1) {
            for y in stride(from: floor(bounds.minY), through: ceil(bounds.maxY), by: 1) {
                let p = CGPoint(x: x, y: y)
                if kidneys.cgPath.contains(p) { XCTAssertTrue(AnatomyArtwork.containsBody(p), "Kidney outside body at \(p)") }
            }
        }
    }

    func testLoweredKidneysKeepAnchorInsideAndStayBehindOtherOrgans() {
        let kidneys = AnatomyArtwork.asset(.kidneys)
        XCTAssertEqual(kidneys.anchor, CGPoint(x: 208, y: 228))
        XCTAssertTrue(kidneys.path.cgPath.contains(kidneys.anchor))
        XCTAssertGreaterThan(kidneys.path.boundingRect.minY, 200)
        XCTAssertLessThan(kidneys.path.boundingRect.maxY, 270)
        XCTAssertEqual(AnatomyArtwork.assets.first?.part, .kidneys)
    }

    func testBodyContainmentAtConcaveArmVertexScanline() {
        for y in [216.999, 217, 217.001] {
            XCTAssertTrue(AnatomyArtwork.containsBody(CGPoint(x: 120, y: y)))
            XCTAssertTrue(AnatomyArtwork.containsBody(CGPoint(x: 205, y: y)))
            XCTAssertFalse(AnatomyArtwork.containsBody(CGPoint(x: 15, y: y)))
        }
    }

    func testIntestinalHitTestingDoesNotUseOuterBoundingRectangle() {
        XCTAssertEqual(AnatomyArtwork.hitTest(CGPoint(x: 155, y: 299)), .smallIntestine)
        XCTAssertEqual(AnatomyArtwork.hitTest(CGPoint(x: 214, y: 291)), .largeIntestine)
        XCTAssertNil(AnatomyArtwork.hitTest(CGPoint(x: 161, y: 287)))
    }

    func testSwallowingJoinsDigestionAndParticlesStayInsideDigestiveLayers() {
        let end = AnatomyArtwork.swallowRoute.point(at: 1)
        let start = AnatomyArtwork.digestionRoute.point(at: 0)
        XCTAssertEqual(end.x, start.x, accuracy: 0.01)
        XCTAssertEqual(end.y, start.y, accuracy: 0.01)
        let tract: [AnatomyPart] = [.stomach, .duodenum, .smallIntestine, .largeIntestine]
        for i in 0...300 {
            let point = AnatomyArtwork.digestionRoute.point(at: Double(i) / 300)
            XCTAssertTrue(tract.contains { AnatomyArtwork.asset($0).path.contains(point) }, "Particle outside artwork at \(point)")
        }
    }
}
