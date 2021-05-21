////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryDayTest: Equatable {

	// MARK: - Init

	init?(
		id: Int,
		date: String,
		type: Int,
		result: Int
	) {
		guard let type = CoronaTestType(rawValue: type),
			  let result = TestResult(rawValue: result) else {
			return nil
		}
		self.id = id
		self.date = date
		self.type = type
		self.result = result
	}

	// MARK: - Internal

	let id: Int
	let date: String
	let type: CoronaTestType
	let result: TestResult

}
