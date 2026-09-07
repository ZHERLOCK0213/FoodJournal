import XCTest
@testable import FoodJourney

@MainActor
final class AnatomyCalloutLayoutTests: XCTestCase {
    func testAllOrgansHaveDistinctNonOverlappingCards() {
        XCTAssertEqual(Set(AnatomyCalloutLayout.left + AnatomyCalloutLayout.right), Set(AnatomyPart.allCases))
        for width in [375.0, 402.0, 440.0] {
            let layout = AnatomyCalloutLayout(size: CGSize(width: width, height: 424))
            let bounds = CGRect(origin: .zero, size: layout.size)
            for part in AnatomyPart.allCases {
                let card = layout.cardRect(part)
                XCTAssertTrue(bounds.contains(card))
                for other in AnatomyPart.allCases where other != part {
                    XCTAssertFalse(card.intersects(layout.cardRect(other)))
                }
                for asset in AnatomyArtwork.assets {
                    XCTAssertFalse(card.intersects(asset.path.applying(layout.transform).boundingRect))
                }
            }
        }
    }

    func testLeadersAreOrthogonalAndEndInsideTheirOwnOrgan() {
        let layout = AnatomyCalloutLayout(size: CGSize(width: 402, height: 424))
        for part in AnatomyPart.allCases {
            let points = layout.leaderPoints(part)
            for i in 1..<points.count {
                XCTAssertTrue(points[i].x == points[i-1].x || points[i].y == points[i-1].y)
            }
            let source = points.last!.applying(layout.transform.inverted())
            XCTAssertTrue(AnatomyArtwork.asset(part).path.cgPath.contains(source), "Incorrect leader endpoint: \(part)")
        }
    }

    func testCropKeepsWholeTractAndHitTestingRoundTrips() {
        let layout = AnatomyCalloutLayout(size: CGSize(width: 402, height: 424))
        for asset in AnatomyArtwork.assets {
            XCTAssertTrue(CGRect(origin: .zero, size: layout.size).contains(asset.path.applying(layout.transform).boundingRect))
            let p = asset.anchor.applying(layout.transform).applying(layout.transform.inverted())
            XCTAssertEqual(p.x, asset.anchor.x, accuracy: 0.001)
            XCTAssertEqual(p.y, asset.anchor.y, accuracy: 0.001)
        }
    }

    func testCalloutNumbersAreInputAmountsNotInventedOutput() {
        let food = FoodDatabase.allFoods.first { $0.name == "鸡胸肉" }!
        let a = MealDigestionJourney(item: FoodItem(food: food, grams: 100))
        let b = MealDigestionJourney(item: FoodItem(food: food, grams: 200))
        XCTAssertTrue(a.calloutData(for: .stomach).contains("31.0g"))
        XCTAssertTrue(b.calloutData(for: .stomach).contains("62.0g"))
        XCTAssertTrue(b.calloutData(for: .largeIntestine).contains("0.0g"))
        for part: AnatomyPart in [.liver, .pancreas, .kidneys] {
            XCTAssertTrue(b.calloutData(for: part).contains("未估算"))
        }
    }
}
