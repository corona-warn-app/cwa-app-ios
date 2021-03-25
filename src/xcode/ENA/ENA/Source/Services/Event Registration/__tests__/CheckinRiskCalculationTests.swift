////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinRiskCalculationTests: XCTestCase {

	func test_some() {
		let config = createAppConfig()
		let mockConfigProvider = CachedAppConfigurationMock(with: config)
	}

	private func createAppConfig() -> SAP_Internal_V2_ApplicationConfigurationIOS {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		var tracingParameters = SAP_Internal_V2_PresenceTracingParameters()
		var transmissionRiskValueMapping = [SAP_Internal_V2_TransmissionRiskValueMapping]()
		var normalizedTimePerCheckInToRiskLevelMapping = [SAP_Internal_V2_NormalizedTimeToRiskLevelMapping]()
		var normalizedTimePerDayToRiskLevelMapping = [SAP_Internal_V2_NormalizedTimeToRiskLevelMapping]()
		var riskCalculationParameters = SAP_Internal_V2_PresenceTracingRiskCalculationParameters()

		riskCalculationParameters.transmissionRiskValueMapping = transmissionRiskValueMapping
		riskCalculationParameters.normalizedTimePerCheckInToRiskLevelMapping = normalizedTimePerCheckInToRiskLevelMapping
		riskCalculationParameters.normalizedTimePerCheckInToRiskLevelMapping = normalizedTimePerDayToRiskLevelMapping

		tracingParameters.riskCalculationParameters = riskCalculationParameters
		config.presenceTracingParameters = tracingParameters

		return config
	}
}
