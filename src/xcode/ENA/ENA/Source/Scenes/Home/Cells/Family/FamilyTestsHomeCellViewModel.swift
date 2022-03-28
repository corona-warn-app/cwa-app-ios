//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct FamilyTestsHomeCellViewModel {

	// MARK: - Init

	init(
		_ badgeCount: Int
	) {
		self.badgeCount = badgeCount
		self.detailText = badgeCount > 0 ? AppStrings.Home.familyTestDetail : nil
	}

	// MARK: - Internal

	let image: UIImage = UIImage(imageLiteralResourceName: "Icon_Family")
	let detailIndicatorImage: UIImage = UIImage(imageLiteralResourceName: "Icons_Chevron_plain")

	let titleText: String = AppStrings.Home.familyTestTitle
	let detailText: String?
	let badgeView: UIView = UIView()

	// MARK: - Private

	private let badgeCount: Int
}
