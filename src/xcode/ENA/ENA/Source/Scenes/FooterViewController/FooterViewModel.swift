////
// 🦠 Corona-Warn-App
//

import Foundation

final class FooterViewModel {

	// MARK: - Init
	
	init(
		primaryButtonName: String? = nil,
		secondaryButtonName: String? = nil,
		isPrimaryButtonEnabled: Bool = true,
		isSecondaryButtonEnabled: Bool = true,
		isPrimaryButtonHidden: Bool = false,
		isSecondaryButtonHidden: Bool = false
	) {
		self.primaryButtonName = primaryButtonName
		self.secondaryButtonName = secondaryButtonName
		self.isPrimaryButtonEnabled = isPrimaryButtonEnabled
		self.isSecondaryButtonEnabled = isSecondaryButtonEnabled
		self.isPrimaryButtonHidden = isPrimaryButtonHidden
		self.isSecondaryButtonHidden = isSecondaryButtonHidden
	}

	// MARK: - Internal

	let primaryButtonName: String?
	let secondaryButtonName: String?

	let isPrimaryButtonEnabled: Bool
	let isSecondaryButtonEnabled: Bool

	let isPrimaryButtonHidden: Bool
	let isSecondaryButtonHidden: Bool

	// MARK: - Private

}
