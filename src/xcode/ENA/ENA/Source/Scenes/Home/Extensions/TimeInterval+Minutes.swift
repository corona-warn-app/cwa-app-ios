//
// 🦠 Corona-Warn-App
//

import Foundation

extension TimeInterval {

	init?(minutes: Int?) {
		guard let minutes = minutes else {
			return nil
		}

		self.init(minutes * 60)
	}

}
