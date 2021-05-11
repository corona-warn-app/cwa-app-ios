////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateKeyValueCellViewModel {

	// MARK: - Init

	init?(
		key: String?,
		value: String?,
		isBottomSeparatorHidden: Bool = false,
		topSpace: CGFloat? = nil,
		bottomSpace: CGFloat? = nil
	) {
		guard let key = key,
			  let value = value
		else {
			return nil
		}
		self.headline = key
		self.text = value
		self.isBottomSeparatorHidden = isBottomSeparatorHidden
		self.topSpace = topSpace
		self.bottomSpace = bottomSpace
	}

	// MARK: - Internal

	let headlineFont: UIFont = .enaFont(for: .body)
	let textFont: UIFont = .enaFont(for: .subheadline)
	let headlineTextColor: UIColor = .enaColor(for: .textPrimary1)
	let textTextColor: UIColor = .enaColor(for: .textPrimary2)

	let headline: String
	let text: String
	let isBottomSeparatorHidden: Bool
	let topSpace: CGFloat?
	let bottomSpace: CGFloat?

}
