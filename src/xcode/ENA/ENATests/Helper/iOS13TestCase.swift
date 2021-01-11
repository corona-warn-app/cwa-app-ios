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
			print("Skipping test because it's iOS13+ only.")
			return
		}
	}

}
