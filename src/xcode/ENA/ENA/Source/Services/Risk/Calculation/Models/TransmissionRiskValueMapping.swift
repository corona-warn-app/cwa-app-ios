//
// 🦠 Corona-Warn-App
//

import Foundation

struct TransmissionRiskValueMapping: Codable {

	// MARK: - Init

	init(from transmissionRiskValueMapping: SAP_Internal_V2_TransmissionRiskValueMapping) {
		self.transmissionRiskLevel = transmissionRiskValueMapping.transmissionRiskLevel
		self.transmissionRiskValue = transmissionRiskValueMapping.transmissionRiskValue
	}

	// MARK: - Internal
	
	let transmissionRiskLevel: Int32
	let transmissionRiskValue: Double
	
}
