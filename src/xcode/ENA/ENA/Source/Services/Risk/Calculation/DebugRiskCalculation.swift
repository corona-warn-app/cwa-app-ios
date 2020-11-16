//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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

	// MARK: - Private

	private let riskCalculation: RiskCalculation
	private let store: Store

}

#endif
