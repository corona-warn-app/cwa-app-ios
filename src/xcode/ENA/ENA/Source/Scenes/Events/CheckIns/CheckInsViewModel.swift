////
// 🦠 Corona-Warn-App
//

import Foundation

final class CheckInsViewModel {

	// MARK: - Init

	convenience init() {
		self.init([])
	}

	init(
		_ checkIns: [String]
	) {
		self.checkIns = checkIns
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var checkIns: [String]

	// MARK: - Private

}
