//
// 🦠 Corona-Warn-App
//

import Foundation

struct TrlFilter: Codable {

	// MARK: - Init

	init(from trlFilter: SAP_Internal_V2_TrlFilter) {
		self.dropIfTrlInRange = ENARange(from: trlFilter.dropIfTrlInRange)
	}

	// MARK: - Internal

	let dropIfTrlInRange: ENARange

}
