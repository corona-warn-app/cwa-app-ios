//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import ExposureNotification
import XCTest

final class HTTPClientSubmitTests: CWATestCase {

	let mockUrl = URL(staticString: "http://example.com")
	let expectationsTimeout: TimeInterval = 2
	let tan = "1234"

	private var keys: [SAP_External_Exposurenotification_TemporaryExposureKey] {
		var key = SAP_External_Exposurenotification_TemporaryExposureKey()
		key.keyData = Data(bytes: [1, 2, 3], count: 3)
		key.rollingPeriod = 1337
		key.rollingStartIntervalNumber = 42
		key.transmissionRiskLevel = 8

		return [key]
	}

}
