////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateKeyValueCellViewModel {

	// MARK: - Init

	init?(
		key: String?,
		value: String?
	) {
		guard let key = key,
			  let value = value
		else {
			return nil
		}
		self.headline = key
		self.text = value
	}

	// MARK: - Internal

	let headlineFont: UIFont = .enaFont(for: .headline)
	let textFont: UIFont = .enaFont(for: .body)
	let headlineTextColor: UIColor = .enaColor(for: .textPrimary1)
	let textTextColor: UIColor = .enaColor(for: .textPrimary1)

	let headline: String
	let text: String

}
