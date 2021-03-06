/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let website1: [String: String] = ["url": "www.mozilla.org", "label": "Internet for people, not profit — Mozilla", "value": "mozilla.org"]
let website2 = "yahoo.com"

class ToolbarTests: BaseTestCase {
    var navigator: Navigator!
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        navigator = createScreenGraph(app).navigator(self)
    }

    override func tearDown() {
        super.tearDown()
    }

    /**
     * Tests landscape page navigation enablement with the URL bar with tab switching.
     */
    func testLandscapeNavigationWithTabSwitch() {
        XCUIDevice.shared().orientation = .landscapeLeft

        // Check that url field is empty and it shows a placeholder
        navigator.goto(NewTabScreen)
        let urlPlaceholder = "Search or enter address"
        XCTAssert(app.textFields["url"].exists)
        let defaultValuePlaceholder = app.textFields["url"].placeholderValue!

        // Check the url placeholder text and that the back and forward buttons are disabled
        XCTAssertTrue(urlPlaceholder == defaultValuePlaceholder, "The placeholder does not show the correct value")
        XCTAssertFalse(app.buttons["URLBarView.backButton"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)
        XCTAssertFalse(app.buttons["Reload"].isEnabled)

        // Navigate to two pages and press back once so that all buttons are enabled in landscape mode.
        navigator.openURL(urlString: website1["url"]!)
        waitForValueContains(app.textFields["url"], value: website1["value"]!)

        XCTAssertTrue(app.buttons["URLBarView.backButton"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)
        XCTAssertTrue(app.buttons["Reload"].isEnabled)

        navigator.openURL(urlString: website2)
        waitForValueContains(app.textFields["url"], value: website2)
        XCTAssertTrue(app.buttons["URLBarView.backButton"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)

        app.buttons["URLBarView.backButton"].tap()
        waitForValueContains(app.textFields["url"], value: website1["value"]!)
        XCTAssertTrue(app.buttons["URLBarView.backButton"].isEnabled)
        XCTAssertTrue(app.buttons["Forward"].isEnabled)

        // Open new tab and then go back to previous tab to test navigation buttons.
        navigator.goto(NewTabScreen)

        navigator.goto(TabTray)
        waitforExistence(app.collectionViews.cells[website1["label"]!])
        app.collectionViews.cells[website1["label"]!].tap()
        waitForValueContains(app.textFields["url"], value: website1["value"]!)

        // Test to see if all the buttons are enabled then close tab.
        XCTAssertTrue(app.buttons["URLBarView.backButton"].isEnabled)
        XCTAssertTrue(app.buttons["Forward"].isEnabled)

        navigator.nowAt(BrowserTab)
        navigator.goto(TabTray)
        waitforExistence(app.collectionViews.cells[website1["label"]!])
        app.collectionViews.cells[website1["label"]!].swipeRight()

        // Go Back to other tab to see if all buttons are disabled.
        waitforExistence(app.collectionViews.cells["home"])
        app.collectionViews.cells["home"].tap()

        XCTAssertFalse(app.buttons["URLBarView.backButton"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)

        // Go back to portrait mode
        XCUIDevice.shared().orientation = .portrait
    }

    func testClearURLTextUsingBackspace() {
        navigator.openURL(urlString: website1["url"]!)
        waitForValueContains(app.textFields["url"], value: website1["value"]!)

        // Simulate pressing on backspace key should remove the text
        app.textFields["url"].tap()
        app.textFields["address"].typeText("\u{8}")

        let value = app.textFields["address"].value
        XCTAssertEqual(value as? String, "", "The url has not been removed correctly")
    }
}
