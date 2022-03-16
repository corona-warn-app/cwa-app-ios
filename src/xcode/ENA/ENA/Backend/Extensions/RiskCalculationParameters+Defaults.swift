//
// 🦠 Corona-Warn-App
//

import Foundation

extension SAP_Internal_V2_RiskCalculationParameters {
	
	var defaultedMaxEncounterAgeInDays: UInt32 {
		maxEncounterAgeInDays == 0 ? 14 : maxEncounterAgeInDays
	}
}
