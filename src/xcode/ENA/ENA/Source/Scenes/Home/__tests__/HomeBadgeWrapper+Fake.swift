//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
@testable import ENA

extension HomeBadgeWrapper {

	static func fake(
		badgesCount: [BadgeType: Int?] = [:]
	) -> HomeBadgeWrapper {
		let mockStore = MockTestStore()
		return  HomeBadgeWrapper(mockStore)
	}

}
