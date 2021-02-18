////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPADataType {
	case userData(UserMetadata)
	case riskExposureMetadata(RiskExposureMetadata)
	case clientMetadata(ClientMetadata)
	case testResultMetadata(TestResultMetaData)
}

enum PPAPartialDataType {
	case testResult(TestResult)
	case hoursSinceTestRegistration(Int?)
}
