//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest

class iOS13TestCase: XCTestCase {

	override func invokeTest() {
		if #available(iOS 13, *) {
			return super.invokeTest()
		} else {
			// swiftlint:disable:next no_plain_print
			print("Skipping test \(self) because it's iOS13+ only.")
			return
		}
	}

}
