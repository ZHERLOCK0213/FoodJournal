import XCTest

final class FoodJourneyUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    private func waitForCanvasResults() {
        let bubble = app.buttons["organ-callout-stomach"]
        expectation(for: NSPredicate(format: "value CONTAINS '本份蛋白'"), evaluatedWith: bubble)
        waitForExpectations(timeout: 12)
        XCTAssertFalse(app.buttons["close-journey-summary"].exists, "Completion must not cover the on-canvas bubbles")
    }

    func testRicePreviewCompletesAndOpensReport() throws {
        XCTAssertTrue(app.staticTexts["消化预演"].waitForExistence(timeout: 3))

        let riceChip = app.buttons["food-chip-米饭"]
        XCTAssertTrue(riceChip.waitForExistence(timeout: 3))
        riceChip.tap()

        let eatButton = app.buttons["eat-button"]
        XCTAssertTrue(eatButton.isEnabled)
        eatButton.tap()

        waitForCanvasResults()
        app.buttons["open-journey-summary"].tap()
        let summaryClose = app.buttons["close-journey-summary"]
        XCTAssertTrue(summaryClose.waitForExistence(timeout: 3))
        summaryClose.tap()
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: summaryClose)
        waitForExpectations(timeout: 5)

        let reportButton = app.buttons["report-button"]
        expectation(for: NSPredicate(format: "isEnabled == true AND isHittable == true"), evaluatedWith: reportButton)
        waitForExpectations(timeout: 7)
        reportButton.tap()

        XCTAssertTrue(app.staticTexts["累积代谢"].waitForExistence(timeout: 3))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "米饭代谢报告"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testOrganFocusSwitchAndDismiss() throws {
        let stomach = app.buttons["organ-callout-stomach"]
        XCTAssertTrue(stomach.waitForExistence(timeout: 3))
        stomach.tap()
        XCTAssertTrue(app.scrollViews["organ-detail-stomach"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.otherElements["anatomy-canvas"].value as? String, "胃")
        let focus = XCTAttachment(screenshot: app.screenshot())
        focus.name = "胃聚焦与其他器官淡出"; focus.lifetime = .keepAlways; add(focus)

        let kidneys = app.buttons["organ-callout-kidneys"]
        XCTAssertTrue(kidneys.isHittable)
        kidneys.tap()
        XCTAssertTrue(app.scrollViews["organ-detail-kidneys"].waitForExistence(timeout: 2))
        let renal = XCTAttachment(screenshot: app.screenshot())
        renal.name = "后层双肾聚焦"; renal.lifetime = .keepAlways; add(renal)
        kidneys.tap()
        XCTAssertEqual(app.otherElements["anatomy-canvas"].value as? String, "全部器官")

        let canvas = app.otherElements["anatomy-canvas"]
        func tapArtwork(_ x: CGFloat, _ y: CGFloat) {
            let cardWidth = min(110, max(86, canvas.frame.width * 0.24))
            let scale = min(max(100, canvas.frame.width - 2 * (cardWidth + 23)) / 146,
                            (canvas.frame.height - 42) / 340)
            let offset = CGVector(dx: canvas.frame.width / 2 + (x - 159) * scale,
                                  dy: canvas.frame.height / 2 + (y - 218) * scale)
            canvas.coordinate(withNormalizedOffset: .zero).withOffset(offset).tap()
        }
        tapArtwork(155, 299)
        XCTAssertEqual(canvas.value as? String, "小肠")
        tapArtwork(155, 299)
        XCTAssertEqual(canvas.value as? String, "全部器官")
        tapArtwork(123, 188)
        XCTAssertEqual(canvas.value as? String, "肝脏")
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98)).tap()
        XCTAssertEqual(canvas.value as? String, "全部器官")
        let full = XCTAttachment(screenshot: app.screenshot())
        full.name = "中央消化道与左右气泡全貌"; full.lifetime = .keepAlways; add(full)
    }

    func testChicken200WithStomachFocusShowsMealSpecificOutcomes() throws {
        app.buttons["organ-callout-stomach"].tap()
        app.buttons["food-chip-鸡胸肉"].tap()
        app.buttons["portion-picker"].tap()
        app.buttons["portion-200"].tap()
        XCTAssertEqual(app.buttons["portion-picker"].value as? String, "200g")
        app.buttons["eat-button"].tap()
        // Screen capture does not wait for the animated app to become idle.
        Thread.sleep(forTimeInterval: 3.0)
        let inFlight = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        inFlight.name = "聚焦胃时食物仍沿下游流动"; inFlight.lifetime = .keepAlways; add(inFlight)
        waitForCanvasResults()
        XCTAssertTrue((app.buttons["organ-callout-stomach"].value as? String ?? "").contains("62.0g"))
        XCTAssertEqual(app.buttons["organ-callout-pancreas"].value as? String, "分泌量未估算")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'organ-callout-' ")).count, 10)
        let bubbles = XCTAttachment(screenshot: app.screenshot())
        bubbles.name = "鸡胸肉200g画布两侧数据气泡"; bubbles.lifetime = .keepAlways; add(bubbles)
        app.buttons["organ-callout-stomach"].tap()
        app.buttons["open-journey-summary"].tap()
        XCTAssertTrue(app.buttons["close-journey-summary"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["journey-meal-title"].label, "鸡胸肉 · 200g")
        let list = app.scrollViews["journey-summary-list"]
        // Expand the sheet and inspect the protein-specific downstream collaboration result.
        list.swipeUp()
        let pancreas = app.buttons["result-focus-pancreas"]
        for _ in 0..<12 {
            if pancreas.exists && pancreas.isHittable { break }
            list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
                .press(forDuration: 0.1, thenDragTo: list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)))
        }
        if !pancreas.exists {
            let diagnostic = XCTAttachment(string: app.debugDescription)
            diagnostic.name = "小结无障碍树"; diagnostic.lifetime = .keepAlways; add(diagnostic)
        }
        XCTAssertTrue(pancreas.isHittable)
        let summary = XCTAttachment(screenshot: app.screenshot())
        summary.name = "鸡胸肉200g的胰腺参与小结"; summary.lifetime = .keepAlways; add(summary)
        pancreas.tap()
        XCTAssertEqual(app.otherElements["anatomy-canvas"].value as? String, "胰腺")
        XCTAssertTrue(app.scrollViews["organ-detail-pancreas"].exists)
        let focus = XCTAttachment(screenshot: app.screenshot())
        focus.name = "鸡胸肉结果定位到胰腺"; focus.lifetime = .keepAlways; add(focus)
        app.buttons["clear-organ-focus"].tap()
        app.buttons["replay-journey"].tap()
        waitForCanvasResults()
        XCTAssertTrue((app.buttons["organ-callout-stomach"].value as? String ?? "").contains("62.0g"))
    }
}
