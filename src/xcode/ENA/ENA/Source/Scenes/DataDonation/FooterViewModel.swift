////
// 🦠 Corona-Warn-App
//

import Foundation

final class FooterViewModel {

	// MARK: - Init
	init(
		primaryButtonName: String,
		secondaryButtonName: String,
		isPrimaryButtonEnabled: Bool,
		isSecondaryButtonEnabled: Bool,
		isPrimaryButtonHidden: Bool,
		isSecondaryButtonHidden: Bool
	) {
		self.primaryButtonName = primaryButtonName
		self.secondaryButtonName = secondaryButtonName
		self.isPrimaryButtonEnabled = isPrimaryButtonEnabled
		self.isSecondaryButtonEnabled = isSecondaryButtonEnabled
		self.isPrimaryButtonHidden = isPrimaryButtonHidden
		self.isSecondaryButtonHidden = isSecondaryButtonHidden
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let primaryButtonName: String?
	let secondaryButtonName: String?

	let isPrimaryButtonEnabled: Bool
	let isSecondaryButtonEnabled: Bool

	let isPrimaryButtonHidden: Bool
	let isSecondaryButtonHidden: Bool

	// MARK: - Private

}
