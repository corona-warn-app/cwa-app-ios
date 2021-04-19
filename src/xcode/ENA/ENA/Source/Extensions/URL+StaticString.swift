//
// 🦠 Corona-Warn-App
//

import Foundation

extension URL {
	init(staticString: StaticString) {
		guard let url = URL(string: "\(staticString)") else {
			preconditionFailure("Invalid static URL string: \(staticString)")
		}

		self = url
	}
}
