//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension TestResultReceiveModel {
	static func fake(
		testResult: Int = 0,
		sc: Int? = nil,
		labId: String? = nil
	) -> TestResultReceiveModel {
		TestResultReceiveModel(
			testResult: testResult,
			sc: sc,
			labId: labId
		)
	}
}
