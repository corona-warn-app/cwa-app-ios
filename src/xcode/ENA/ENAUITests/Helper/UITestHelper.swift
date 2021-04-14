////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest

/// we will search for the given identifier inside a scrollable element
/// scroll and collect all visible elements until the collection doesn't change

enum UITestHelper {
	
	static func scrollTo(identifier: String, element: XCUIElement, app: XCUIApplication) -> XCUIElement? {
		var allElementsFound = false
		var lastLoopSeenElements: [String] = []
		var retryCount = 0
		
		while !allElementsFound, retryCount < 10 /* max retries is arbitrary but required to prevent infinite loops */ {
			/** search for a possible button */
			guard !element.buttons[identifier].exists else {
				return element.buttons[identifier]
			}
			
			/** search for a possible cell */
			guard !element.cells[identifier].exists else {
				return element.cells[identifier]
			}
			
			let allElements = element.cells.allElementsBoundByIndex.map { $0.identifier } + element.buttons.allElementsBoundByIndex.map { $0.identifier }
			allElementsFound = allElements == lastLoopSeenElements
			lastLoopSeenElements = allElements
			
			app.swipeUp()
			retryCount += 1
		}
		return nil
	}
	
}
