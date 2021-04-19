////
// 🦠 Corona-Warn-App
//

import Foundation

extension Array {
	public subscript(safe index: Int) -> Element? {
		guard index >= 0, index < endIndex else {
			return nil
		}

		return self[index]
	}
}
