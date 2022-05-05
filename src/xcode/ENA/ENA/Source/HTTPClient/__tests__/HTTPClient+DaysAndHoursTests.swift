//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

final class HTTPClientDaysAndHoursTests: CWATestCase {
	let binFileSize = 501
	let sigFileSize = 144
	let mockUrl = URL(staticString: "http://example.com")
	let tan = "1234"

	private var keys: [ENTemporaryExposureKey] {
		let key = ENTemporaryExposureKey()
		key.keyData = Data(bytes: [1, 2, 3], count: 3)
		key.rollingPeriod = 1337
		key.rollingStartNumber = 42
		key.transmissionRiskLevel = 8

		return [key]
	}

	private func assertPackageFormat(for response: PackageDownloadResponse) {
		// Packages for key download are never empty
		XCTAssertFalse(response.isEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package?.bin.count, binFileSize)
		XCTAssertEqual(response.package?.signature.count, sigFileSize)
	}
}
