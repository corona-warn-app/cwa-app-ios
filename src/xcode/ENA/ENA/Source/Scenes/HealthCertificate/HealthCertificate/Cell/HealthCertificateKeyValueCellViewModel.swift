////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateKeyValueCellViewModel {

	// MARK: - Init

	init(_ model: HealthCertificateViewModel.DummyModel ) {
		self.headline = model.key
		self.text = model.value
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let headlineFont: UIFont = .enaFont(for: .headline)
	let textFont: UIFont = .enaFont(for: .body)
	let headlineTextColor: UIColor = .enaColor(for: .textPrimary1)
	let textTextColor: UIColor = .enaColor(for: .textPrimary1)

	let headline: String
	let text: String

	// MARK: - Private
}
