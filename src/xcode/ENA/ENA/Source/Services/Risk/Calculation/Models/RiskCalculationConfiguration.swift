//
// 🦠 Corona-Warn-App
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
		self.transmissionRiskValueMapping = riskCalculationParameters.transmissionRiskValueMapping.map { TransmissionRiskValueMapping(from: $0) }
		self.maxEncounterAgeInDays = riskCalculationParameters.maxEncounterAgeInDays == 0 ? 14 : riskCalculationParameters.maxEncounterAgeInDays
	}

	// MARK: - Internal

	let minutesAtAttenuationFilters: [MinutesAtAttenuationFilter]
	let trlFilters: [TrlFilter]
	let minutesAtAttenuationWeights: [MinutesAtAttenuationWeight]
	let normalizedTimePerEWToRiskLevelMapping: [NormalizedTimeToRiskLevelMapping]
	let normalizedTimePerDayToRiskLevelMapping: [NormalizedTimeToRiskLevelMapping]
	let trlEncoding: TrlEncoding
	let transmissionRiskValueMapping: [TransmissionRiskValueMapping]
	let maxEncounterAgeInDays: UInt32
}
