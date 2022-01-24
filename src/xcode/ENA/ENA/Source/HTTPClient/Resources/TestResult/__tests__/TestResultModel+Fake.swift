//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension TestResultModel {
	static func fake(
		testResult: Int = 0,
		sc: Int? = nil,
		labId: String? = nil
	) -> TestResultModel {
		TestResultModel(
			testResult: testResult,
			sc: sc,
			labId: labId
		)
	}
}
