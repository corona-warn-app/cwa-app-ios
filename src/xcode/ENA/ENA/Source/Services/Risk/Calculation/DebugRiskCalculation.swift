//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DebugRiskCalculation: RiskCalculationProtocol {

	// MARK: - Init

	init(
		riskCalculation: RiskCalculation,
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
	) throws -> RiskCalculationResult {
		let riskCalculationResult = try riskCalculation.calculateRisk(exposureWindows: exposureWindows, configuration: configuration)

		store.mostRecentRiskCalculation = riskCalculation
		store.mostRecentRiskCalculationConfiguration = configuration

		return riskCalculationResult
	}

	// MARK: - Internal

	var mappedExposureWindows: [RiskCalculationExposureWindow] = []
	
	// MARK: - Private

	private let riskCalculation: RiskCalculation
	private let store: Store

}

#endif
