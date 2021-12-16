//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct TestCasesWithConfiguration: Decodable {

	// MARK: - Internal

	let defaultRiskCalculationConfiguration: ENA.RiskCalculationConfiguration
	let testCases: [ExposureWindowTestCase]

}
