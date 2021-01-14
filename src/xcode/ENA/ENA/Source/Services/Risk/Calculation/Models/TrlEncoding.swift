//
// 🦠 Corona-Warn-App
//

import Foundation

struct TrlEncoding: Codable {

	// MARK: - Init

	init(from trlEncoding: SAP_Internal_V2_TransmissionRiskLevelEncoding) {
		self.infectiousnessOffsetStandard = Int(trlEncoding.infectiousnessOffsetStandard)
		self.infectiousnessOffsetHigh = Int(trlEncoding.infectiousnessOffsetHigh)
		self.reportTypeOffsetRecursive = Int(trlEncoding.reportTypeOffsetRecursive)
		self.reportTypeOffsetSelfReport = Int(trlEncoding.reportTypeOffsetSelfReport)
		self.reportTypeOffsetConfirmedClinicalDiagnosis = Int(trlEncoding.reportTypeOffsetConfirmedClinicalDiagnosis)
		self.reportTypeOffsetConfirmedTest = Int(trlEncoding.reportTypeOffsetConfirmedTest)
	}

	// MARK: - Internal

	let infectiousnessOffsetStandard: Int
	let infectiousnessOffsetHigh: Int
	let reportTypeOffsetRecursive: Int
	let reportTypeOffsetSelfReport: Int
	let reportTypeOffsetConfirmedClinicalDiagnosis: Int
	let reportTypeOffsetConfirmedTest: Int
	
}
