//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct CheckinTestCase: Decodable {

	// MARK: - Internal

	let description: String
	let startDate: Date
	let endDate: Date
	let expStartDate: Date?
	let expEndDate: Date?

}
