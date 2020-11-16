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

import Foundation

struct RiskCalculationConfiguration: Codable {

	// MARK: - Init

	init(from riskCalculationParameters: SAP_Internal_V2_RiskCalculationParameters) {
		self.minutesAtAttenuationFilters = riskCalculationParameters.minutesAtAttenuationFilters.map { MinutesAtAttenuationFilter(from: $0) }
		self.trlFilters = riskCalculationParameters.trlFilters.map { TrlFilter(from: $0) }
		self.minutesAtAttenuationWeights = riskCalculationParameters.minutesAtAttenuationWeights.map { MinutesAtAttenuationWeight(from: $0) }
		self.normalizedTimePerEWToRiskLevelMapping = riskCalculationParameters.normalizedTimePerEwtoRiskLevelMapping.map { NormalizedTimeToRiskLevelMapping(from: $0) }
		self.normalizedTimePerDayToRiskLevelMapping = riskCalculationParameters.normalizedTimePerDayToRiskLevelMapping.map { NormalizedTimeToRiskLevelMapping(from: $0) }
		self.trlEncoding = TrlEncoding(from: riskCalculationParameters.trlEncoding)
		self.transmissionRiskLevelMultiplier = riskCalculationParameters.transmissionRiskLevelMultiplier
	}

	// MARK: - Internal

	let minutesAtAttenuationFilters: [MinutesAtAttenuationFilter]
	let trlFilters: [TrlFilter]
	let minutesAtAttenuationWeights: [MinutesAtAttenuationWeight]
	let normalizedTimePerEWToRiskLevelMapping: [NormalizedTimeToRiskLevelMapping]
	let normalizedTimePerDayToRiskLevelMapping: [NormalizedTimeToRiskLevelMapping]
	let trlEncoding: TrlEncoding
	let transmissionRiskLevelMultiplier: Double
	
}
