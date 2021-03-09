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


	// MARK: - Internal

	var checkIns: [String]

	// MARK: - Private

}
