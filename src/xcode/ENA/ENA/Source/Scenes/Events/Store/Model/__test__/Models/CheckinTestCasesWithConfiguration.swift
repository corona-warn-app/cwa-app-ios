//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct CheckinTestCasesWithConfiguration: Decodable {

	// MARK: - Internal

	let defaultConfiguration: ENA.PresenceTracingSubmissionConfiguration
	let testCases: [CheckinTestCase]

}
