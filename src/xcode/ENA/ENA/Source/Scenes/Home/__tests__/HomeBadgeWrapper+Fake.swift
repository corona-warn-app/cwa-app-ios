//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
@testable import ENA

extension HomeBadgeWrapper {

	static func fake() -> HomeBadgeWrapper {
		let mockStore = MockTestStore()
		return  HomeBadgeWrapper(mockStore)
	}

}
