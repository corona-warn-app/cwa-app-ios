//
// 🦠 Corona-Warn-App
//

import Foundation

extension URL {
	init(staticString: StaticString) {
		// swiftlint:disable:next force_unwrapping
		self.init(string: "\(staticString)")!
	}
}
