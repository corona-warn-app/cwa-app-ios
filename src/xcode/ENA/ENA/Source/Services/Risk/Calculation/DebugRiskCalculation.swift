//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DebugRiskCalculation: ENFRiskCalculationProtocol {

	// MARK: - Init

	init(
		riskCalculation: ENFRiskCalculation,
		store: Store
	) {
		self.riskCalculation = riskCalculation
		self.store = store
	}

	// MARK: - Internal

	/// executes the risk calculation and writes the risk calculation values and it's configuration to the store
	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) -> ENFRiskCalculationResult {
		let riskCalculationResult = riskCalculation.calculateRisk(exposureWindows: exposureWindows, configuration: configuration)

		store.mostRecentRiskCalculation = riskCalculation
		store.mostRecentRiskCalculationConfiguration = configuration

		return riskCalculationResult
	}

	// MARK: - Internal

	var mappedExposureWindows: [RiskCalculationExposureWindow] = []
	
	// MARK: - Private

	private let riskCalculation: ENFRiskCalculation
	private let store: Store

}

#endif
