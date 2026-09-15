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

    private func selectFood(_ name: String, id: String? = nil) {
        let catalogID = id ?? name
        let quick = app.buttons["quick-food-\(catalogID)"]
        if quick.exists { quick.tap(); return }
        app.buttons["open-food-catalog"].tap()
        let search = app.searchFields["搜索食物"]
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap()
        search.typeText(name)
        let result = app.buttons["catalog-select-\(catalogID)"]
        XCTAssertTrue(result.waitForExistence(timeout: 3))
        result.tap()
    }

    private func reportElement(_ id: String) -> XCUIElement {
        let element = app.descendants(matching: .any).matching(identifier: id).firstMatch
        for _ in 0..<10 {
            if element.exists && element.isHittable { break }
            app.scrollViews["meal-report-scroll"].swipeUp()
        }
        return element
    }

    func testRicePreviewCompletesAndOpensReport() throws {
        XCTAssertTrue(app.staticTexts["消化预演"].waitForExistence(timeout: 3))

        let riceChip = app.buttons["quick-food-米饭"]
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

        XCTAssertTrue(app.staticTexts["本餐食物成分"].waitForExistence(timeout: 3))
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
        selectFood("鸡胸肉")
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
        XCTAssertEqual(app.buttons["organ-callout-pancreas"].value as? String, "消化酶 · 胰岛素")
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

    func testPorkAndBunReportUpdatesAndExplainsBothPancreasRoles() throws {
        selectFood("红烧肉")
        app.buttons["eat-button"].tap()
        waitForCanvasResults()
        app.buttons["report-button"].tap()
        let carbs = app.descendants(matching: .any).matching(identifier: "report-total-carbs").firstMatch
        XCTAssertTrue(carbs.waitForExistence(timeout: 3))
        XCTAssertEqual(carbs.value as? String, "3.0g")
        app.tabBars.buttons["消化预演"].tap()
        selectFood("馒头")
        app.buttons["eat-button"].tap()
        waitForCanvasResults()
        app.buttons["report-button"].tap()
        let updatedCarbs = app.descendants(matching: .any).matching(identifier: "report-total-carbs").firstMatch
        XCTAssertTrue(updatedCarbs.waitForExistence(timeout: 3))
        XCTAssertEqual(updatedCarbs.value as? String, "50.0g")
        XCTAssertFalse(app.staticTexts["内脏使用度"].exists)
        XCTAssertFalse(app.staticTexts["实际产 ATP"].exists)
        let report = XCTAttachment(screenshot: app.screenshot())
        report.name = "红烧肉100g加馒头100g整餐报告"; report.lifetime = .keepAlways; add(report)
        let glucose = app.buttons["report-pancreas-glucose"]
        reportElement("report-pancreas-toggle").tap()
        _ = reportElement("report-pancreas-glucose")
        glucose.tap()
        XCTAssertTrue(app.buttons["pancreas-role-glucose"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["胰岛素参与餐后调节"].exists)
        app.buttons["pancreas-role-digestion"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["pancreas-step-0"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["pancreas-step-1"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["pancreas-step-2"].exists)
        XCTAssertTrue(app.staticTexts["pancreas-static-steps-note"].exists)
        XCTAssertFalse(app.buttons["pancreas-play"].exists)
        let thirdStep = app.descendants(matching: .any)["pancreas-step-2"]
        if !thirdStep.isHittable { app.scrollViews["pancreas-process-scroll"].swipeUp() }
        let process = XCTAttachment(screenshot: app.screenshot())
        process.name = "胰腺帮助消化三步讲解"; process.lifetime = .keepAlways; add(process)
        app.buttons["close-pancreas-process"].tap()
        XCTAssertTrue(app.scrollViews["meal-report-scroll"].waitForExistence(timeout: 3))
    }

    func testUrateFocusShowsChickenKidneyEducationAndClearsWhenFocusOrMealChanges() throws {
        app.tabBars.buttons["我"].tap()
        let urateFocus = app.buttons["focus-purine"]
        XCTAssertTrue(urateFocus.waitForExistence(timeout: 3))
        urateFocus.tap()

        app.tabBars.buttons["消化预演"].tap()
        selectFood("鸡胸肉")
        app.buttons["eat-button"].tap()
        waitForCanvasResults()

        let kidney = app.buttons["organ-callout-kidneys"]
        XCTAssertTrue((kidney.value as? String ?? "").contains("嘌呤与尿酸"))
        XCTAssertFalse(app.buttons["close-urate-education"].exists, "尿酸详情不应自动弹出")
        kidney.tap()
        XCTAssertTrue(app.buttons["open-urate-education"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["urate-kidney-hint"].exists)
        app.buttons["open-urate-education"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["urate-education-card"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["肉类份量提示"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '368.6mg'")).firstMatch.exists)
        let liveDetail = XCTAttachment(screenshot: app.screenshot())
        liveDetail.name = "尿酸关注鸡胸肉肾脏科普"; liveDetail.lifetime = .keepAlways; add(liveDetail)
        app.buttons["close-urate-education"].tap()

        app.buttons["report-button"].tap()
        reportElement("report-urate-toggle").tap()
        XCTAssertTrue(app.descendants(matching: .any)["urate-education-card"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["肉类份量提示"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '368.6mg'")).firstMatch.exists)
        let report = XCTAttachment(screenshot: app.screenshot())
        report.name = "尿酸关注鸡胸肉报告卡"; report.lifetime = .keepAlways; add(report)

        app.tabBars.buttons["我"].tap()
        app.buttons["热量"].tap()
        app.tabBars.buttons["代谢报告"].tap()
        expectation(for: NSPredicate(format: "exists == false"),
                    evaluatedWith: app.descendants(matching: .any)["urate-education-card"])
        waitForExpectations(timeout: 3)

        app.tabBars.buttons["我"].tap()
        urateFocus.tap()
        app.tabBars.buttons["消化预演"].tap()
        XCTAssertTrue((kidney.value as? String ?? "").contains("嘌呤与尿酸"))
        app.buttons["clear-organ-focus"].tap()
        app.buttons["重置饮食"].tap()
        app.alerts["重置饮食"].buttons["重置"].tap()
        XCTAssertEqual(kidney.value as? String, "等待预演")
        XCTAssertFalse(app.buttons["open-urate-education"].exists)
    }

    func testSearchableCatalogShowsReferenceSourceAndRecordsNewFood() throws {
        app.buttons["open-food-catalog"].tap()
        XCTAssertTrue(app.navigationBars["全部食物"].waitForExistence(timeout: 3))
        let search = app.searchFields["搜索食物"]
        XCTAssertTrue(search.waitForExistence(timeout: 2))
        search.tap()
        search.typeText("汉堡")

        let burger = app.buttons["catalog-select-beef-burger-reference"]
        XCTAssertTrue(burger.waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["汉堡详情"].exists)
        XCTAssertFalse(app.staticTexts["来源链接待补标"].exists)
        let catalog = XCTAttachment(screenshot: app.screenshot())
        catalog.name = "可搜索食物目录与汉堡参考来源"; catalog.lifetime = .keepAlways; add(catalog)
        burger.tap()

        let eat = app.buttons["eat-button"]
        XCTAssertTrue(eat.isEnabled)
        XCTAssertTrue(eat.label.contains("汉堡"))
        eat.tap()
        waitForCanvasResults()
        app.buttons["open-eaten-items"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["eaten-item-beef-burger-reference"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["现有条目"].exists)
        app.buttons["完成"].tap()
        app.buttons["report-button"].tap()
        let sourceToggle = reportElement("report-source-toggle-beef-burger-reference")
        XCTAssertTrue(sourceToggle.exists)
        sourceToggle.tap()
        XCTAssertTrue(app.staticTexts["白面包、牛肉饼和沙拉，不含芝士。"].exists)
        XCTAssertTrue(reportElement("report-composition-source-cfs").exists)
    }

    func testRepeatedDumplingsMergeIntoOne1000gMatrixRowAnd500gIsSelectable() throws {
        app.buttons["open-food-catalog"].tap()
        let search = app.searchFields["搜索食物"]
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap()
        search.typeText("水饺")
        let dumplings = app.buttons["catalog-select-pork-vegetable-dumplings"]
        XCTAssertTrue(dumplings.waitForExistence(timeout: 3))
        dumplings.tap()

        app.buttons["portion-picker"].tap()
        let fiveHundred = app.buttons["portion-500"]
        XCTAssertTrue(fiveHundred.waitForExistence(timeout: 2))
        fiveHundred.tap()
        XCTAssertEqual(app.buttons["portion-picker"].value as? String, "500g")

        app.buttons["eat-button"].tap()
        waitForCanvasResults()
        app.buttons["eat-button"].tap()
        waitForCanvasResults()
        app.buttons["report-button"].tap()

        let row = app.staticTexts["report-food-row-pork-vegetable-dumplings"]
        XCTAssertTrue(row.waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["report-merged-count-pork-vegetable-dumplings"].label, "合并 2 份")
        let primary = app.descendants(matching: .any)["report-primary-pork-vegetable-dumplings"]
        XCTAssertTrue(primary.exists)
        XCTAssertTrue((primary.value as? String ?? "").contains("克重 1,000.0g"))
        XCTAssertEqual(app.staticTexts.matching(identifier: "report-food-row-pork-vegetable-dumplings").count, 1)
        for _ in 0..<3 where !primary.isHittable { app.scrollViews["meal-report-scroll"].swipeUp() }
        let matrix = XCTAttachment(screenshot: app.screenshot())
        matrix.name = "水饺两份500g合并为1000g矩阵"; matrix.lifetime = .keepAlways; add(matrix)
    }

    func testPendingPublicFoodIsHiddenFromSelection() throws {
        app.buttons["open-food-catalog"].tap()
        let search = app.searchFields["搜索食物"]
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap()
        search.typeText("新疆炒米粉")

        let pending = app.buttons["catalog-select-xinjiang-fried-rice-noodles"]
        XCTAssertTrue(app.staticTexts["没有匹配的食物"].waitForExistence(timeout: 3))
        XCTAssertFalse(pending.exists)
        XCTAssertTrue(app.buttons["new-personal-food"].exists)
    }

    func testMyFoodCreationLeavesOptionalNutrientsUnknown() throws {
        app.tabBars.buttons["我"].tap()
        XCTAssertFalse(app.switches["提供已知情况"].exists)
        XCTAssertFalse(app.buttons["反流与进食"].exists)
        app.buttons["my-foods"].tap()
        app.buttons["new-personal-food"].tap()
        let name = app.textFields["personal-food-name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap(); name.typeText("My rice")
        for (id, value) in [("carbs", "25"), ("protein", "3"), ("fat", "1"), ("calories", "121")] {
            let field = app.textFields["personal-food-\(id)"]
            if !field.isHittable { app.swipeUp() }
            field.tap(); field.typeText(value)
        }
        app.buttons["save-personal-food"].tap()
        let created = app.buttons.matching(NSPredicate(format: "label CONTAINS 'My rice'")).firstMatch
        XCTAssertTrue(created.waitForExistence(timeout: 3))
        created.tap()
        XCTAssertTrue(app.buttons["edit-personal-food"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label == '未提供'")).firstMatch.exists)
    }
}
