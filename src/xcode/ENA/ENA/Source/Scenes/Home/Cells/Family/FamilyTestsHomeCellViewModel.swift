//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct FamilyTestsHomeCellViewModel {

	// MARK: - Init

	init(
		_ badgeCount: Int = 0
	) {
		self.badgeCount = badgeCount
	}

	// MARK: - Internal

	let titleText: String = AppStrings.Home.familyTestTitle

	var badgeText: String? {
		guard badgeCount > 0 else { return nil }
		return "\(badgeCount)"
	}

	var detailText: String? {
		badgeCount > 0 ? AppStrings.Home.familyTestDetail : nil
	}

	var isDetailsHidden: Bool {
		detailText == nil
	}

	// MARK: - Private

	private let badgeCount: Int
}
